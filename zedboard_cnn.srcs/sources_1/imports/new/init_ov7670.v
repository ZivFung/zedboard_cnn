`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2017 07:44:23 PM
// Design Name: 
// Module Name: init_ov7670
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


module init_ov7670#(REG_CNT=123,CFG_FILE="ov7670_RamData.dat")(
    input wire clk,
    //input wire en_100k,
    input wire rst,
    inout wire siod,
    output reg sioc,
    output reg error
    );
    pullup up (siod);
    parameter [7:0]ov7670_id=8'h42;
    
    reg [15:0] OV7670RAMData[0:REG_CNT-1];
    initial $readmemh(CFG_FILE, OV7670RAMData); // Initialize the RAM
    
    reg [15:0]cnt_1k;initial cnt_1k = 0;
    always@(posedge clk)begin
      if(cnt_1k < 500)begin
        cnt_1k <= cnt_1k+1;
      end
      else begin
        cnt_1k <= 0;
      end
    end
    wire en_1k = cnt_1k == 5;
    
    reg [6:0]addr_cnt; initial addr_cnt=0;
    reg addr_valid,addr_ready; initial begin addr_valid=1; addr_ready=0; end
    
    always@(posedge clk)begin
      if(rst) begin
        addr_cnt <= 0;  
      end    
      if(en_1k)
      begin
        if(addr_valid & addr_ready) begin
          addr_cnt <= addr_cnt + 1;
        end
        else 
          addr_cnt <= addr_cnt;
      end       
    end 
    
    always@(posedge clk) if(en_1k) addr_valid <= ( addr_cnt < REG_CNT);
    
    reg [15:0] addr_val; initial addr_val = 0;
    
    always@(posedge clk)begin
      if(en_1k)
        addr_val <= OV7670RAMData[addr_cnt];
    end     
    
    reg [31:0] write_data;initial write_data = 0;   
    reg [0:0]siod_data;initial siod_data=0;
    parameter hafbit_M = 8'd118;
    reg [7:0]send_cnt;initial send_cnt = 0;
    always@(posedge clk)begin
      if(en_1k)
      if(rst)send_cnt <= 0;
      else if(send_cnt < hafbit_M  &  addr_valid)begin
        send_cnt <= send_cnt+1;
      end
      else send_cnt <= 'd0;
    end
    
        //SIOD_EN
    reg [0:0]siod_en;initial siod_en =1 ;
    always @ (posedge clk) 
    case  (send_cnt)
        36,37,38,39,72,73,74,75,108,109,110,111:siod_en <=0 ;
        default siod_en<=1;
    endcase

    
    always@(posedge clk)begin
      if(en_1k)begin 
      if(rst)begin
        write_data <= 32'hFFFFFFFF;
      end
      else begin
        if(addr_valid & send_cnt=='d0)begin
          write_data <= {2'b10,ov7670_id,1'bx,addr_val[15:8],1'bx,addr_val[7:0],1'bx,3'b011};
        end
      end
      
      case(send_cnt)
        0:begin sioc <= 1'b1; siod_data <= write_data[31]; end
        1:begin sioc <= 1'b1;siod_data <= write_data[30];end
        2,6,10,14,18,22,26,30,34,38,42,46,50,54,58,
        62,66,70,74,78,82,86,90,94,98,102,106,110:begin sioc <= 1'b0;  end
        3,7,11,15,19,23,27,31,35,39,43,47,51,55,59,
        63,67,71,75,79,83,87,91,95,99,103,107,111:begin sioc <= 1'b0;siod_data <= write_data[29];end
        4,8,12,16,20,24,28,32,36,40,44,48,52,56,
        60,64,68,72,76,80,84,88,92,96,100,104,108,112:begin sioc <= 1'b1;write_data <= {write_data[30:0],1'b1}; end
        5,9,13,17,21,25,29,33,37,41,45,49,53,57,
        61,65,69,73,77,81,85,89,93,97,101,105,109,113:begin sioc <= 1'b1; end       
        114:begin sioc <= 1'b1; siod_data <= write_data[29]; addr_ready<=1'b1;end
        115:begin sioc <= 1'b1; write_data <= {write_data[30:0],1'b1};addr_ready<=1'b0;end
        116:begin sioc <= 1'b1; siod_data<=write_data[29]; end
        117,118:begin sioc <= 1'b1;end             
      endcase
      end
    end
    assign siod = (siod_en == 1)? siod_data:'BZ;
  
endmodule
