`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2017 03:40:16 PM
// Design Name: 
// Module Name: vga
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


// 640 X 480 @ 60Hz with a 25.000MHz pixel clock

`define H_ACTIVE		640
`define H_FRONT_PORCH	16
`define H_SYNCH			96
`define H_BACK_PORCH	48
`define H_TOTAL			( `H_SYNCH + `H_BACK_PORCH + `H_ACTIVE + `H_FRONT_PORCH ) 
//640 // pixels

`define V_ACTIVE		480	
`define V_FRONT_PORCH  11
`define V_SYNCH			2
`define V_BACK_PORCH	31	
`define V_TOTAL			 (`V_SYNCH + `V_BACK_PORCH +  `V_ACTIVE +`V_FRONT_PORCH )	
//480 // lines

module vga#(PIXEL_CNT = 307200,
            RAM_ADDR_WIDTH = 19,
            COLOR_OUT_WIDTH = 4,
            RAM_DIN_WIDTH = 12,
            
            V_ACTIVE = 480,
            V_FRONT_PORCH = 11,
            V_SYNCH = 2,
            V_BACK_PORCH = 33,          
            
            H_ACTIVE = 640,
            H_FRONT_PORCH = 16,
            H_SYNCH = 96,
            H_BACK_PORCH = 48
            )
    (
      input  wire clk,                               //25MHz
      input  wire rst, 
      input  wire [RAM_DIN_WIDTH-1:0]ram_data_in,
      output reg [RAM_ADDR_WIDTH-1:0]ram_addr_out,
      output wire [COLOR_OUT_WIDTH-1:0]R,G,B,
      output wire h_synch,v_synch
    );
    parameter V_TOTAL = V_ACTIVE + V_FRONT_PORCH + V_SYNCH + V_BACK_PORCH;
    parameter H_TOTAL = H_ACTIVE + H_FRONT_PORCH + H_SYNCH + H_BACK_PORCH;
    reg [$clog2(V_TOTAL)-1:0]v_cnt;initial v_cnt = 0;
    reg [$clog2(H_TOTAL)-1:0]h_cnt;initial h_cnt = 0;

    assign h_synch = h_cnt < H_SYNCH;
    assign v_synch = v_cnt < V_SYNCH;
    always@(posedge clk)begin
      if(rst)begin
        h_cnt <= 0;
      end
      else begin
        if(h_cnt == H_TOTAL - 1)begin
          h_cnt <= 0;
        end
        else begin
          h_cnt <= h_cnt + 1;
        end
      end
    end
    wire h_cnt_co = h_cnt == H_TOTAL - 1;
    
    always@(posedge clk)begin
      if(rst)begin
        v_cnt <= 0;
      end
      else begin
        if(v_cnt <= V_TOTAL -1)begin
          if(h_cnt_co)begin
            v_cnt <= v_cnt + 1;
          end
          else begin
            v_cnt <= v_cnt;
          end
        end
        else begin
          v_cnt <= 0;
        end
      end
    end
    wire v_cnt_co = v_cnt == V_TOTAL - 1; 
    wire v_active = (h_cnt >= H_SYNCH + H_BACK_PORCH - 1) & (h_cnt < H_SYNCH+H_BACK_PORCH + H_ACTIVE - 1);   // -1
    wire h_active = (v_cnt >= V_SYNCH + V_BACK_PORCH - 1) & (v_cnt < V_SYNCH+V_BACK_PORCH + V_ACTIVE - 1);   //
        
    initial ram_addr_out=0;    
    always@(posedge clk)begin
      if(v_synch)begin
        ram_addr_out <= 0;
      end                //& (v_cnt > V_SYNCH + V_BACK_PORCH - 1) & (v_cnt <= V_SYNCH+V_BACK_PORCH + V_ACTIVE - 1)
      else begin
        if( v_active & h_active )begin
          ram_addr_out <= ram_addr_out + 1;
        end
        else
          ram_addr_out <= ram_addr_out;
      end
    end
    
      assign R = ( v_active & h_active ) ? ram_data_in[11:8] : 4'b0;
      assign G = ( v_active & h_active ) ? ram_data_in[7:4] : 4'b0;
      assign B = ( v_active & h_active ) ? ram_data_in[3:0] : 4'b0;
endmodule
