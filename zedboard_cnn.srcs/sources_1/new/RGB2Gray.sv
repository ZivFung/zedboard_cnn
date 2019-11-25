`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2018 03:55:04 PM
// Design Name: 
// Module Name: RGB2Gray
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


module RGB2Gray#(
    parameter R_DW = 5,
    parameter G_DW = 6,
    parameter B_DW = 5,
    parameter GRAY_DW = 8,
    parameter SCALE_W = 2 
    )(
    input wire InputEn,
    input wire [R_DW-1:0]R,
    input wire [G_DW-1:0]G,
    input wire [B_DW-1:0]B,
    output logic OutputEn,
    output logic [GRAY_DW-1:0]Gray
    );
    logic [GRAY_DW-1:0]R_Buffer;
    logic [GRAY_DW-1:0]G_Buffer;
    logic [GRAY_DW-1:0]B_Buffer;
    
    assign R_Buffer = (GRAY_DW + R_DW)'(R * 8'd76) >> (8 - SCALE_W);
    assign G_Buffer = (GRAY_DW + G_DW)'(G * 8'd150) >> (8 - SCALE_W);
    assign B_Buffer = (GRAY_DW + B_DW)'(B * 8'd30) >> (8 - SCALE_W);
    
    assign Gray = R_Buffer + G_Buffer + B_Buffer;
    assign OutputEn = InputEn;
endmodule
