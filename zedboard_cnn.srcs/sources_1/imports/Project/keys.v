`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2015 03:18:45 PM
// Design Name: 
// Module Name: keys
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

module keysprocess
#(
    parameter W = 1
)(
    input clk,
    input [W - 1 : 0] keyin,
    output [W - 1 : 0] keyout
);
    reg [19 : 0] cnt10ms; initial cnt10ms = 0;
    always@(posedge clk)
    begin
        if(cnt10ms < 20'd249999)
            cnt10ms <= cnt10ms + 20'b1;
        else
            cnt10ms <= 20'b0;
    end
    
    reg [W - 1 : 0] keysmp; initial keysmp = 0;
    always@(posedge clk)
    begin
        if(cnt10ms == 20'd249999)
            keysmp <= keyin;
    end
    
    reg [W - 1 : 0] keydly; initial keydly = 0;
    always@(posedge clk)
    begin
        keydly <= keysmp;
    end
    
    assign keyout = keysmp & ~keydly;

endmodule
