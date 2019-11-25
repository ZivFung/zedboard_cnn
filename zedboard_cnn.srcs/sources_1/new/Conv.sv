`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2018 03:46:32 PM
// Design Name: 
// Module Name: Conv
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
module Adder#(
  parameter INPUT_DATA_WIDTH = 16,
  parameter OUTPUT_DATA_WIDTH = 16
  )(
  input wire signed[INPUT_DATA_WIDTH-1:0]add1,
  input wire signed[INPUT_DATA_WIDTH-1:0]add2,
  output logic signed[OUTPUT_DATA_WIDTH-1:0]addout
  );
  assign addout = add1 + add2;
endmodule

module Conv#(
    COV_CORE_ROW = 5,
    COV_CORE_COLUMN = 5,
    INPUT_DATA_WIDTH = 2,
    INPUT_DATA_FW = 0,
    INPUT_DATA_ROW = 32,
    INPUT_DATA_NUM = 1024,
    COV_CORE_WIDTH = 16,   //    Q6.10
    COV_CORE_FW = 10,
    OUTPUT_DATA_WIDTH = 16,
    OUTPUT_DATA_FW = 10,
    CONV_CORE_DATA_FILE = "conv_core.dat"
    )(
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed[INPUT_DATA_WIDTH-1:0]Din,
    input wire Din_en,
    output logic Dout_en,
    output logic signed[OUTPUT_DATA_WIDTH-1:0]Dout,
    output logic DoutStart,
    output logic Finish
    );
    localparam CORENUM = COV_CORE_ROW * COV_CORE_COLUMN;
    localparam CORENUM_WIDTH = $clog2(CORENUM);
    localparam INPUT_NUM_WIDTH = $clog2(INPUT_DATA_NUM);
    localparam FINISH_CNT = INPUT_DATA_ROW * (INPUT_DATA_ROW - COV_CORE_ROW + 1);
    localparam FINISHCNT_WIDTH = $clog2(FINISH_CNT);
    localparam INPUT_DATA_COLUMN = INPUT_DATA_NUM/INPUT_DATA_ROW;
    
    reg signed[COV_CORE_WIDTH-1:0]ConvCoreData[0:CORENUM-1];initial $readmemh(CONV_CORE_DATA_FILE,ConvCoreData,0,CORENUM-1);
    logic signed[COV_CORE_WIDTH-1:0]CoreData[CORENUM];
    logic [1:0]ConvState;
    logic signed[INPUT_DATA_WIDTH-1:0]ConvInputData[INPUT_DATA_NUM];
    logic signed [INPUT_DATA_WIDTH-1:0]z[CORENUM];
    
    always_ff@(posedge clk)begin
      if(rst)begin ConvState <= 0; end
      else begin
        case(ConvState)
          0:begin
            if(start)ConvState <= 1;
            else ConvState <= ConvState;
          end
          1:begin
            if(ReadFinish)ConvState <= 2;
            else ConvState <= ConvState;
          end
          2:begin
            if(MulFinish)ConvState <=3;
            else ConvState <= ConvState;
          end
          3:begin
            ConvState <= 0;
          end   
        endcase
      end
    end
    assign Finish = ConvState==3;
    
    logic [INPUT_NUM_WIDTH-1:0]DataReadIndex;
    logic [CORENUM_WIDTH-1:0]CoreReadIndex;
    logic ReadFinish;
    logic ReadEn;
    assign ReadEn = Din_en&(ConvState==1);
    assign DoutStart = ReadFinish;
    Counter#(INPUT_DATA_NUM)ReadCnt(clk,rst,ReadEn,DataReadIndex,ReadFinish);
    Counter#(CORENUM)CoreReadCnt(clk,rst,1,CoreReadIndex,);
    
    always_ff@(posedge clk)begin
      if(rst)CoreData <= '{CORENUM{'0}};
      else begin
        CoreData[CoreReadIndex] <= ConvCoreData[CoreReadIndex];
      end
    end
    
    always_ff@(posedge clk)begin
      if(rst)ConvInputData <= '{INPUT_DATA_NUM{'0}};
      else begin if(ReadEn)ConvInputData[DataReadIndex] <= Din;end
    end
    
    logic [FINISHCNT_WIDTH-1:0]MulCnt;
    logic signed[INPUT_DATA_WIDTH-1:0]ZIn[COV_CORE_ROW];
    logic MulFinish,ColumnCo,CoreWinowCo;
    logic Cnt_en;
    assign Cnt_en = (MulCnt > 1) &(MulCnt < FINISH_CNT+2);
        
    Counter#(INPUT_DATA_COLUMN)ColumnCnt(clk,rst,Cnt_en,,ColumnCo);
    Counter#(COV_CORE_ROW)WindowCnt(clk,(ColumnCo | rst | ReadFinish),Cnt_en,,CoreWinowCo);
    Counter#(FINISH_CNT+2)CoreMulCnt(clk,rst,ConvState==2,MulCnt,MulFinish);

    always_ff@(posedge clk)begin
      if(rst)ZIn <= '{COV_CORE_ROW{'0}};
      else begin
        if(ConvState==2)begin
          ZIn[0] <= ConvInputData[MulCnt];
          ZIn[1] <= ConvInputData[MulCnt+INPUT_DATA_ROW];
          ZIn[2] <= ConvInputData[MulCnt+INPUT_DATA_ROW*2];
          ZIn[3] <= ConvInputData[MulCnt+INPUT_DATA_ROW*3];
          ZIn[4] <= ConvInputData[MulCnt+INPUT_DATA_ROW*4];
        end
      end 
    end
    
    always_ff@(posedge clk)begin
      if(rst) z <= '{CORENUM{'0}};
      else begin
        z[0:COV_CORE_COLUMN-1] <= {ZIn[0],z[0:COV_CORE_COLUMN-2]};
        z[COV_CORE_COLUMN:2*COV_CORE_COLUMN-1] <= {ZIn[1],z[COV_CORE_COLUMN:2*COV_CORE_COLUMN-2]};
        z[2*COV_CORE_COLUMN:3*COV_CORE_COLUMN-1] <= {ZIn[2],z[2*COV_CORE_COLUMN:3*COV_CORE_COLUMN-2]};
        z[3*COV_CORE_COLUMN:4*COV_CORE_COLUMN-1] <= {ZIn[3],z[3*COV_CORE_COLUMN:4*COV_CORE_COLUMN-2]};
        z[4*COV_CORE_COLUMN:5*COV_CORE_COLUMN-1] <= {ZIn[4],z[4*COV_CORE_COLUMN:5*COV_CORE_COLUMN-2]};
      end
    end
    
    logic signed [OUTPUT_DATA_WIDTH-1:0]RowAdder[COV_CORE_ROW-1:0]; 
    logic signed [OUTPUT_DATA_WIDTH-1:0]Mult[COV_CORE_ROW*COV_CORE_COLUMN-1:0];
    logic signed [OUTPUT_DATA_WIDTH-1:0]ParallelAdder;
    
    generate
      for(genvar i = 0 ; i < COV_CORE_ROW ; i++)begin : MultRow
        for(genvar k = 0 ; k < COV_CORE_COLUMN ; k++)begin : MultColumn
          assign Mult[i*COV_CORE_ROW+k] = z[i*COV_CORE_ROW+k] * CoreData[(i+1)*COV_CORE_ROW - k -1]
                                          >>> (COV_CORE_FW + INPUT_DATA_FW - OUTPUT_DATA_FW);
        end
      end
    endgenerate
    generate 
      for(genvar k = 0; k < COV_CORE_ROW; k++)begin : AddrRows
        assign RowAdder[k] =Mult[k * COV_CORE_COLUMN] + Mult[k * COV_CORE_COLUMN+1] + Mult[k * COV_CORE_COLUMN+2] +
                           Mult[k * COV_CORE_COLUMN+3] + Mult[k * COV_CORE_COLUMN+4];
      end
    endgenerate 
    
    assign ParallelAdder = RowAdder[0] + RowAdder[1] + RowAdder[2] + RowAdder[3] + RowAdder[4];
    
    logic [1:0]ENState;
    always_ff@(posedge clk)begin
      if(rst)begin ENState <= 0;Dout_en <=0; Dout <= 0;end
      else begin
        case(ENState)
          0:begin
            if(ReadFinish)ENState <= 1;
            else ENState <= ENState;
          end
          1:begin
            if(CoreWinowCo)begin ENState <= 2;Dout_en <= 1;Dout <= ParallelAdder; end
            else begin
              ENState <= ENState;
              Dout_en <= 0;
            end
          end
          2:begin
            if(MulFinish)begin
              ENState <= 3;
              Dout_en <= 1;
              Dout <= ParallelAdder;
            end
            else if(ColumnCo)begin
              ENState <= 1;
              Dout_en <= 1;
              Dout <= ParallelAdder;
            end
            else begin
              Dout_en <= 1;
              Dout <= ParallelAdder;
            end
          end
          3:begin
            Dout_en <= 0;
            ENState <= 0;
          end
        endcase
      end
    end
    
endmodule
