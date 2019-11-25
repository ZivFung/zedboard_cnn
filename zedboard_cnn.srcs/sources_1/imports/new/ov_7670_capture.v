`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2017 12:29:00 AM
// Design Name: 
// Module Name: ov_7670_capture
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


module ov_7670_capture(
        input wire clk,rst,
        input wire ov7670_pclk,
        input wire ov7670_href,ov7670_vsync,
        input wire [7:0] ov7670_din ,
        input wire mode,
        output wire [11:0] buff_dout,
        output wire  buff_wr,
        output reg [18:0] buff_addr = 0 
    );
    
    reg [1:0] pclk_capture;initial pclk_capture=0;
    always@(posedge clk)begin
      pclk_capture <= {pclk_capture[0],ov7670_pclk};
    end
    wire pclk_rise = pclk_capture==2'b01;
    wire pclk_fall = pclk_capture==2'b10;
     
    wire frame_data_valid = ~ov7670_vsync;
    wire row_data_valid = ov7670_href;
    reg pixel_data_valid;initial pixel_data_valid=0;
    always@(posedge clk)begin
      if(frame_data_valid & row_data_valid)begin
        if(pclk_rise)begin
          pixel_data_valid <= ~pixel_data_valid;
        end
        else begin
          pixel_data_valid <= pixel_data_valid;
        end
      end 
     else begin
       pixel_data_valid <= 0;
     end 
    end
    
    reg[15:0] rgb565_data;initial rgb565_data=16'b0;
    always@(posedge clk)begin
      if(frame_data_valid & row_data_valid)begin
        if(pclk_rise)begin
          rgb565_data <= {rgb565_data[7:0],ov7670_din};
        end
        else begin
          rgb565_data <= rgb565_data;
        end
      end
      else begin 
        rgb565_data <= 16'b0;
      end
    end
//    wire [13:0]gray_buf = (rgb565_data[15:11] * 8'd76 + rgb565_data[10:5] * 8'd150 + rgb565_data[4:0] * 8'd30) ;
//    wire [5:0]gray = gray_buf >> 8;
//    wire [3:0]gray_dis = gray[5:2];
//    wire [11:0]buff_data = {gray_dis,gray_dis,gray_dis};
   
    wire [11:0]RGBProcessData = (rgb565_data[15:12] > 4'd4)?(rgb565_data[10:7] > 4'd4)?(rgb565_data[4:1] > 4'd4)? 12'HFFF:0:0:0;
    assign buff_dout = (mode)?{rgb565_data[15:12],rgb565_data[10:7],rgb565_data[4:1]} : RGBProcessData;
    assign buff_wr = (frame_data_valid & row_data_valid)? ~pixel_data_valid : 0;
    always@(posedge clk)begin
      if(pclk_rise)begin
        if(~frame_data_valid | rst)begin
          buff_addr<=0;
        end
        else begin
          if(buff_wr)buff_addr <= buff_addr+1;
        end
      end
    end
    
endmodule
