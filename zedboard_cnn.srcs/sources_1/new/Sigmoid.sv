`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2018 02:06:03 PM
// Design Name: 
// Module Name: Sigmoid
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


module Sigmoid#(
  parameter INPUT_DW = 16,
  parameter INPUT_FW = 10,
  parameter OUTPUT_DW = 16,
  parameter OUTPUT_FW = 10
  )(
    input wire signed[INPUT_DW-1:0]Din,
    input wire Din_en,
    output logic signed[OUTPUT_DW-1:0]Dout,
    output logic Dout_en
    );
    
    localparam COFFE_FW = 10;
    localparam MULDW1 = INPUT_DW + 16;
    localparam MULDW2 = MULDW1 + INPUT_DW;
    
    assign Dout_en = Din_en;    
    
    logic signed[15:0]a,c; //Q6.10
    logic signed[15:0]b; //Q6.10logic signed[15:0]b; //Q6.10
    assign a = (Din < -7728)? 0 :
               (Din >= -7782 & Din < -6687)? 0 :
               (Din >= -6687 & Din < -6144)? 0 :   
               (Din >= -6144 & Din < -5786)? 0 :
               (Din >= -5786 & Din < -5540)? 0 :
               (Din >= -5540 & Din < -5325)? 0 :
               (Din >= -5325 & Din < -5151)? 0 :
               (Din >= -5151 & Din < -5120)? 0 :      
               (Din >= -5120 & Din < -4096)? 6 :
               (Din >= -4096 & Din < -3072)? 14 :       
               (Din >= -3072 & Din < -2048)? 31 :    
               (Din >= -2048 & Din < -1024)? 48 :
               (Din >= -1024 & Din <  1024)? 0 : 
               (Din >=  1024 & Din <  2048)? -49 :
               (Din >=  2048 & Din <  3072)? -31 : 
               (Din >=  3072 & Din <  4096)? -14 : 
               (Din >=  4096 & Din <  5120)? -6 :     
               (Din >=  5120 & Din <  5142)? 0 :      
               (Din >=  5142 & Din <  5314)? 0 :  
               (Din >=  5314 & Din <  5518)? 0 :  
               (Din >=  5518 & Din <  5773)? 0 : 
               (Din >=  5773 & Din <  6113)? 0 :    
               (Din >=  6113 & Din <  6625)? 0 :    
               (Din >=  6625 & Din <  7331)? 0 : 0; 
    assign b = (Din < -7728)? 0 :
               (Din >= -7782 & Din < -6687)? 0 :
               (Din >= -6687 & Din < -6144)? 0 :   
               (Din >= -6144 & Din < -5786)? 0 :
               (Din >= -5786 & Din < -5540)? 0 :
               (Din >= -5540 & Din < -5325)? 0 :
               (Din >= -5325 & Din < -5151)? 0 :
               (Din >= -5151 & Din < -5120)? 0 :      
               (Din >= -5120 & Din < -4096)? 61 :
               (Din >= -4096 & Din < -3072)? 127 :       
               (Din >= -3072 & Din < -2048)? 225 :    
               (Din >= -2048 & Din < -1024)? 297 :
               (Din >= -1024 & Din <  1024)? 244 : 
               (Din >=  1024 & Din <  2048)? 297 :
               (Din >=  2048 & Din <  3072)? 255 : 
               (Din >=  3072 & Din <  4096)? 127 : 
               (Din >=  4096 & Din <  5120)? 61 :     
               (Din >=  5120 & Din <  5142)? 0 :      
               (Din >=  5142 & Din <  5314)? 0 :  
               (Din >=  5314 & Din <  5518)? 0 :  
               (Din >=  5518 & Din <  5773)? 0 : 
               (Din >=  5773 & Din <  6113)? 0 :    
               (Din >=  6113 & Din <  6625)? 0 :    
               (Din >=  6625 & Din <  7331)? 0 : 0; 

    assign c = (Din < -7728)? 0 :
               (Din >= -7782 & Din < -6687)? 1 :
               (Din >= -6687 & Din < -6144)? 2 :   
               (Din >= -6144 & Din < -5786)? 3 :
               (Din >= -5786 & Din < -5540)? 4 :
               (Din >= -5540 & Din < -5325)? 5 :
               (Din >= -5325 & Din < -5151)? 6 :
               (Din >= -5151 & Din < -5120)? 7 :      
               (Din >= -5120 & Din < -4096)? 174 :
               (Din >= -4096 & Din < -3072)? 304 :       
               (Din >= -3072 & Din < -2048)? 451 :    
               (Din >= -2048 & Din < -1024)? 524 :
               (Din >= -1024 & Din <  1024)? 512 : 
               (Din >=  1024 & Din <  2048)? 500 :
               (Din >=  2048 & Din <  3072)? 573 : 
               (Din >=  3072 & Din <  4096)? 720 : 
               (Din >=  4096 & Din <  5120)? 850 :     
               (Din >=  5120 & Din <  5142)? 1017 :      
               (Din >=  5142 & Din <  5314)? 1018 :  
               (Din >=  5314 & Din <  5518)? 1019 :  
               (Din >=  5518 & Din <  5773)? 1020 : 
               (Din >=  5773 & Din <  6113)? 1021 :    
               (Din >=  6113 & Din <  6625)? 1022 :    
               (Din >=  6625 & Din <  7331)? 1023 : 1024;                                      
    logic signed [OUTPUT_DW-1:0]output_mul1Temp;
    logic signed [OUTPUT_DW-1:0]output_mul1;
    logic signed [OUTPUT_DW-1: 0]output_mul2;
    logic signed [OUTPUT_DW-1:0]output_mul3; 
    
//    assign output_mul1 = MULDW2'(a*Din*Din) >>> (INPUT_FW + INPUT_FW +COFFE_FW - OUTPUT_FW);
    assign output_mul1Temp = MULDW1'(a*Din) >>> (COFFE_FW);
    assign output_mul1 = MULDW2'(output_mul1Temp*Din) >>> (INPUT_FW + INPUT_FW - OUTPUT_FW);
    assign output_mul2 = (b*Din) >>> (INPUT_FW + COFFE_FW - OUTPUT_FW );
    assign output_mul3 = c >>> (COFFE_FW - OUTPUT_FW);
    assign Dout = output_mul1 + output_mul2 + output_mul3;
endmodule
