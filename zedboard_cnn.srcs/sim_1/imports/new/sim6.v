`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2017 07:02:29 PM
// Design Name: 
// Module Name: sim6
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


module sim6(

    );
    reg clk;initial clk=0;
    reg rst;initial begin rst =1;#20 rst = 0;  end
    always #5 clk=~clk;
    
    reg clk25m;initial clk25m = 0;
    always #20 clk25m = ~clk25m;
    reg mode;initial begin mode = 0;#200 mode = 1;end
    
    reg [11:0]ram_data_in;initial begin ram_data_in <= 12'hFFF ; end
    wire [18:0]ram_addr_out;
    
    
    
    wire signed[15:0] test;
    assign test = 0.81 *(2**10);
    wire signed[15:0] test1;
    assign test1 = -0.5 *(2**10);
    wire [7:0]led;
    CNN_MODIFY#(12,19)cnn(clk,rst,clk25m,mode,ram_data_in,ram_addr_out,led);
endmodule
