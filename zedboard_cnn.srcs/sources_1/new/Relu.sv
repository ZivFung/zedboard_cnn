`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2018 01:23:41 PM
// Design Name: 
// Module Name: Relu
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


module Relu#(
  parameter INPUT_DW = 16,
  parameter OUTPUT_DW = 16
  )(
  input  wire signed[INPUT_DW-1 : 0]Din,
  input  wire Din_en,
  output logic signed[OUTPUT_DW-1 : 0]Dout,
  output logic Dout_en
    );
  assign Dout = (Din_en)? (Din >= 0)? Din :0 :0;
  assign Dout_en = Din_en ;
endmodule
