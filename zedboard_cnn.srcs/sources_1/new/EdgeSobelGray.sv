`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2018 03:33:08 PM
// Design Name: 
// Module Name: EdgeSobelGray
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*
Gx sobel
-1  -2  -1
 0   0   0
 1   2   1
 
Gy sobel
 -1  0  1
 -2  0  2
 -1  0  1
 */

module EdgeSobelGray#(
    parameter ROW_NUM = 32,
    parameter COLUMN_NUM = 32,
    parameter INPUT_DW = 8,
    parameter OUTPUT_DW = 8,
    parameter T = 10       
)(
    input wire clk,
    input wire rst, 
    input wire start,          
    input wire InputEn,
    input wire [INPUT_DW-1:0]InputData,
    output logic OutputStart,
    output logic OutputEn,
    output logic [OUTPUT_DW-1:0]OutputData
    );
    localparam PIXEL_NUM = ROW_NUM * COLUMN_NUM;
    localparam PIXEL_WIDTH = $clog2(PIXEL_NUM);
    
    assign OutputStart = EgdeReadFinish;
    logic [2:0]EdgeState;
    always_ff@(posedge clk)begin
      if(rst)EdgeState <= 0;
      else begin
        case(EdgeState)
          0:begin
            if(start)EdgeState <= 1;
            else EdgeState <= EdgeState;
          end
          1:begin
            if(ReadFinish)EdgeState <= 2;
            else EdgeState <= EdgeState;
          end
          2:begin
            if(EdgeFinish)EdgeState <= 3;
            else EdgeState <= EdgeState;
          end
          3:begin
            if(EgdeReadFinish)EdgeState <= 4;
            else EdgeState <= EdgeState;
          end
          4:begin
            if(OutFinish)EdgeState <= 5;
            else EdgeState <= EdgeState;
          end
          5:begin
            EdgeState <= 0;
          end
        endcase
      end
    end
//    logic DelayCo;
//    Counter#(13)Delay(clk,rst,EdgeState==3,,DelayCo);
    
    logic [INPUT_DW-1:0]ImgData[PIXEL_NUM];
    logic [INPUT_DW-1:0]EdgeImg[PIXEL_NUM];
    logic [PIXEL_WIDTH-1:0]ReadCnt;
    logic ReadFinish;
    assign ReadFinish = ReadCnt == PIXEL_NUM-1;
    
    always_ff@(posedge clk)begin
      if(rst)begin ImgData <= '{PIXEL_NUM{'0}};ReadCnt <= 0;end
      else begin
        case(EdgeState)
          1:begin
            if(InputEn)begin
              ImgData[ReadCnt] <= InputData;
              ReadCnt <= ReadCnt + 1;
            end
          end
        endcase
      end
    end 
    
    logic [INPUT_DW-1:0]WindowWeight[8];
    logic [PIXEL_WIDTH-1:0]EdgeCnt;
    logic EdgeFinish;
    assign EdgeFinish = EdgeCnt == (PIXEL_NUM-COLUMN_NUM-2);
    
    always_ff@(posedge clk)begin
      if(rst)EdgeCnt <= COLUMN_NUM + 1;
      else begin
        if(EdgeState == 2)begin
          if((EdgeCnt+1)%(COLUMN_NUM)==(COLUMN_NUM-1))EdgeCnt <= EdgeCnt + 3;
          else begin
            EdgeCnt <= EdgeCnt + 1;
          end
        end
        else EdgeCnt <= COLUMN_NUM + 1;
      end
    end
    
    always_ff@(posedge clk)begin
      if(rst)WindowWeight <= '{8{'0}};
      else begin
        WindowWeight[0] <= ImgData[EdgeCnt-COLUMN_NUM-1];
        WindowWeight[1] <= ImgData[EdgeCnt-COLUMN_NUM];
        WindowWeight[2] <= ImgData[EdgeCnt-COLUMN_NUM+1];
        WindowWeight[3] <= ImgData[EdgeCnt-1];
        WindowWeight[4] <= ImgData[EdgeCnt+1];
        WindowWeight[5] <= ImgData[EdgeCnt+COLUMN_NUM-1];
        WindowWeight[6] <= ImgData[EdgeCnt+COLUMN_NUM];
        WindowWeight[7] <= ImgData[EdgeCnt+COLUMN_NUM+1];      
      end
    end
    
    wire signed[INPUT_DW-1:0]GradientX = (INPUT_DW+2)'(WindowWeight[5] + WindowWeight[6]<<1 + 
               WindowWeight[7] - WindowWeight[0] - WindowWeight[1]<<1 - WindowWeight[2]);
    wire signed[INPUT_DW-1:0]GradientY = (INPUT_DW+2)'(WindowWeight[3] + WindowWeight[4]<<1 +
               WindowWeight[7] - WindowWeight[0] - WindowWeight[3]<<1 - WindowWeight[5]);
    wire signed[2*INPUT_DW-1:0]SquareGX = GradientX * GradientX;
    wire signed[2*INPUT_DW-1:0]SquareGY = GradientY * GradientY;
    wire [2*INPUT_DW-1:0]SquareSum =SquareGX + SquareGY; 
    
    logic SqrtDataValid;
    logic [11:0]SqrtData;
    cordic_0 theSqrt(
        .aclk(clk),
        .s_axis_cartesian_tvalid(EdgeState==2),
        .s_axis_cartesian_tdata(SquareSum),
        .m_axis_dout_tvalid(SqrtDataValid),
        .m_axis_dout_tdata(SqrtData)
      );
    
    logic [PIXEL_WIDTH-1:0]EdgeReadCnt;
    logic EgdeReadFinish;
    assign EgdeReadFinish = EdgeReadCnt == (PIXEL_NUM-COLUMN_NUM-2);
    always_ff@(posedge clk)begin
      if(rst) EdgeReadCnt <= COLUMN_NUM + 1;
      else begin
        case(EdgeState)
        2,3:
          if(SqrtDataValid)begin
            if((EdgeReadCnt+1)%(COLUMN_NUM)==(COLUMN_NUM-1))EdgeReadCnt <= EdgeReadCnt + 3;
            else
              EdgeReadCnt <= EdgeReadCnt + 1;
          end
        default:EdgeReadCnt <= COLUMN_NUM + 1;
        endcase
      end
    end
    
    always_ff@(posedge clk)begin
      if(rst)begin EdgeImg <= '{PIXEL_NUM{'0}};end
      else begin
        case(EdgeState)
          1:begin
            if(InputEn)begin
              EdgeImg[ReadCnt] <= InputData;
            end
          end
          2:begin
            if(SqrtDataValid)begin
              EdgeImg[EdgeReadCnt] <= SqrtData[INPUT_DW-1:0];
            end
          end
          3:begin
            if(SqrtDataValid)begin
              EdgeImg[EdgeReadCnt] <= SqrtData[INPUT_DW-1:0];
          end
          end
        endcase
      end
    end
    
    logic[PIXEL_WIDTH-1:0]OutCnt;
    logic OutFinish;
    assign OutFinish = OutCnt == PIXEL_NUM-1;
    always_ff@(posedge clk)begin
      if(rst)OutCnt <= 0;
      else begin
        case(EdgeState)
          4:begin
            OutputData <= EdgeImg[OutCnt];
            OutputEn <= 1;
            OutCnt <= OutCnt + 1;
          end
          default:begin OutputData <= 0;OutputEn <= 0;end
        endcase
      end
    end
    
endmodule
