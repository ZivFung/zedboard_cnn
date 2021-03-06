`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2018 09:08:48 PM
// Design Name: 
// Module Name: ImgRam1
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


module ImgRam1#(
    parameter DW = 2,
    parameter AW = 10,
    parameter OUTROW_NUM = 5,
    parameter IMG_ROW = 32,
    parameter IMG_COLUMN = 32
    
    )(
    input wire clk,
    input wire rst,
    input wire start,
    input wire InputEn,
    input wire [DW-1:0]InputData,
    input wire [AW-1:0]OutputAddr,
    output logic DataReady,
    output logic [DW-1:0]OutData[OUTROW_NUM]  
    );
    localparam IMGPIXEL_NUM = IMG_COLUMN * IMG_ROW;
    
    logic [1:0]RamState;
    assign DataReady = ReadFinish;
    always_ff@(posedge clk)begin
      if(rst)RamState <= 0;
      else begin
        case(RamState)
          0:if(start)RamState <= 1;
            else RamState <= RamState;
          1:if(ReadFinish)RamState <= 2;
            else RamState <= RamState;
          2:RamState <= 0;
        endcase
      end
    end
    
    logic [DW-1:0]RamData[IMGPIXEL_NUM];
    
    always_ff@(posedge clk)begin
      if(rst)RamData <= '{IMGPIXEL_NUM{'0}};
      else begin
        case(RamState)
          1:if(InputEn)RamData <= {RamData[1:IMGPIXEL_NUM-1],InputData};
        endcase       
      end
    end
    
    logic ReadEn;
    assign ReadEn = InputEn & (RamState==1); 
    logic ReadFinish;
    Counter#(IMGPIXEL_NUM)ReadCnt(clk,rst,ReadEn,,ReadFinish);
    
    generate
      for(genvar k = 0 ; k < OUTROW_NUM ; k++)begin : DataOutput
        assign OutData[k] = RamData[OutputAddr+IMG_COLUMN*k];
      end
    endgenerate
    
endmodule