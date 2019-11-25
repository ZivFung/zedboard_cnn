`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2018 06:41:17 PM
// Design Name: 
// Module Name: CnnTest
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


module CnnTest#(
  INPUT_DATA_WIDTH = 12,
  RAM_ADDR_WIDTH = 19
  
)(
    input wire clk,
    input wire rst,
    input wire clk25m,
    input wire mode,
    input wire [INPUT_DATA_WIDTH-1:0]ram_data_in,
    output reg [RAM_ADDR_WIDTH-1:0]ram_addr_out = 0,
    output wire [3:0]led
    );
    reg [1:0]mode_capture;initial mode_capture = 0;
    always@(posedge clk)begin
      mode_capture <= {mode_capture[0],mode};
    end
    wire mode_rise = mode_capture == 2'b01;   
    
    reg [1:0]clk25m_capture;initial clk25m_capture = 0;
    always@(posedge clk)begin
      clk25m_capture <= {clk25m_capture[0],clk25m};
    end
    wire clk25m_en = clk25m_capture == 2'b01;   
    reg [15:0]Zreg[1023:0];initial $readmemh("eight1_32x32.dat", Zreg);
    reg [0:0]z_in[1023:0];
    reg [11:0]rd_data_cnt;initial rd_data_cnt = 0;
    reg [2:0]rd_state;initial rd_state = 0;
    
    parameter IDLE = 0;
    parameter START = 1;
    parameter POOLING1 = 2;
    parameter COV1_1 = 3;
    parameter POOLING1_1 = 4;
    parameter COV2_1 = 5;
    parameter POOLING2_1 = 6;
    parameter FULLCONNECT1 = 7;
    parameter CNN_FINISH = 8;
    (*mark_debug = "true"*)reg [3:0]cnn_state;initial cnn_state = START;
    //(*mark_debug = "true"*)reg [8:0]cnn_cnt;initial cnn_cnt = 0;
    reg [19:0]ram_start_addr;initial ram_start_addr = 0;
    reg [0:0]rd_data_start;initial rd_data_start = 0;
    
        
    always@(posedge clk)begin                   //cnn_state switch
      if(rst)cnn_state <= START;
      else begin
        case(cnn_state)
//          IDLE:begin
//            if(mode_rise)cnn_state <= START;
//            else cnn_state <= IDLE;
//          end
          START:begin
            if(ZRdCnt == 1024)
            cnn_state <= COV1_1;
          else
            cnn_state <= cnn_state;
          end
          COV1_1:begin
            if(cov1_1_finish)
              cnn_state <= POOLING1_1;
            else 
              cnn_state <= cnn_state;
          end
          POOLING1_1:begin
            if(pooling1_1_finish)
              cnn_state <= POOLING2_1;
            else 
              cnn_state <= cnn_state;
          end
          POOLING2_1:begin
            if(pooling2_1_finish)
              cnn_state <= CNN_FINISH;
            else 
              cnn_state <= cnn_state;
          end
//          FULLCONNECT1:begin
//            if(full_connect1_output_en)
//              cnn_state <= CNN_FINISH;
//            else 
//              cnn_state <= cnn_state;
//          end 
          CNN_FINISH:begin
            cnn_state <= cnn_state;
          end  
        endcase
      end
    end

    reg [10:0]ZRdCnt;initial ZRdCnt = 0;
    always@(posedge clk)begin
    if(rst | mode_rise)ZRdCnt <= 0;
    else begin
      if(ZRdCnt < 1024 & cnn_state == START)begin
        z_in[ZRdCnt] <= Zreg[ZRdCnt]>0 ? 1:0;
        ZRdCnt <= ZRdCnt + 1;
      end
      else if(ZRdCnt == 1024)ZRdCnt <= 0;
      else begin 
        ZRdCnt <= ZRdCnt;
      end
    end
    end
    
    
    reg [1:0]cov1_1_z_in0,cov1_1_z_in1,cov1_1_z_in2,cov1_1_z_in3,cov1_1_z_in4;
    initial begin cov1_1_z_in0 = 0 ;cov1_1_z_in1 = 0;cov1_1_z_in2 = 0;cov1_1_z_in3 = 0; cov1_1_z_in4 = 0;end
    reg [15:0]cov1_1_trans_cnt;initial cov1_1_trans_cnt = 0;
    reg [1:0]cov1_1_trans_state;initial cov1_1_trans_state = 0;
    always@(posedge clk)begin
      case(cov1_1_trans_state)
        0:begin
          if(ZRdCnt == 1024)begin
            cov1_1_trans_state <= 1;
          end
          else
            cov1_1_trans_state <= 0;
        end
        1:begin
          if(cov1_1_trans_start)begin
            cov1_1_z_in0 <= {1'b0,z_in[cov1_1_trans_cnt]};
            cov1_1_z_in1 <= {1'b0,z_in[cov1_1_trans_cnt+32]};
            cov1_1_z_in2 <= {1'b0,z_in[cov1_1_trans_cnt+64]};
            cov1_1_z_in3 <= {1'b0,z_in[cov1_1_trans_cnt+96]};
            cov1_1_z_in4 <= {1'b0,z_in[cov1_1_trans_cnt+128]};
            cov1_1_trans_cnt <= cov1_1_trans_cnt + 1;
            cov1_1_trans_state <= 2;
          end
          else 
            cov1_1_trans_state <= cov1_1_trans_state;
        end
        2:begin
          if(cov1_1_trans_cnt < 896)begin
            cov1_1_z_in0 <= {1'b0,z_in[cov1_1_trans_cnt]};
            cov1_1_z_in1 <= {1'b0,z_in[cov1_1_trans_cnt+32]};
            cov1_1_z_in2 <= {1'b0,z_in[cov1_1_trans_cnt+64]};
            cov1_1_z_in3 <= {1'b0,z_in[cov1_1_trans_cnt+96]};
            cov1_1_z_in4 <= {1'b0,z_in[cov1_1_trans_cnt+128]};
            cov1_1_trans_cnt <= cov1_1_trans_cnt + 1;
            end 
          else begin
            cov1_1_trans_state <= 3;
          end
        end
        3:begin
          cov1_1_trans_state <= 0;
          cov1_1_trans_cnt <= 0;
        end
      endcase
    end
    
    wire cov1_1_trans_start;
    wire cov1_1_start = ZRdCnt == 1024;
    
    wire [4:0] cov1_1_core_addr;
    wire signed[15:0] cov1_1_core_data;
    wire [0:0]cov1_1_output_data_valid;
    wire signed[15:0]cov1_1_output_data;
    
    blk_mem_gen_1 w_cov1_1_rom
      (
        .clka(clk),
        .ena(1),
        .addra(cov1_1_core_addr),
        .douta(cov1_1_core_data)
      );
   // assign trans_start = trans_state ==3;
   (*mark_debug = "true"*)wire cov1_1_finish;
    conv1#(.COV_CORE_ROW(5),.INPUT_DATA_WIDTH(2),.INPUT_DATA_FW(0),.INPUT_DATA_ROW(32),.INPUT_DATA_NUM(1024),.COV_CORE_WIDTH(16),
        .COV_CORE_FW(10),.COV_CORE_ADDR_WIDTH(5),.OUTPUT_DATA_WIDTH(16),.OUTPUT_DATA_FW(10))cov_1_1
        (.clk(clk),
         .rst(rst | mode_rise),
         .start(cov1_1_start),
         .z_in0(cov1_1_z_in0),
         .z_in1(cov1_1_z_in1),
         .z_in2(cov1_1_z_in2),
         .z_in3(cov1_1_z_in3),
         .z_in4(cov1_1_z_in4),
         .trans_start(cov1_1_trans_start),
         .cov_core_data(cov1_1_core_data),
         .cov_core_addr(cov1_1_core_addr),
         .output_data_valid(cov1_1_output_data_valid),
         .output_data(cov1_1_output_data),
         .cov_finish(cov1_1_finish)
        );
  
    wire [15:0]cov1_1_relu_output_data;
    wire cov1_1_relu_output_data_valid;
    
//    sigmoid#(.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.NONCONSTANT_INPUT_DATA_FW(10),.OUTPUT_DATA_WIDTH(16),.OUTPUT_DATA_FW(10))
//    cov1_1_sig(clk,cov1_1_output_data,cov1_1_output_data_valid,cov1_1_sigmoid_output_data,cov1_1_sigmoid_output_data_valid);    
    Relu#(.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.OUTPUT_DATA_WIDTH(16),.OUTPUT_DATA_FW(10)
    )relu_1_1(.clk(clk),.input_data(cov1_1_output_data),.input_data_en(cov1_1_output_data_valid),.output_data(cov1_1_relu_output_data),.output_data_valid(cov1_1_relu_output_data_valid));
    wire [15:0]pooling1_1_output_data;
    wire pooling1_1_output_data_en;
    wire pooling1_1_finish;
    MaxPool#(.SIDE_LENGTH(2),.STRIDE(2),.DATA_ROW(28),.DATA_COLUMN(28),.DATA_WIDTH(16),.DATA_FW(10))pooling1_1
    (clk,rst | mode_rise,cov1_1_trans_start,cov1_1_relu_output_data,cov1_1_relu_output_data_valid,pooling1_1_output_data,pooling1_1_output_data_en,pooling1_1_finish);
    
   
     /************************cov1_2*******************************/
    wire cov1_2_trans_start;
    wire cov1_2_start = ZRdCnt == 1024;
      
    wire [4:0] cov1_2_core_addr;
    wire signed[15:0] cov1_2_core_data;
    wire [0:0]cov1_2_output_data_valid;
    wire signed[15:0]cov1_2_output_data;
      
    blk_mem_gen_2 w_cov1_2_rom
      (
        .clka(clk),
        .ena(1),
        .addra(cov1_2_core_addr),
        .douta(cov1_2_core_data)
      );
  
    wire cov1_2_finish;
    conv1#(.COV_CORE_ROW(5),.INPUT_DATA_WIDTH(2),.INPUT_DATA_FW(0),.INPUT_DATA_ROW(32),.INPUT_DATA_NUM(1024),.COV_CORE_WIDTH(16),
        .COV_CORE_FW(10),.COV_CORE_ADDR_WIDTH(5),.OUTPUT_DATA_WIDTH(16),.OUTPUT_DATA_FW(10))cov_1_2
        (.clk(clk),
         .rst(rst | mode_rise),
         .start(cov1_2_start),
         .z_in0(cov1_1_z_in0),
         .z_in1(cov1_1_z_in1),
         .z_in2(cov1_1_z_in2),
         .z_in3(cov1_1_z_in3),
         .z_in4(cov1_1_z_in4),
         .trans_start(cov1_2_trans_start),
         .cov_core_data(cov1_2_core_data),
         .cov_core_addr(cov1_2_core_addr),
         .output_data_valid(cov1_2_output_data_valid),
         .output_data(cov1_2_output_data),
         .cov_finish(cov1_2_finish)
        );
    wire [15:0]cov1_2_relu_output_data;
    wire cov1_2_relu_output_data_valid;      
//    sigmoid#(.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.NONCONSTANT_INPUT_DATA_FW(10),.OUTPUT_DATA_WIDTH(16),.OUTPUT_DATA_FW(10))
//    cov1_2_sig(clk,cov1_2_output_data,cov1_2_output_data_valid,cov1_2_sigmoid_output_data,cov1_2_sigmoid_output_data_valid);    
    Relu#(.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.OUTPUT_DATA_WIDTH(16),.OUTPUT_DATA_FW(10)
    )relu_1_2(.clk(clk),.input_data(cov1_2_output_data),.input_data_en(cov1_2_output_data_valid),.output_data(cov1_2_relu_output_data),.output_data_valid(cov1_2_relu_output_data_valid));  
    
    wire [15:0]pooling1_2_output_data;
    wire pooling1_2_output_data_en;
    wire pooling1_2_finish;
    MaxPool#(.SIDE_LENGTH(2),.STRIDE(2),.DATA_ROW(28),.DATA_COLUMN(28),.DATA_WIDTH(16),.DATA_FW(10))pooling1_2
    (clk,rst | mode_rise,cov1_2_trans_start,cov1_2_relu_output_data,cov1_2_relu_output_data_valid,pooling1_2_output_data,pooling1_2_output_data_en,pooling1_2_finish);
     
     
      
 /**************COV2_1*****************/     
    parameter LAYER2_DATAWIDTH = 24;
      
    wire [4:0] cov2_1_core_addr;
    
    
    wire signed[15:0] cov2_1_core_data;
    blk_mem_gen_3 w_cov2_1_rom
    (
     .clka(clk),
     .ena(1),
     .addra(cov2_1_core_addr),
     .douta(cov2_1_core_data)
    );
      
    reg [LAYER2_DATAWIDTH-1:0]cov2_1_z_in[195:0];
    reg [8:0]cov2_1_rd_cnt;initial cov2_1_rd_cnt = 0;
    always@(posedge clk)begin
      if(rst | mode_rise)begin
        cov2_1_rd_cnt <= 0;
      end
      else begin
      if(pooling1_1_output_data_en)begin
        cov2_1_z_in[cov2_1_rd_cnt] <= pooling1_1_output_data;
        cov2_1_rd_cnt <= cov2_1_rd_cnt + 1;
      end
      else
        cov2_1_rd_cnt <= cov2_1_rd_cnt;
      end
    end
      
    reg [LAYER2_DATAWIDTH-1:0]cov2_1_z_in0,cov2_1_z_in1,cov2_1_z_in2,cov2_1_z_in3,cov2_1_z_in4;
    initial begin cov2_1_z_in0 = 0 ;cov2_1_z_in1 = 0;cov2_1_z_in2 = 0;cov2_1_z_in3 = 0; cov2_1_z_in4 = 0;end
    reg [9:0]cov2_1_trans_cnt;initial cov2_1_trans_cnt = 0;
    reg [1:0]cov2_1_trans_state;initial cov2_1_trans_state = 0;
    always@(posedge clk)begin
      case(cov2_1_trans_state)
        0:begin
          if(pooling1_1_finish)begin
            cov2_1_trans_state <= 1;
          end
          else
            cov2_1_trans_state <= 0;
        end
        1:begin
          if(cov2_1_trans_start)begin
            cov2_1_z_in0 <= cov2_1_z_in[cov2_1_trans_cnt];
            cov2_1_z_in1 <= cov2_1_z_in[cov2_1_trans_cnt+14];
            cov2_1_z_in2 <= cov2_1_z_in[cov2_1_trans_cnt+28];
            cov2_1_z_in3 <= cov2_1_z_in[cov2_1_trans_cnt+42];
            cov2_1_z_in4 <= cov2_1_z_in[cov2_1_trans_cnt+56];
            cov2_1_trans_cnt <= cov2_1_trans_cnt + 1;
            cov2_1_trans_state <= 2;
          end
          else 
            cov2_1_trans_state <= cov2_1_trans_state;
        end
        2:begin
          if(cov2_1_trans_cnt < 140)begin
            cov2_1_z_in0 <= cov2_1_z_in[cov2_1_trans_cnt];
            cov2_1_z_in1 <= cov2_1_z_in[cov2_1_trans_cnt+14];
            cov2_1_z_in2 <= cov2_1_z_in[cov2_1_trans_cnt+28];
            cov2_1_z_in3 <= cov2_1_z_in[cov2_1_trans_cnt+42];
            cov2_1_z_in4 <= cov2_1_z_in[cov2_1_trans_cnt+56];
            cov2_1_trans_cnt <= cov2_1_trans_cnt + 1;
            end 
          else begin
            cov2_1_trans_state <= 3;
          end
        end
        3:begin
          cov2_1_trans_state <= 0;
          cov2_1_trans_cnt <= 0;
        end
      endcase
    end
      
    wire cov2_1_trans_start;
    wire [0:0]cov2_1_output_data_valid;
    wire signed[LAYER2_DATAWIDTH-1:0]cov2_1_output_data;
    wire cov2_1_finish;
    cov#(.COV_CORE_ROW(5),.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.INPUT_DATA_ROW(14),.INPUT_DATA_NUM(196),.COV_CORE_WIDTH(16),
         .COV_CORE_FW(10),.COV_CORE_ADDR_WIDTH(5),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.OUTPUT_DATA_FW(10))cov_2_1
        (.clk(clk),
         .rst(rst | mode_rise),
         .start(pooling1_1_finish),
         .z_in0(cov2_1_z_in0),
         .z_in1(cov2_1_z_in1),
         .z_in2(cov2_1_z_in2),
         .z_in3(cov2_1_z_in3),
         .z_in4(cov2_1_z_in4),
         .trans_start(cov2_1_trans_start),
         .cov_core_data(cov2_1_core_data),
         .cov_core_addr(cov2_1_core_addr),
         .output_data_valid(cov2_1_output_data_valid),
         .output_data(cov2_1_output_data),
         .cov_finish(cov2_1_finish)
        );
    wire signed[LAYER2_DATAWIDTH-1:0]TestCovData;    
    wire TestCovOutEn;
    wire TestCovFinish;
    Conv#(.COV_CORE_ROW(5),.COV_CORE_COLUMN(5),.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.INPUT_DATA_ROW(14),.INPUT_DATA_NUM(196),
          .COV_CORE_WIDTH(16),.COV_CORE_FW(10),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),
          .OUTPUT_DATA_FW(10),.CONV_CORE_DATA_FILE("covcore2_1.dat"))cov_2_1_test
        (.clk(clk),
         .rst(rst | mode_rise),
         .start(cov1_2_start),
         .data_input_en(pooling1_1_output_data_en),
         .data_input(pooling1_1_output_data),
         .output_data_valid(TestCovOutEn),
         .output_data(TestCovData),
         .cov_finish(TestCovFinish)
        );  
  
    /**************cov2_2***************/  
     
    wire [4:0] cov2_2_core_addr;
    wire signed[15:0] cov2_2_core_data;
       blk_mem_gen_4 w_cov2_2_rom
      (
        .clka(clk),
        .ena(1),
        .addra(cov2_2_core_addr),
        .douta(cov2_2_core_data)
      );
    
    reg [LAYER2_DATAWIDTH-1:0]cov2_2_z_in[195:0];
    reg [8:0]cov2_2_rd_cnt;initial cov2_2_rd_cnt = 0;
    always@(posedge clk)begin
      if(rst | mode_rise)begin
        cov2_2_rd_cnt <= 0;
      end
      else begin
        if(pooling1_2_output_data_en)begin
          cov2_2_z_in[cov2_2_rd_cnt] <= pooling1_2_output_data;
          cov2_2_rd_cnt <= cov2_2_rd_cnt + 1;
        end
        else
          cov2_2_rd_cnt <= cov2_2_rd_cnt;
        end
    end
    
    reg [LAYER2_DATAWIDTH-1:0]cov2_2_z_in0,cov2_2_z_in1,cov2_2_z_in2,cov2_2_z_in3,cov2_2_z_in4;
    initial begin cov2_2_z_in0 = 0 ;cov2_2_z_in1 = 0;cov2_2_z_in2 = 0;cov2_2_z_in3 = 0; cov2_2_z_in4 = 0;end
    reg [9:0]cov2_2_trans_cnt;initial cov2_2_trans_cnt = 0;
    reg [1:0]cov2_2_trans_state;initial cov2_2_trans_state = 0;
    always@(posedge clk)begin
      case(cov2_2_trans_state)
        0:begin
          if(pooling1_1_finish)begin
            cov2_2_trans_state <= 1;
          end
          else
            cov2_2_trans_state <= 0;
        end
        1:begin
          if(cov2_2_trans_start)begin
            cov2_2_z_in0 <= cov2_2_z_in[cov2_2_trans_cnt];
            cov2_2_z_in1 <= cov2_2_z_in[cov2_2_trans_cnt+14];
            cov2_2_z_in2 <= cov2_2_z_in[cov2_2_trans_cnt+28];
            cov2_2_z_in3 <= cov2_2_z_in[cov2_2_trans_cnt+42];
            cov2_2_z_in4 <= cov2_2_z_in[cov2_2_trans_cnt+56];
            cov2_2_trans_cnt <= cov2_2_trans_cnt + 1;
            cov2_2_trans_state <= 2;
          end
          else 
            cov2_2_trans_state <= cov2_2_trans_state;
        end
        2:begin
          if(cov2_2_trans_cnt < 140)begin
            cov2_2_z_in0 <= cov2_2_z_in[cov2_2_trans_cnt];
            cov2_2_z_in1 <= cov2_2_z_in[cov2_2_trans_cnt+14];
            cov2_2_z_in2 <= cov2_2_z_in[cov2_2_trans_cnt+28];
            cov2_2_z_in3 <= cov2_2_z_in[cov2_2_trans_cnt+42];
            cov2_2_z_in4 <= cov2_2_z_in[cov2_2_trans_cnt+56];
            cov2_2_trans_cnt <= cov2_2_trans_cnt + 1;
            end 
          else begin
            cov2_2_trans_state <= 3;
          end
        end
        3:begin
          cov2_2_trans_state <= 0;
          cov2_2_trans_cnt <= 0;
        end
      endcase
    end
    
    wire cov2_2_trans_start;
    wire [0:0]cov2_2_output_data_valid;
    wire signed[LAYER2_DATAWIDTH-1:0]cov2_2_output_data;
    wire cov2_2_finish;
     cov#(.COV_CORE_ROW(5),.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.INPUT_DATA_ROW(14),.INPUT_DATA_NUM(196),.COV_CORE_WIDTH(16),
         .COV_CORE_FW(10),.COV_CORE_ADDR_WIDTH(5),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.OUTPUT_DATA_FW(10))cov_2_2
        (.clk(clk),
         .rst(rst | mode_rise),
         .start(pooling1_2_finish),
         .z_in0(cov2_2_z_in0),
         .z_in1(cov2_2_z_in1),
         .z_in2(cov2_2_z_in2),
         .z_in3(cov2_2_z_in3),
         .z_in4(cov2_2_z_in4),
         .trans_start(cov2_2_trans_start),
         .cov_core_data(cov2_2_core_data),
         .cov_core_addr(cov2_2_core_addr),
         .output_data_valid(cov2_2_output_data_valid),
         .output_data(cov2_2_output_data),
         .cov_finish(cov2_2_finish)
        );
/***********sig2_1 pooling_2_1**********************/  

    wire [LAYER2_DATAWIDTH-1:0]sigmoid2_1_output_data;
    wire sigmoid2_1_output_data_valid;
    sigmoid#(.INPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.INPUT_DATA_FW(10),.NONCONSTANT_INPUT_DATA_FW(10),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.OUTPUT_DATA_FW(10))
    sig2_1(clk,cov2_2_output_data + cov2_1_output_data,cov2_2_output_data_valid,sigmoid2_1_output_data,sigmoid2_1_output_data_valid);    
    wire [LAYER2_DATAWIDTH-1:0]pooling2_1_output_data;
    wire pooling2_1_output_data_en;
    wire pooling2_1_finish;
    MaxPool#(.SIDE_LENGTH(2),.STRIDE(2),.DATA_ROW(10),.DATA_COLUMN(10),.DATA_WIDTH(LAYER2_DATAWIDTH),.DATA_FW(10))pooling2_1
    (clk,rst | mode_rise,cov2_2_trans_start,sigmoid2_1_output_data,sigmoid2_1_output_data_valid,pooling2_1_output_data,pooling2_1_output_data_en,pooling2_1_finish);  
     
     
 /**************COV2_3*****************/     
         
         
       wire [4:0] cov2_3_core_addr;     
       wire signed[15:0] cov2_3_core_data;
       blk_mem_gen_5 w_cov2_3_rom
       (
        .clka(clk),
        .ena(1),
        .addra(cov2_3_core_addr),
        .douta(cov2_3_core_data)
       );
         
         
       wire cov2_3_trans_start;
       wire [0:0]cov2_3_output_data_valid;
       wire signed[LAYER2_DATAWIDTH-1:0]cov2_3_output_data;
       wire cov2_3_finish;
       cov#(.COV_CORE_ROW(5),.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.INPUT_DATA_ROW(14),.INPUT_DATA_NUM(196),.COV_CORE_WIDTH(16),
            .COV_CORE_FW(10),.COV_CORE_ADDR_WIDTH(5),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.OUTPUT_DATA_FW(10))cov_2_3
           (.clk(clk),
            .rst(rst | mode_rise),
            .start(pooling1_1_finish),
            .z_in0(cov2_1_z_in0),
            .z_in1(cov2_1_z_in1),
            .z_in2(cov2_1_z_in2),
            .z_in3(cov2_1_z_in3),
            .z_in4(cov2_1_z_in4),
            .trans_start(cov2_3_trans_start),
            .cov_core_data(cov2_3_core_data),
            .cov_core_addr(cov2_3_core_addr),
            .output_data_valid(cov2_3_output_data_valid),
            .output_data(cov2_3_output_data),
            .cov_finish(cov2_3_finish)
           );
     
       /**************cov2_4***************/  
        
       wire [4:0] cov2_4_core_addr;
       wire signed[15:0] cov2_4_core_data;
          blk_mem_gen_6 w_cov2_4_rom
         (
           .clka(clk),
           .ena(1),
           .addra(cov2_4_core_addr),
           .douta(cov2_4_core_data)
         );
       
       wire cov2_4_trans_start;
       wire [0:0]cov2_4_output_data_valid;
       wire signed[LAYER2_DATAWIDTH-1:0]cov2_4_output_data;
       wire cov2_4_finish;
    cov#(.COV_CORE_ROW(5),.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.INPUT_DATA_ROW(14),.INPUT_DATA_NUM(196),.COV_CORE_WIDTH(16),
         .COV_CORE_FW(10),.COV_CORE_ADDR_WIDTH(5),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.OUTPUT_DATA_FW(10))cov_2_4
           (.clk(clk),
            .rst(rst | mode_rise),
            .start(pooling1_2_finish),
            .z_in0(cov2_2_z_in0),
            .z_in1(cov2_2_z_in1),
            .z_in2(cov2_2_z_in2),
            .z_in3(cov2_2_z_in3),
            .z_in4(cov2_2_z_in4),
            .trans_start(cov2_4_trans_start),
            .cov_core_data(cov2_4_core_data),
            .cov_core_addr(cov2_4_core_addr),
            .output_data_valid(cov2_4_output_data_valid),
            .output_data(cov2_4_output_data),
            .cov_finish(cov2_4_finish)
           );
   /***********sig2_2 pooling_2_2**********************/  
   
       wire [LAYER2_DATAWIDTH-1:0]sigmoid2_2_output_data;
       wire sigmoid2_2_output_data_valid;
       sigmoid#(.INPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.INPUT_DATA_FW(10),.NONCONSTANT_INPUT_DATA_FW(10),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.OUTPUT_DATA_FW(10))
       sig2_2(clk,cov2_3_output_data + cov2_4_output_data,cov2_3_output_data_valid,sigmoid2_2_output_data,sigmoid2_2_output_data_valid);    
       wire [LAYER2_DATAWIDTH-1:0]pooling2_2_output_data;
       wire pooling2_2_output_data_en;
       wire pooling2_2_finish;
       MaxPool#(.SIDE_LENGTH(2),.STRIDE(2),.DATA_ROW(10),.DATA_COLUMN(10),.DATA_WIDTH(LAYER2_DATAWIDTH),.DATA_FW(10))pooling2_2
       (clk,rst | mode_rise,cov2_4_trans_start,sigmoid2_2_output_data,sigmoid2_2_output_data_valid,pooling2_2_output_data,pooling2_2_output_data_en,pooling2_2_finish);  
   
   
 /**************COV2_5*****************/     
               
               
             wire [4:0] cov2_5_core_addr;     
             wire signed[15:0] cov2_5_core_data;
             blk_mem_gen_7 w_cov2_5_rom
             (
              .clka(clk),
              .ena(1),
              .addra(cov2_5_core_addr),
              .douta(cov2_5_core_data)
             );
               
               
             wire cov2_5_trans_start;
             wire [0:0]cov2_5_output_data_valid;
             wire signed[LAYER2_DATAWIDTH-1:0]cov2_5_output_data;
             wire cov2_5_finish;
    cov#(.COV_CORE_ROW(5),.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.INPUT_DATA_ROW(14),.INPUT_DATA_NUM(196),.COV_CORE_WIDTH(16),
         .COV_CORE_FW(10),.COV_CORE_ADDR_WIDTH(5),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.OUTPUT_DATA_FW(10))cov_2_5
                 (.clk(clk),
                  .rst(rst | mode_rise),
                  .start(pooling1_1_finish),
                  .z_in0(cov2_1_z_in0),
                  .z_in1(cov2_1_z_in1),
                  .z_in2(cov2_1_z_in2),
                  .z_in3(cov2_1_z_in3),
                  .z_in4(cov2_1_z_in4),
                  .trans_start(cov2_5_trans_start),
                  .cov_core_data(cov2_5_core_data),
                  .cov_core_addr(cov2_5_core_addr),
                  .output_data_valid(cov2_5_output_data_valid),
                  .output_data(cov2_5_output_data),
                  .cov_finish(cov2_5_finish)
                 );
           
             /**************cov2_6***************/  
              
             wire [4:0] cov2_6_core_addr;
             wire signed[15:0] cov2_6_core_data;
                blk_mem_gen_8 w_cov2_6_rom
               (
                 .clka(clk),
                 .ena(1),
                 .addra(cov2_6_core_addr),
                 .douta(cov2_6_core_data)
               );
             
             wire cov2_6_trans_start;
             wire [0:0]cov2_6_output_data_valid;
             wire signed[LAYER2_DATAWIDTH-1:0]cov2_6_output_data;
             wire cov2_6_finish;
    cov#(.COV_CORE_ROW(5),.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.INPUT_DATA_ROW(14),.INPUT_DATA_NUM(196),.COV_CORE_WIDTH(16),
         .COV_CORE_FW(10),.COV_CORE_ADDR_WIDTH(5),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.OUTPUT_DATA_FW(10))cov_2_6
                 (.clk(clk),
                  .rst(rst | mode_rise),
                  .start(pooling1_2_finish),
                  .z_in0(cov2_2_z_in0),
                  .z_in1(cov2_2_z_in1),
                  .z_in2(cov2_2_z_in2),
                  .z_in3(cov2_2_z_in3),
                  .z_in4(cov2_2_z_in4),
                  .trans_start(cov2_6_trans_start),
                  .cov_core_data(cov2_6_core_data),
                  .cov_core_addr(cov2_6_core_addr),
                  .output_data_valid(cov2_6_output_data_valid),
                  .output_data(cov2_6_output_data),
                  .cov_finish(cov2_6_finish)
                 );
         /***********sig2_3 pooling_2_3**********************/  
         
             wire [LAYER2_DATAWIDTH-1:0]sigmoid2_3_output_data;
             wire sigmoid2_3_output_data_valid;
             sigmoid#(.INPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.INPUT_DATA_FW(10),.NONCONSTANT_INPUT_DATA_FW(10),.OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),.OUTPUT_DATA_FW(10))
             sig2_3(clk,cov2_5_output_data + cov2_6_output_data,cov2_5_output_data_valid,sigmoid2_3_output_data,sigmoid2_3_output_data_valid);    
             wire [LAYER2_DATAWIDTH-1:0]pooling2_3_output_data;
             wire pooling2_3_output_data_en;
             wire pooling2_3_finish;
             MaxPool#(.SIDE_LENGTH(2),.STRIDE(2),.DATA_ROW(10),.DATA_COLUMN(10),.DATA_WIDTH(LAYER2_DATAWIDTH),.DATA_FW(10))pooling2_3
             (clk,rst | mode_rise,cov2_6_trans_start,sigmoid2_3_output_data,sigmoid2_3_output_data_valid,pooling2_3_output_data,pooling2_3_output_data_en,pooling2_3_finish);  
            
    FullConnect#(
      .INPUT_DATA_WIDTH(LAYER2_DATAWIDTH),
      .INPUT_DATA_FW(10),
      .INPUT_WEIGHT_WIDTH(16),
      .INPUT_DATA_POOLING_NUM(3),
      .INPUT_DATA_POOLING_CNT(25),
      .OUTPUT_DATA_WIDTH(LAYER2_DATAWIDTH),
      .OUTPUT_WIDTH(4),
      .FCW_FILE("fc1_core.dat"),
      .FCB_FILE("fcb_data.dat")
      )fc1(
      .clk(clk),
      .rst(rst | mode_rise),
      .start(pooling1_1_finish),
      .pooling2_1_output_data(pooling2_1_output_data),
      .pooling_data_input_en(pooling2_1_output_data_en),
      .pooling2_2_output_data(pooling2_2_output_data),
      .pooling2_3_output_data(pooling2_3_output_data),
      .led(led)
//      .full_connect1_output_data(full_connect1_output_data),
//      .full_connect1_output_en(full_connect1_output_en)
      );
endmodule
