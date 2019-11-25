`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2017 08:39:14 PM
// Design Name: 
// Module Name: mac
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


module mac#(
   NODE_NUM = 400,
   INPUT_DATA_WIDTH = 4,
   INPUT_ADDR_WIDTH = 9,
   WEIGHT_DATA_WIDTH = 16,
   WEIGHT_ADDR_WIDTH = 9,
   OUTPUT_DATA_WIDTH = 16
 )(
   input wire clk,
   input wire rst,
   input wire start,
   input wire signed[WEIGHT_DATA_WIDTH - 1:0]weight,
   output reg [WEIGHT_ADDR_WIDTH - 1:0]weight_addr,
   input wire [INPUT_DATA_WIDTH - 1:0]input_data,
   input wire input_data_en,
   output wire signed[OUTPUT_DATA_WIDTH - 1: 0]sum_data,
   output wire output_en 
   );
   
   reg [WEIGHT_DATA_WIDTH + INPUT_DATA_WIDTH - 1:0]sum;initial sum = 0;
   reg [$clog2(NODE_NUM) - 1: 0]add_cnt;initial add_cnt = 0;
   reg start_reg;initial start_reg = 0;
   always@(posedge clk)begin
     if(start)begin
       start_reg <= 1;
     end
     else if(rst)
       start_reg <= 0;
     else 
       start_reg <= start_reg;
   end
   
   assign add_finish = add_cnt == NODE_NUM - 1;
   
   always@(posedge clk)begin        //mac
     if(rst)begin
       sum <= 0;
       add_cnt <= 0;
       weight_addr <= 0;
     end
     else begin
       if(start)begin
         if(input_data_en)
           sum <= sum + input_data * weight;
           add_cnt <= add_cnt + 1;
           weight_addr <= weight_addr + 1;
       end
       else begin
         sum <= sum;
       end
     end
   end
   
   
   
endmodule
