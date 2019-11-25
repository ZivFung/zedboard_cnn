`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2017 06:39:31 PM
// Design Name: 
// Module Name: edge_enhance
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
/*
Gx sobel
-1  -2  -1
 0   0   0
 1   2   1
 
Gy sobel
 -1  0  1
 -2  0  2
 -1  0  1
 */


module edge_enhance_back#(
    PIXEL_NUM = 307200,
    ROW_NUM = 480,
    COLUMN = 640,
    T = 10       
)(
    input  wire clk,
    input  wire mode,          
    output reg  [18:0]ram_wr_addr_process = 0,
    output wire  [11:0]ram_wr_data_process,
    output reg   ram_wr_process = 0,
    
    output reg  [18:0]ram_rd_addr_process = 0,
    input  wire [11:0]ram_rd_data_process

    );
    reg[18:0]pixel_cnt;initial pixel_cnt = 0;
    reg [1:0]mode_capture;initial mode_capture = 0;
    always@(posedge clk)begin
      mode_capture <= {mode_capture[0],mode};
    end
    wire mode_rise = mode_capture == 2'b01;   
    wire pixel_en;
    always@(posedge clk)begin
      if(mode_rise)begin
        pixel_cnt <= 0;
      end
      else if(pixel_en)begin
        if(pixel_cnt < PIXEL_NUM)
          pixel_cnt <= pixel_cnt + 1;
        else
          pixel_cnt <= pixel_cnt;
      end
    end   
    assign pixel_en = (state == 0) & (pixel_cnt < PIXEL_NUM);
    reg [3:0]z[8:0]; initial begin
      z[0] = 0; z[1] = 0;z[2] = 0;z[3] = 0;z[4] = 0;z[5] = 0;z[6] = 0;z[7] = 0;z[8] = 0;
    end
    reg [3:0]state;initial state = 0; 
    reg [4:0]gx_temp1;initial gx_temp1 = 0;
    reg [4:0]gx_temp2;initial gx_temp2 = 0;
    reg [4:0]gx;initial gx = 0;
    reg [4:0]gy_temp1;initial gy_temp1 = 0;
    reg [4:0]gy_temp2;initial gy_temp2 = 0;
    reg [4:0]gy;initial gy = 0;
    always@(posedge clk)begin
      if(mode_rise) state <= 0;
      else
      case(state)
        0:begin
          if(pixel_en)begin
            state <= state + 1;
          end
          else state <= state;
        end
        1:begin
          ram_rd_addr_process <= pixel_cnt - 641;
          state <= state + 1;
        end   
        2:begin
          ram_rd_addr_process <= pixel_cnt - 640;
          state <= state + 1;
        end   
        3:begin
          z[0] <= ram_rd_data_process[3:0];
          ram_rd_addr_process <= pixel_cnt - 639;
          state <= state + 1;
        end
        4:begin
          z[1] <= ram_rd_data_process[3:0];
          ram_rd_addr_process <= pixel_cnt - 1;
          state <= state + 1;
        end
        5:begin
          z[2] <= ram_rd_data_process[3:0];
          ram_rd_addr_process <= pixel_cnt ;
          state <= state + 1;
        end
        6:begin
          z[3] <= ram_rd_data_process[3:0];
          ram_rd_addr_process <= pixel_cnt + 1;
          state <= state + 1;
        end
        7:begin
          z[4] <= ram_rd_data_process[3:0];
          ram_rd_addr_process <= pixel_cnt + 639;
          state <= state + 1;
        end
        8:begin
          z[5] <= ram_rd_data_process[3:0];
          ram_rd_addr_process <= pixel_cnt + 640;
          state <= state + 1;
        end
        9:begin
          z[6] <= ram_rd_data_process[3:0];
          ram_rd_addr_process <= pixel_cnt + 641;
          state <= state + 1;
        end
        10:begin
          z[7] <= ram_rd_data_process[3:0];
          state <= state + 1;
        end
        11:begin
          z[8] <= ram_rd_data_process[3:0];
          state <= state + 1;
        end
        12:begin                            //calculate
          gx_temp1 <= z[2] + (z[5] << 1) + z[8];
          gx_temp2 <= z[0] + (z[3] << 1) + z[6];
          gy_temp1 <= z[0] + (z[1] << 1) + z[2];
          gy_temp2 <= z[6] + (z[7] << 1) + z[8];
          state <= state + 1;
        end
        13:begin
          gx <= (gx_temp1 >= gx_temp2)? gx_temp1 - gx_temp2 : gx_temp2 - gx_temp1;
          gy <= (gy_temp1 >= gy_temp2)? gy_temp1 - gy_temp2 : gy_temp2 - gy_temp1;
          state <= state + 1 ;
        end
        14:begin
          state <= 0;
        end
       
      endcase
    end 
    wire [5:0]sum = gx + gy;
    wire [3:0]gxy = (sum > T)? 15 : 0 ;
    wire wr_en = (state == 14)? 1:0;
    wire rd_en;
    wire [3:0]dout;
    wire full;
    wire prog_full;
    wire empty;
    fifo_generator_0 fifo0
      (
        .clk(clk),
        .srst(mode_rise),
        .din(gxy),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty(empty),
        .prog_full(prog_full)
      );
    reg [9:0]rd_cnt;initial rd_cnt=0;
    reg [2:0]rd_state;initial rd_state = 0;
    reg [18:0]addr_cnt;initial addr_cnt =0 ;
    assign ram_wr_data_process = {dout,dout,dout};
    assign rd_en = (rd_state == 1) & rd_cnt < 640;
    always@(posedge clk)begin
      if(mode_rise)begin
        rd_state <= 0;
        rd_cnt <= 0;
        addr_cnt <= 0;
      end
      else begin
        case(rd_state)
          0:begin
            if(prog_full)begin
              rd_state <= 1;
              rd_cnt <= 0;
            end
          end
          1:begin
            if(rd_cnt < COLUMN )begin
              rd_cnt <= rd_cnt + 1;
              addr_cnt <= addr_cnt + 1;
              ram_wr_process <= 1'b1;
              ram_wr_addr_process <= addr_cnt; 
            end
            else begin
              if(addr_cnt < 305919)begin
                rd_cnt <= rd_cnt;
                ram_wr_process <= 0;
                rd_state <= 0;
              end
              else begin
                if(pixel_cnt > (PIXEL_NUM-1) & ~empty)begin
                  addr_cnt <= addr_cnt + 1;
                  ram_wr_process <= 1'b1;
                  ram_wr_addr_process <= addr_cnt; 
                end
                else begin
                  rd_state <= 0;
                  ram_wr_process <= 1'b0;
                  ram_wr_addr_process <= 0;
                end
              end
            end
          end
        endcase
      end
      end

endmodule  