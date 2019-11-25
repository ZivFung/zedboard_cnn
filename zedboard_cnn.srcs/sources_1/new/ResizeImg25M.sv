`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2018 08:23:44 AM
// Design Name: 
// Module Name: ResizeImg25M
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


module Resizeimg25M#(                    //Nearest interpolation
    parameter INPUT_DW = 4,
    parameter RAM_AW = 19,
    parameter INPUT_ROWNUM = 480,
    parameter INPUT_COLUMNNUM = 640,
    parameter OUTPUT_ROWNUM = 32,
    parameter OUTPUT_COLUMNNUM = 32
    )(
    input wire clk,
//    input wire Clk25m,
    (*mark_debug = "true"*)input wire rst,
    input wire start,
    input wire [INPUT_DW-1:0]ImageIn,
    input wire [RAM_AW-1:0]VgaAddrIn,
    output logic [RAM_AW-1:0]ResizWrAddr,
    output logic [INPUT_DW-1:0]ResizWrData,
    output logic ResizWrEn,
//    output logic [RAM_AW-1:0]AddrOut,
    output logic [INPUT_DW-1:0]ImgOut,
    output logic OutEn
    );
    localparam ROW_SCALE = INPUT_ROWNUM / OUTPUT_ROWNUM;
    localparam COLUMN_SCALE = INPUT_COLUMNNUM / OUTPUT_COLUMNNUM;
    localparam ROW_INTERVAL = COLUMN_SCALE + (ROW_SCALE - 1) * INPUT_COLUMNNUM;
    localparam COLUMN_INTERVAL = COLUMN_SCALE;
    localparam READ_ENDNUM = INPUT_COLUMNNUM * (INPUT_ROWNUM - ROW_SCALE + 1);
    
    logic [1:0]Clk25mCapture;
    logic [1:0]ResizeState;
    
    always_ff@(posedge clk)begin
      if(rst)ResizeState <= 0;
      else begin
        case(ResizeState)
          0:begin
            if(start)ResizeState <= 1;
            else ResizeState <= ResizeState;
          end
          1:begin
            if(VgaAddrIn == 0)ResizeState <= 2;
            else ResizeState <= ResizeState;
          end
          2:begin
            if(ReadFinish)ResizeState <= 3;
            else ResizeState <= ResizeState;
          end
          3:begin
            ResizeState <= 0;
          end
        endcase
      end
    end
    
    logic ReadFinish;
    logic ColumnEn;
    logic [9:0]ResizeWrCnt;
    logic [18:0]AddrCmp;
    always_ff@(posedge clk)begin
      if(rst)begin ReadFinish <= 0;ColumnEn <= 0;AddrCmp <= COLUMN_SCALE;ImgOut <= 0;ResizWrAddr <= 739;ResizWrEn <= 0;
        ResizWrData <= 0;ResizeWrCnt <= 0;end
      else begin
        if(ResizeState==2)begin
          if(VgaAddrIn == (AddrCmp-1))begin
            ColumnEn <= 1;
            if(ResizeWrCnt%32 < 2)begin
              ImgOut <= 12'h000;
              ResizWrData <= 12'h000;
            end
            else begin
              ImgOut <= (ImageIn > 0)? 12'b0:12'hfff;
              ResizWrData <= (ImageIn > 0)? 12'b0:12'hfff;
            end
            
            ResizWrEn <= 1;
            if((ResizeWrCnt)%32 == 0 & ResizeWrCnt>0)begin ResizWrAddr <= ResizWrAddr + 609;ResizeWrCnt <= ResizeWrCnt + 1;end 
            else begin ResizWrAddr <= ResizWrAddr + 1;ResizeWrCnt <= ResizeWrCnt + 1;end
            
            if(AddrCmp == READ_ENDNUM)ReadFinish <= 1;
            else if(AddrCmp%INPUT_COLUMNNUM == 0)
              AddrCmp <= AddrCmp + ROW_INTERVAL;
            else
              AddrCmp <= AddrCmp + COLUMN_SCALE;
          end
          else begin ColumnEn <= 0;ReadFinish <= 0;end
        end
        else begin ColumnEn <= 0;ReadFinish <= 0;end
      end
    end
    always_ff@(posedge clk)OutEn <= ColumnEn;

endmodule
