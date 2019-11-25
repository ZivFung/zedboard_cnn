`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2018 04:12:33 PM
// Design Name: 
// Module Name: Resizeimg
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


module Resizeimg#(                    //Nearest interpolation
    parameter INPUT_DW = 4,
    parameter RAM_AW = 19,
    parameter INPUT_ROWNUM = 480,
    parameter INPUT_COLUMNNUM = 640,
    parameter OUTPUT_ROWNUM = 32,
    parameter OUTPUT_COLUMNNUM = 32
    )(
    input wire clk,
    input wire Clk25m,
    input wire rst,
    input wire start,
    input wire [INPUT_DW-1:0]ImageIn,
    output logic [RAM_AW-1:0]ResizWrAddr,
    output logic [INPUT_DW-1:0]ResizWrData,
    output logic ResizWrEn,
    output logic [RAM_AW-1:0]AddrOut,
    output logic [INPUT_DW-1:0]ImgOut,
    output logic OutEn
    );
    localparam ROW_SCALE = INPUT_ROWNUM / OUTPUT_ROWNUM;
    localparam COLUMN_SCALE = INPUT_COLUMNNUM / OUTPUT_COLUMNNUM;
    localparam ROW_INTERVAL = COLUMN_SCALE + (ROW_SCALE - 1) * INPUT_COLUMNNUM;
    localparam COLUMN_INTERVAL = COLUMN_SCALE;
    
    logic [1:0]Clk25mCapture;
    always@(posedge clk)begin
      if(rst)Clk25mCapture <= 0;
      else Clk25mCapture <= {Clk25mCapture[0],Clk25m};
    end
    logic Clk25mEn;
    assign Clk25mEn = Clk25mCapture == 2'b01;
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
            if(ReadFinish)ResizeState <= 2;
            else ResizeState <= ResizeState;
          end
          2:begin
            ResizeState <= 0;
          end
        endcase
      end
    end
    
    logic ReadFinish;
    logic ColumnEn;
    
    always_ff@(posedge clk)begin
      if(rst)begin AddrOut <= 0;ReadFinish <= 0;ColumnEn <= 0; end
      else begin
        if(Clk25mEn & ResizeState==1)begin
          if(RowCntCo)begin ReadFinish <= 1; ColumnEn <= 0;end
          else if(ColumnCntCo)begin AddrOut <= AddrOut + ROW_INTERVAL;ReadFinish <= 0;ColumnEn <= 1;end
          else begin AddrOut <= AddrOut + COLUMN_INTERVAL;ReadFinish <= 0;ColumnEn <= 1;end
        end
        else if(Clk25mEn & ResizeState==2)begin
          ReadFinish <= 0;
          AddrOut <= 0;
        end
      end
    end
    
    logic RowCntCo,ColumnCntCo;
    Counter#(OUTPUT_COLUMNNUM)ColumnCnt(Clk25mEn,rst,ColumnEn,,ColumnCntCo);
    Counter#(OUTPUT_ROWNUM)RowCnt(Clk25mEn,rst,ColumnCntCo,,RowCntCo);
    
    logic [2:0]EnState;
    logic [9:0]ResizeWrCnt;
    always_ff@(posedge clk)begin
      if(rst)begin OutEn <= 0;EnState <= 0;ImgOut <= 0;ResizWrAddr <= 739;ResizWrEn <= 0;
        ResizWrData <= 0;ResizeWrCnt <= 0;
      end
      else begin
        if(Clk25mEn)begin
          case(EnState)
            0:begin
              if(start)EnState <= 1;
              else begin EnState <= EnState;OutEn <= 0;ResizWrEn <= 0;end
            end
            1:begin
              EnState <= 2;
            end
            2:begin
              OutEn <= 1;
              if(ResizeWrCnt%32 < 3)begin
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
              if(ReadFinish)EnState <= 3;
              else EnState <= EnState;
            end
            3:begin
              ResizWrEn <= 0;
              EnState <= 4;
            end
            4:begin
              EnState <= 0;
              OutEn <= 0;
            end
          endcase
        end
        else begin
          case(EnState)
            0:begin
              if(start)EnState <= 1;
              else begin EnState <= EnState;OutEn <= 0;end
            end
          endcase
          OutEn <= 0;
        end
      end      
    end

endmodule
