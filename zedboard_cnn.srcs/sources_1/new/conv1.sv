`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2018 12:52:46 PM
// Design Name: 
// Module Name: conv1
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


module conv1#(
    COV_CORE_ROW = 5,
    INPUT_DATA_WIDTH = 2,
    INPUT_DATA_FW = 0,
    INPUT_DATA_ROW = 32,
    INPUT_DATA_NUM = 1024,
    COV_CORE_WIDTH = 16,   //    Q6.10
    COV_CORE_FW = 10,
    COV_CORE_ADDR_WIDTH = 5,
    OUTPUT_DATA_WIDTH = 16,
    OUTPUT_DATA_FW = 10
    
)   (
    input wire clk,
    input wire rst,
    input wire start,
    output logic trans_start,
    input wire signed[INPUT_DATA_WIDTH - 1:0]z_in0,
    input wire signed[INPUT_DATA_WIDTH - 1:0]z_in1,
    input wire signed[INPUT_DATA_WIDTH - 1:0]z_in2,
    input wire signed[INPUT_DATA_WIDTH - 1:0]z_in3,
    input wire signed[INPUT_DATA_WIDTH - 1:0]z_in4,
    
    input wire signed[COV_CORE_WIDTH - 1:0]cov_core_data,
    output logic [COV_CORE_ADDR_WIDTH - 1:0]cov_core_addr = 0,
    output logic output_data_valid = 0,
    output logic signed[OUTPUT_DATA_WIDTH - 1:0]output_data,
    output logic cov_finish
    );
    reg signed [COV_CORE_WIDTH - 1:0]w[COV_CORE_ROW * COV_CORE_ROW - 1: 0];
    logic [4:0]state;
    
    always_ff@(posedge clk)begin
      if(rst) state <= 0;
      else
      case(state)
        0:begin
          if(start)begin
            state <= state + 1;
          end
          else state <= state;
        end
        1:begin
          cov_core_addr <= 0;
          state <= state + 1;
        end   
        2:begin
          cov_core_addr <= 1;
          state <= state + 1;
        end
        3:begin
            cov_core_addr <= 2;
            state <= state + 1; 
        end   
        4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26:begin
          w[state - 4] <= cov_core_data;
          cov_core_addr <= state - 1;
          state <= state + 1;
        end
        27:begin
          w[23] <= cov_core_data;
          state <= state + 1;
        end
        28:begin
          w[24] <= cov_core_data;
          state <= state + 1; 
        end
        29:begin
          state <= 0;
        end       
      endcase
    end    
    logic signed [INPUT_DATA_WIDTH - 1 :0]z[COV_CORE_ROW * COV_CORE_ROW - 1:0];         
    logic signed [OUTPUT_DATA_WIDTH - 1:0]AddrRow[COV_CORE_ROW-1:0]; 
    logic signed [OUTPUT_DATA_WIDTH - 1:0]mul[COV_CORE_ROW*COV_CORE_ROW-1:0];
    logic signed [OUTPUT_DATA_WIDTH - 1:0]paralleladd;
    
    generate 
      for(genvar k = 0; k < COV_CORE_ROW; k++)begin:MulRow1
        assign mul[k] = z[k] * w[COV_CORE_ROW - k -1];
      end
    endgenerate  
    generate 
      for(genvar k = 5; k < 2 * COV_CORE_ROW; k++)begin:MulRow2
        assign mul[k] = z[k] * w[3*COV_CORE_ROW - k -1];
      end
    endgenerate 
    generate 
      for(genvar k = 10; k < 3 * COV_CORE_ROW; k++)begin:MulRow3
        assign mul[k] = z[k] * w[5*COV_CORE_ROW - k -1];
      end
    endgenerate 
    generate 
      for(genvar k = 15; k < 4 * COV_CORE_ROW; k++)begin:MulRow4
        assign mul[k] = z[k] * w[7*COV_CORE_ROW - k -1];
      end
    endgenerate 
    generate 
      for(genvar k = 20; k < 5 * COV_CORE_ROW; k++)begin:MulRow5
        assign mul[k] = z[k] * w[9*COV_CORE_ROW - k -1];
      end
    endgenerate 
    generate 
      for(genvar k = 0; k < COV_CORE_ROW; k++)begin:AddrRows
        assign AddrRow[k] =mul[k * COV_CORE_ROW] + mul[k * COV_CORE_ROW+1] + mul[k * COV_CORE_ROW+2] +
                           mul[k * COV_CORE_ROW+3] + mul[k * COV_CORE_ROW+4];
      end
    endgenerate 
    assign paralleladd = AddrRow[0] + AddrRow[1] + AddrRow[2] + AddrRow[3] + AddrRow[4];
    assign trans_start = state == 28;
    logic [$clog2(INPUT_DATA_NUM) : 0]add_cnt;
    always_ff@(posedge clk)begin                      
      if(rst)begin
        add_cnt <= 0;
        z[0] <= 0;
        z[1] <= 0;
        z[2] <= 0;
        z[3] <= 0;
        z[4] <= 0;
        z[5] <= 0;
        z[6] <= 0;
        z[7] <= 0;
        z[8] <= 0;
        z[9] <= 0;
        z[10] <= 0;
        z[11] <= 0;
        z[12] <= 0;
        z[13] <= 0;
        z[14] <= 0;
        z[15] <= 0;
        z[16] <= 0;
        z[17] <= 0;
        z[18] <= 0;
        z[19] <= 0;
        z[20] <= 0;
        z[21] <= 0;
        z[22] <= 0;
        z[23] <= 0;
        z[24] <= 0;
        end
      else begin
        if(state == 28)add_cnt <= 1;
        else if(add_cnt > 0 & add_cnt < INPUT_DATA_ROW * (INPUT_DATA_ROW - COV_CORE_ROW + 1) + 1)begin      //less a top
          z[4] <= z[3];z[9] <= z[8];z[14] <= z[13];z[19] <= z[18];z[24] <= z[23];
          z[3] <= z[2];z[8] <= z[7];z[13] <= z[12];z[18] <= z[17];z[23] <= z[22];
          z[2] <= z[1];z[7] <= z[6];z[12] <= z[11];z[17] <= z[16];z[22] <= z[21]; 
          z[1] <= z[0];z[6] <= z[5];z[11] <= z[10];z[16] <= z[15];z[21] <= z[20];
          z[0] <= z_in0;z[5] <= z_in1;z[10] <= z_in2;z[15] <= z_in3;z[20] <= z_in4;
          add_cnt <= add_cnt + 1;    
        end
        else begin
          add_cnt <= 0;
        end
      end        
    end
    
    logic signed [OUTPUT_DATA_WIDTH - 1:0]cov_output;
//    logic signed [COV_CORE_WIDTH + INPUT_DATA_WIDTH - 1:0]cov_output_process;
    always_ff@(posedge clk)begin
      if(rst)cov_output <= 0;
      else if(add_cnt > COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW + 1)begin
//        cov_output[add_cnt - 5] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 2 + 1)begin
//        cov_output[add_cnt - 9] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 2 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 3 + 1)begin
//        cov_output[add_cnt - 13] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 3 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 4 + 1)begin
//        cov_output[add_cnt - 17] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 4 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 5 + 1)begin
//        cov_output[add_cnt - 21] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 5 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 6 + 1)begin
//        cov_output[add_cnt - 25] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 6 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 7 + 1)begin
//        cov_output[add_cnt - 29] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 7 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 8 + 1)begin
//        cov_output[add_cnt - 33] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 8 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 9 + 1)begin
//        cov_output[add_cnt - 37] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 9 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 10 + 1)begin
//        cov_output[add_cnt - 41] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 10 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 11 + 1)begin
//        cov_output[add_cnt - 45] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 11 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 12 + 1)begin
//        cov_output[add_cnt - 49] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 12 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 13 + 1)begin
//        cov_output[add_cnt - 53] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 13 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 14 + 1)begin
//        cov_output[add_cnt - 57] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 14 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 15 + 1)begin
//        cov_output[add_cnt - 61] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 15 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 16 + 1)begin
        cov_output[add_cnt - 65] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 16 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 17 + 1)begin
//        cov_output[add_cnt - 69] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 17 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 18 + 1)begin
//        cov_output[add_cnt - 73] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 18 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 19 + 1)begin
//        cov_output[add_cnt - 77] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 19 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 20 + 1)begin
//        cov_output[add_cnt - 81] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 20 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 21 + 1)begin
//        cov_output[add_cnt - 85] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 21 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 22 + 1)begin
//        cov_output[add_cnt - 89] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 22 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 23 + 1)begin
//        cov_output[add_cnt - 93] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 23 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 24 + 1)begin
//        cov_output[add_cnt - 97] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 24 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 25 + 1)begin
//        cov_output[add_cnt - 101] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 25 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 26 + 1)begin
//        cov_output[add_cnt - 105] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 26 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 27 + 1)begin
//        cov_output[add_cnt - 109] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else if(add_cnt > INPUT_DATA_ROW * 27 + COV_CORE_ROW & add_cnt <= INPUT_DATA_ROW * 28 + 1)begin
//        cov_output[add_cnt - 113] <= paralleladd;
        cov_output <= paralleladd;
        output_data_valid <= 1;
      end
      else 
        output_data_valid <= 0;
    end
    
    assign cov_finish = add_cnt == INPUT_DATA_ROW * (INPUT_DATA_ROW - COV_CORE_ROW + 1) + 1;
    assign output_data = cov_output;
endmodule
