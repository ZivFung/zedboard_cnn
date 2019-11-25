`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2018 11:50:38 PM
// Design Name: 
// Module Name: Seg
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


module Seg#(
    parameter INPUT_DW = 10,
    parameter OUTPUT_DW = 8 
    )(
    input wire clk,
    input wire rst,
    input wire [INPUT_DW-1:0]Din,
    input wire Din_en,
    output logic [OUTPUT_DW-1:0]SegOut
    );
    
    always_ff@(posedge clk)begin
      if(rst)SegOut <= SegOut;
      else begin
        if(Din_en)begin
          case(Din)
            10'h1:SegOut <= 8'b0111_1110;
            10'h2:SegOut <= 8'b0011_0000;
            10'h4:SegOut <= 8'b0110_1101;
            10'h8:SegOut <= 8'b0111_1001;
            10'h10:SegOut <= 8'b0011_0011;
            10'h20:SegOut <= 8'b0101_1011;
            10'h40:SegOut <= 8'b0101_1111;
            10'h80:SegOut <= 8'b0111_0000; 
            10'h100:SegOut <= 8'b0111_1111; 
            10'h200:SegOut <= 8'b0111_1011;
            10'h0: SegOut <= 8'b1000_0000;
            default:SegOut <= 8'b1000_0000;
          endcase
        end
      end
    end
endmodule
