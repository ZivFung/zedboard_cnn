`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2018 12:42:21 PM
// Design Name: 
// Module Name: Cnn
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


module Cnn#(
    parameter INPUT_DW = 2,
    parameter INPUT_FW = 0,
    parameter INPUT_ROW_NUM = 32,
    parameter INPUT_COLUMN_NUM = 32,
    parameter OUTPUT_DW = 4
)(  input wire clk,
    input wire rst,
    input wire start,
    input wire signed[INPUT_DW-1:0]Din,
    input wire Din_en,
    output logic [OUTPUT_DW-1:0]Dout
 );
 localparam COV1_DEPTH = 2;
 localparam COV1_INPUT_NUM = INPUT_COLUMN_NUM * INPUT_ROW_NUM;
 localparam COV1_DW = 16;
 localparam COV1_FW = 10;
 localparam COV1POOL_IN_ROWNUM = INPUT_ROW_NUM - 4;
 localparam COV1POOL_IN_COLUMNNUM = INPUT_ROW_NUM - 4;
 localparam COV1POOL_OUT_ROWNUM = COV1POOL_IN_ROWNUM/2;
 localparam COV1POOL_OUT_COLUMNNUM = COV1POOL_IN_COLUMNNUM/2;
 
 localparam COV2_DEPTH = 3;
 localparam COV2_INPUT_NUM = COV1POOL_OUT_COLUMNNUM * COV1POOL_OUT_ROWNUM;
 localparam COV2_DW = 21;
 localparam COV2_FW = 10;
 localparam COV2POOL_IN_ROWNUM = COV1POOL_OUT_ROWNUM - 4;
 localparam COV2POOL_IN_COLUMNNUM = COV1POOL_OUT_COLUMNNUM - 4;
 localparam COV2POOL_OUT_ROWNUM = COV2POOL_IN_ROWNUM/2;
 localparam COV2POOL_OUT_COLUMNNUM = COV2POOL_IN_COLUMNNUM/2;
 
 localparam FC_IN_DATANUM = COV2POOL_OUT_ROWNUM * COV2POOL_OUT_COLUMNNUM;
 
 localparam WEIGHT_DW = 16;
 localparam WEIGHT_FW = 10;
 /************************Layer1**************************/
 logic signed[COV1_DW-1:0]Cov1_1OutData;
 logic signed Cov1_1OutEn;
 logic Cov1_1OutStart;
 Conv#(
     .COV_CORE_ROW(5),
     .COV_CORE_COLUMN(5),
     .INPUT_DATA_WIDTH(INPUT_DW),
     .INPUT_DATA_FW(INPUT_FW),
     .INPUT_DATA_ROW(INPUT_ROW_NUM),
     .INPUT_DATA_NUM(COV1_INPUT_NUM),
     .COV_CORE_WIDTH(16),   //    Q6.10
     .COV_CORE_FW(10),
     .OUTPUT_DATA_WIDTH(COV1_DW),
     .OUTPUT_DATA_FW(COV1_FW),
     .CONV_CORE_DATA_FILE("covcore1_1.dat")
     )theCov1_1(
     .clk(clk),
     .rst(rst),
     .start(start),
     .Din(Din),
     .Din_en(Din_en),
     .Dout_en(Cov1_1OutEn),
     .Dout(Cov1_1OutData),
     .DoutStart(Cov1_1OutStart),
     .Finish()
     );
 logic signed[COV1_DW-1:0]Relu1_1OutData;
 logic signed Relu1_1OutEn;
 Relu#(
     .INPUT_DW(COV1_DW),
     .OUTPUT_DW(COV1_DW)
     )the_Relu1_1(
     .Din(Cov1_1OutData),
     .Din_en(Cov1_1OutEn),
     .Dout(Relu1_1OutData),
     .Dout_en(Relu1_1OutEn)
     );
 
 logic signed[COV1_DW-1:0]MaxPool1_1OutData;
 logic MaxPool1_1OutEn;
 logic MaxPool1_1OutStart;
 MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV1POOL_IN_ROWNUM),
     .DATA_COLUMN(COV1POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV1_DW),
     .DATA_FW(COV1_FW)
    )theMaxPool1_1(
     .clk(clk),
     .rst(rst),
     .start(Cov1_1OutStart),
     .Din(Relu1_1OutData),
     .Din_en(Relu1_1OutEn),
     .Dout(MaxPool1_1OutData),
     .Dout_en(MaxPool1_1OutEn),
     .DoutStart(MaxPool1_1OutStart),
     .Finish()
    );


 logic signed[COV1_DW-1:0]Cov1_2OutData;
 logic signed Cov1_2OutEn;
 logic Cov1_2OutStart;
 Conv#(
     .COV_CORE_ROW(5),
     .COV_CORE_COLUMN(5),
     .INPUT_DATA_WIDTH(INPUT_DW),
     .INPUT_DATA_FW(INPUT_FW),
     .INPUT_DATA_ROW(INPUT_ROW_NUM),
     .INPUT_DATA_NUM(COV1_INPUT_NUM),
     .COV_CORE_WIDTH(16),   //    Q6.10
     .COV_CORE_FW(10),
     .OUTPUT_DATA_WIDTH(COV1_DW),
     .OUTPUT_DATA_FW(COV1_FW),
     .CONV_CORE_DATA_FILE("covcore1_2.dat")
     )theCov1_2(
     .clk(clk),
     .rst(rst),
     .start(start),
     .Din(Din),
     .Din_en(Din_en),
     .Dout_en(Cov1_2OutEn),
     .Dout(Cov1_2OutData),
     .DoutStart(Cov1_2OutStart),
     .Finish()
     );
 logic signed[COV1_DW-1:0]Relu1_2OutData;
 logic signed Relu1_2OutEn;
 Relu#(
     .INPUT_DW(COV1_DW),
     .OUTPUT_DW(COV1_DW)
     )theRelu1_2(
     .Din(Cov1_2OutData),
     .Din_en(Cov1_2OutEn),
     .Dout(Relu1_2OutData),
     .Dout_en(Relu1_2OutEn)
     );
 
 logic signed[COV1_DW-1:0]MaxPool1_2OutData;
 logic MaxPool1_2OutEn;
 logic MaxPool1_2OutStart;
 MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV1POOL_IN_ROWNUM),
     .DATA_COLUMN(COV1POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV1_DW),
     .DATA_FW(COV1_FW)
    )theMaxPool1_2(
     .clk(clk),
     .rst(rst),
     .start(Cov1_2OutStart),
     .Din(Relu1_2OutData),
     .Din_en(Relu1_2OutEn),
     .Dout(MaxPool1_2OutData),
     .Dout_en(MaxPool1_2OutEn),
     .DoutStart(MaxPool1_2OutStart),
     .Finish()
    );    


 /************************Layer2**************************/
 logic signed[COV2_DW-1:0]Cov2_1OutData;
 logic signed Cov2_1OutEn;
 logic Cov2_1OutStart;
 Conv#(
     .COV_CORE_ROW(5),
     .COV_CORE_COLUMN(5),
     .INPUT_DATA_WIDTH(COV1_DW),
     .INPUT_DATA_FW(COV1_FW),
     .INPUT_DATA_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_DATA_NUM(COV2_INPUT_NUM),
     .COV_CORE_WIDTH(16),   //    Q6.10
     .COV_CORE_FW(10),
     .OUTPUT_DATA_WIDTH(COV2_DW),
     .OUTPUT_DATA_FW(COV2_FW),
     .CONV_CORE_DATA_FILE("covcore2_1.dat")
     )theCov2_1(
     .clk(clk),
     .rst(rst),
     .start(Cov1_1OutStart),
     .Din(MaxPool1_1OutData),
     .Din_en(MaxPool1_1OutEn),
     .Dout_en(Cov2_1OutEn),
     .Dout(Cov2_1OutData),
     .DoutStart(Cov2_1OutStart),
     .Finish()
     );
     
 logic signed[COV2_DW-1:0]Cov2_2OutData;
 logic signed Cov2_2OutEn;
 logic Cov2_2OutStart;
 Conv#(
     .COV_CORE_ROW(5),
     .COV_CORE_COLUMN(5),
     .INPUT_DATA_WIDTH(COV1_DW),
     .INPUT_DATA_FW(COV1_FW),
     .INPUT_DATA_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_DATA_NUM(COV2_INPUT_NUM),
     .COV_CORE_WIDTH(16),   //    Q6.10
     .COV_CORE_FW(10),
     .OUTPUT_DATA_WIDTH(COV2_DW),
     .OUTPUT_DATA_FW(COV2_FW),
     .CONV_CORE_DATA_FILE("covcore2_2.dat")
     )theCov2_2(
     .clk(clk),
     .rst(rst),
     .start(Cov1_2OutStart),
     .Din(MaxPool1_2OutData),
     .Din_en(MaxPool1_2OutEn),
     .Dout_en(Cov2_2OutEn),
     .Dout(Cov2_2OutData),
     .DoutStart(Cov2_2OutStart),
     .Finish()
     );   
 logic signed[COV2_DW-1:0]Sigmoid2_1OutData;
 logic Sigmoid2_1OutEn;    
 Sigmoid#(
     .INPUT_DW(COV2_DW),
     .INPUT_FW(COV2_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW)
     )theSigmoid2_1(
     .Din(Cov2_1OutData + Cov2_2OutData),
     .Din_en(Cov2_1OutEn),
     .Dout(Sigmoid2_1OutData),
     .Dout_en(Sigmoid2_1OutEn)
     );
 
 logic signed[COV2_DW-1:0]MaxPool2_1OutData;
 logic MaxPool2_1OutEn;
 logic MaxPool2_1OutStart;
 MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV2POOL_IN_ROWNUM),
     .DATA_COLUMN(COV2POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV2_DW),
     .DATA_FW(COV2_FW)
     )theMaxPool2_1(
     .clk(clk),
     .rst(rst),
     .start(Cov2_1OutStart),
     .Din(Sigmoid2_1OutData),
     .Din_en(Sigmoid2_1OutEn),
     .Dout(MaxPool2_1OutData),
     .Dout_en(MaxPool2_1OutEn),
     .DoutStart(MaxPool2_1OutStart),
     .Finish()
     );  


 logic signed[COV2_DW-1:0]Cov2_3OutData;
 logic signed Cov2_3OutEn;
 logic Cov2_3OutStart;
 Conv#(
     .COV_CORE_ROW(5),
     .COV_CORE_COLUMN(5),
     .INPUT_DATA_WIDTH(COV1_DW),
     .INPUT_DATA_FW(COV1_FW),
     .INPUT_DATA_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_DATA_NUM(COV2_INPUT_NUM),
     .COV_CORE_WIDTH(16),   //    Q6.10
     .COV_CORE_FW(10),
     .OUTPUT_DATA_WIDTH(COV2_DW),
     .OUTPUT_DATA_FW(COV2_FW),
     .CONV_CORE_DATA_FILE("covcore2_3.dat")
     )theCov2_3(
     .clk(clk),
     .rst(rst),
     .start(Cov1_1OutStart),
     .Din(MaxPool1_1OutData),
     .Din_en(MaxPool1_1OutEn),
     .Dout_en(Cov2_3OutEn),
     .Dout(Cov2_3OutData),
     .DoutStart(Cov2_3OutStart),
     .Finish()
     );
     
 logic signed[COV2_DW-1:0]Cov2_4OutData;
 logic signed Cov2_4OutEn;
 logic Cov2_4OutStart;
 Conv#(
     .COV_CORE_ROW(5),
     .COV_CORE_COLUMN(5),
     .INPUT_DATA_WIDTH(COV1_DW),
     .INPUT_DATA_FW(COV1_FW),
     .INPUT_DATA_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_DATA_NUM(COV2_INPUT_NUM),
     .COV_CORE_WIDTH(16),   //    Q6.10
     .COV_CORE_FW(10),
     .OUTPUT_DATA_WIDTH(COV2_DW),
     .OUTPUT_DATA_FW(COV2_FW),
     .CONV_CORE_DATA_FILE("covcore2_4.dat")
     )theCov2_4(
     .clk(clk),
     .rst(rst),
     .start(Cov1_2OutStart),
     .Din(MaxPool1_2OutData),
     .Din_en(MaxPool1_2OutEn),
     .Dout_en(Cov2_4OutEn),
     .Dout(Cov2_4OutData),
     .DoutStart(Cov2_4OutStart),
     .Finish()
     );   
 logic signed[COV2_DW-1:0]Sigmoid2_2OutData;
 logic Sigmoid2_2OutEn;    
 Sigmoid#(
     .INPUT_DW(COV2_DW),
     .INPUT_FW(COV2_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW)
     )theSigmoid2_2(
     .Din(Cov2_3OutData + Cov2_4OutData),
     .Din_en(Cov2_3OutEn),
     .Dout(Sigmoid2_2OutData),
     .Dout_en(Sigmoid2_2OutEn)
     );
 
 logic signed[COV2_DW-1:0]MaxPool2_2OutData;
 logic MaxPool2_2OutEn;
 logic MaxPool2_2OutStart;
  MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV2POOL_IN_ROWNUM),
     .DATA_COLUMN(COV2POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV2_DW),
     .DATA_FW(COV2_FW)
     )theMaxPool2_2(
     .clk(clk),
     .rst(rst),
     .start(Cov2_3OutStart),
     .Din(Sigmoid2_2OutData),
     .Din_en(Sigmoid2_2OutEn),
     .Dout(MaxPool2_2OutData),
     .Dout_en(MaxPool2_2OutEn),
     .DoutStart(MaxPool2_2OutStart),
     .Finish()
     ); 
 logic signed[COV2_DW-1:0]Cov2_5OutData;
 logic signed Cov2_5OutEn;
 logic Cov2_5OutStart;
 Conv#(
     .COV_CORE_ROW(5),
     .COV_CORE_COLUMN(5),
     .INPUT_DATA_WIDTH(COV1_DW),
     .INPUT_DATA_FW(COV1_FW),
     .INPUT_DATA_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_DATA_NUM(COV2_INPUT_NUM),
     .COV_CORE_WIDTH(16),   //    Q6.10
     .COV_CORE_FW(10),
     .OUTPUT_DATA_WIDTH(COV2_DW),
     .OUTPUT_DATA_FW(COV2_FW),
     .CONV_CORE_DATA_FILE("covcore2_5.dat")
     )theCov2_5(
     .clk(clk),
     .rst(rst),
     .start(Cov1_1OutStart),
     .Din(MaxPool1_1OutData),
     .Din_en(MaxPool1_1OutEn),
     .Dout_en(Cov2_5OutEn),
     .Dout(Cov2_5OutData),
     .DoutStart(Cov2_5OutStart),
     .Finish()
     );   
 logic signed[COV2_DW-1:0]Cov2_6OutData;
 logic signed Cov2_6OutEn;
 logic Cov2_6OutStart;
 Conv#(
     .COV_CORE_ROW(5),
     .COV_CORE_COLUMN(5),
     .INPUT_DATA_WIDTH(COV1_DW),
     .INPUT_DATA_FW(COV1_FW),
     .INPUT_DATA_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_DATA_NUM(COV2_INPUT_NUM),
     .COV_CORE_WIDTH(16),   //    Q6.10
     .COV_CORE_FW(10),
     .OUTPUT_DATA_WIDTH(COV2_DW),
     .OUTPUT_DATA_FW(COV2_FW),
     .CONV_CORE_DATA_FILE("covcore2_6.dat")
     )theCov2_6(
     .clk(clk),
     .rst(rst),
     .start(Cov1_2OutStart),
     .Din(MaxPool1_2OutData),
     .Din_en(MaxPool1_2OutEn),
     .Dout_en(Cov2_6OutEn),
     .Dout(Cov2_6OutData),
     .DoutStart(Cov2_6OutStart),
     .Finish()
     );  
 logic signed[COV2_DW-1:0]Sigmoid2_3OutData;
 logic Sigmoid2_3OutEn;    
 Sigmoid#(
     .INPUT_DW(COV2_DW),
     .INPUT_FW(COV2_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW)
     )theSigmoid2_3(
     .Din(Cov2_5OutData + Cov2_6OutData),
     .Din_en(Cov2_5OutEn),
     .Dout(Sigmoid2_3OutData),
     .Dout_en(Sigmoid2_3OutEn)
     );
 
 logic signed[COV2_DW-1:0]MaxPool2_3OutData;
 logic MaxPool2_3OutEn;
 logic MaxPool2_3OutStart;
 MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV2POOL_IN_ROWNUM),
     .DATA_COLUMN(COV2POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV2_DW),
     .DATA_FW(COV2_FW)
     )theMaxPool2_3(
     .clk(clk),
     .rst(rst),
     .start(Cov2_5OutStart),
     .Din(Sigmoid2_3OutData),
     .Din_en(Sigmoid2_3OutEn),
     .Dout(MaxPool2_3OutData),
     .Dout_en(MaxPool2_3OutEn),
     .DoutStart(MaxPool2_3OutStart),
     .Finish()
     );  
      
FullConnect#(
   .INPUT_DATA_WIDTH(COV2_DW),
   .INPUT_DATA_FW(COV2_FW),
   .INPUT_WEIGHT_WIDTH(WEIGHT_DW),
   .INPUT_DATA_POOLING_NUM(COV2_DEPTH),
   .INPUT_DATA_POOLING_CNT(FC_IN_DATANUM),
   .OUTPUT_WIDTH(OUTPUT_DW),
   .FCW_FILE("fc1_core.dat"),
   .FCB_FILE("fcb_data.dat")
   )fc1(
   .clk(clk),
   .rst(rst),
   .start(MaxPool2_1OutStart),
   .pooling2_1_output_data(MaxPool2_1OutData),
   .pooling_data_input_en(MaxPool2_1OutEn),
   .pooling2_2_output_data(MaxPool2_2OutData),
   .pooling2_3_output_data(MaxPool2_3OutData),
   .led(Dout)
   );
endmodule
