`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2018 07:27:01 PM
// Design Name: 
// Module Name: MaxPool
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

module Counter #(
    parameter M = 100
)(
    input wire clk, rst, en,
    output logic [$clog2(M) - 1 : 0] cnt,
    output logic co
);
    assign co = en & (cnt == M - 1);
    always_ff@(posedge clk or posedge rst) begin
        if(rst) cnt <= '0;
        else if(en) begin
            if(cnt < M - 1) cnt <= cnt + 1'b1;
            else cnt <= '0;
        end
    end
endmodule
module Campare#(                                   //Return the lager data;
    parameter DATA_WIDTH = 16
)(
    input wire signed[DATA_WIDTH-1:0]InputData1,
    input wire signed[DATA_WIDTH-1:0]InputData2,
    output logic signed[DATA_WIDTH-1:0]OutputData
);
    assign OutputData = (InputData1 >= InputData2)? InputData1 : InputData2;
endmodule

module MaxPool#(
    parameter SIDE_LENGTH = 2,
    parameter STRIDE =2,
    parameter DATA_ROW = 28,
    parameter DATA_COLUMN = 28,
    parameter DATA_WIDTH = 16,
    parameter DATA_FW = 10
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed[DATA_WIDTH - 1 : 0]Din,
    input wire Din_en,
    output logic signed[DATA_WIDTH - 1 : 0]Dout,
    output logic Dout_en,
    output logic DoutStart,
    output logic Finish
    );
    localparam ColumnNum = DATA_COLUMN;
    localparam RowNUm = SIDE_LENGTH;
    localparam PixelNum = DATA_ROW * DATA_COLUMN;
    localparam FifoLength = ColumnNum + SIDE_LENGTH;
    
    assign DoutStart = start;
    logic [1:0]MaxPoolState;
    
    always_ff@(posedge clk)begin
      if(rst)begin MaxPoolState <= 0;Finish <= 0;end
      else begin
        case(MaxPoolState)
          0:begin
            Finish <= 0;
            if(start)MaxPoolState <= 1;
            else MaxPoolState <= 0;
          end
          1:begin
            if(ENState == 3)MaxPoolState <= 2;
            else MaxPoolState <= MaxPoolState;
          end
          2:begin
            MaxPoolState <=0;
            Finish <= 1;
          end
        endcase
      end
    end
    
    logic signed[DATA_WIDTH-1 : 0]Fifo[FifoLength];
    logic ReadEn;
    generate 
      for(genvar k = 0; k < FifoLength; k++)begin : FifoPineLine
        if(k > 0)
        always_ff@(posedge clk)begin
          if(rst) begin Fifo[k] <= (DATA_WIDTH)'(0);end
          else begin
            case(MaxPoolState)
              1:begin if(Din_en)
                Fifo[k] <= Fifo[k-1];
              end
            endcase
          end
        end
        
        else
        always_ff@(posedge clk)begin
          if(rst) begin Fifo[k] <= (DATA_WIDTH)'(0);ReadEn <= 0;end
          else begin
            case(MaxPoolState)
              1:begin 
                if(Din_en)begin
                  Fifo[k] <= Din;
                  ReadEn <= 1;
                end
                else ReadEn <= 0;
              end
            endcase
          end
        end
      end
    endgenerate
    
    logic signed[DATA_WIDTH-1 : 0]RowCompare[SIDE_LENGTH*SIDE_LENGTH];
    logic signed[DATA_WIDTH-1 : 0]ColumnCompare[SIDE_LENGTH];
    logic signed[DATA_WIDTH-1 : 0]ColumnCompareCmp[SIDE_LENGTH];
    
    generate
      for(genvar i = 0 ; i < SIDE_LENGTH ; i++)begin : RowCompareColumnCnt
        assign RowCompare[i*SIDE_LENGTH] = Fifo[i]; 
        for(genvar k = 0 ; k < SIDE_LENGTH - 1 ; k++)begin : RowsCompares
          Campare#(DATA_WIDTH)
          theRowCompare(RowCompare[i*SIDE_LENGTH+k],Fifo[ColumnNum*(k+1)+i],RowCompare[i*SIDE_LENGTH+k+1]);
        end
        assign ColumnCompare[i] = RowCompare[i*SIDE_LENGTH+SIDE_LENGTH-1];
      end
    endgenerate

    assign ColumnCompareCmp[0] = ColumnCompare[0];
    generate
      for(genvar k = 0 ; k < SIDE_LENGTH - 1; k++)begin : ColumnCompares
        Campare#(DATA_WIDTH)
        theRowCompare(ColumnCompareCmp[k],ColumnCompare[k+1],ColumnCompareCmp[k+1]);
      end
    endgenerate
    
    logic signed[DATA_WIDTH-1 : 0]CompareWindow;
    assign CompareWindow = ColumnCompareCmp[SIDE_LENGTH-1];
    
    logic ColumnCo,RowCo,PixelCo,WindowCo;
    Counter#(STRIDE)PoolWindowCnt(clk,rst,ReadEn,,WindowCo);
    Counter#(ColumnNum)ColumnCnt(clk,rst,ReadEn,,ColumnCo);
    Counter#(RowNUm)RowCnt(clk,rst,ColumnCo,,RowCo);
    Counter#(DATA_ROW)PixelCnt(clk,rst,ColumnCo,,PixelCo);
    
    logic [2:0]ENState;
    always_ff@(posedge clk)begin
      if(rst)begin ENState <= 0; Dout_en <= 0; Dout <= 0;end
      else begin
        case(ENState)
          0:begin
            if(start)ENState <= 1;
            else ENState <= ENState;
          end
          1:begin
            if(ColumnCo)begin Dout_en <= 0; ENState <= 2;end
            else begin ENState <= ENState;Dout_en <= 0;end
          end
          2:begin
            if(PixelCo)begin Dout_en <= 1;Dout <= CompareWindow;ENState <= 3; end
            else if(RowCo)begin Dout_en <= 1;Dout <= CompareWindow;ENState <= 1; end
            else if(WindowCo)begin Dout_en <= 1;Dout <= CompareWindow;end
            else begin ENState <= ENState; Dout_en <= 0;end
          end
          3:begin
            Dout <= 0;
            ENState <= 0;
            Dout_en <= 0;
          end
        endcase
      end
    end
    
endmodule
