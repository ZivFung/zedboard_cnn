`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2018 06:03:21 PM
// Design Name: 
// Module Name: Cnn_Optimize
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


module Cnn_Optimize#(
    parameter INPUT_DW = 2,
    parameter INPUT_FW = 0,
    parameter INPUT_ROW_NUM = 32,
    parameter INPUT_COLUMN_NUM = 32,
    parameter OUTPUT_DW = 4
)(  input wire clk,
    input wire rst,
    input wire start,
    (*mark_debug = "true"*)input wire [INPUT_DW-1:0]Din,
    (*mark_debug = "true"*)input wire Din_en,
    output logic Dout_en,
    output logic [OUTPUT_DW-1:0]Dout
 );
 localparam COV1_CORE_ROW = 5;
 localparam COV1_CORE_COLUMN = 5;
 localparam COV1_DEPTH = 3;
 localparam COV1_PROCESS_WIDTH = 16;
 localparam COV1_INPUT_NUM = INPUT_COLUMN_NUM * INPUT_ROW_NUM;
 localparam COV1_RAM_AW = $clog2(COV1_INPUT_NUM);
 localparam COV1_DW = 16;
 localparam COV1_FW = 10;
 localparam COV1POOL_IN_ROWNUM = INPUT_ROW_NUM - 4;
 localparam COV1POOL_IN_COLUMNNUM = INPUT_ROW_NUM - 4;
 localparam COV1POOL_OUT_ROWNUM = COV1POOL_IN_ROWNUM/2;
 localparam COV1POOL_OUT_COLUMNNUM = COV1POOL_IN_COLUMNNUM/2;
 
 localparam COV2_CORE_ROW = 5;
 localparam COV2_CORE_COLUMN = 5;
 localparam COV2_DEPTH = 5;
 localparam COV2_PROCESS_WIDTH = 24;
 localparam COV2_INPUT_NUM = COV1POOL_OUT_COLUMNNUM * COV1POOL_OUT_ROWNUM;
 localparam COV2_RAM_AW = $clog2(COV2_INPUT_NUM);
 localparam COV2_DW = 24;
 localparam COV2_FW = 10;
 localparam COV2_SIGMOID_DW=12;
 localparam COV2POOL_IN_ROWNUM = COV1POOL_OUT_ROWNUM - 4;
 localparam COV2POOL_IN_COLUMNNUM = COV1POOL_OUT_COLUMNNUM - 4;
 localparam COV2POOL_OUT_ROWNUM = COV2POOL_IN_ROWNUM/2;
 localparam COV2POOL_OUT_COLUMNNUM = COV2POOL_IN_COLUMNNUM/2;
 
 localparam FC_IN_DATANUM = COV2POOL_OUT_ROWNUM * COV2POOL_OUT_COLUMNNUM;
 localparam FC_DW = 18;
 
 localparam WEIGHT_DW = 16;
 localparam WEIGHT_FW = 10;
 /************************Layer1**************************/
 logic [COV1_RAM_AW-1:0]Layer1RamAddr;
 logic Conv1Start;
 logic [INPUT_DW-1:0]Ram1DataOut[COV1_CORE_ROW];
 ImgRam1#(
     .DW(INPUT_DW),
     .AW(COV1_RAM_AW),
     .OUTROW_NUM(COV1_CORE_ROW),
     .IMG_ROW(INPUT_ROW_NUM),
     .IMG_COLUMN(INPUT_COLUMN_NUM)
     )theLayer1Ram(
     .clk(clk),
     .rst(rst),
     .start(start),
     .InputEn(Din_en),
     .InputData(Din),
     .OutputAddr(Layer1RamAddr),
     .DataReady(Conv1Start),
     .OutData(Ram1DataOut)  
     );
 logic signed[COV1_DW-1:0]Cov1_1OutData;
 logic Cov1_1OutEn;
 logic Cov1_1OutStart;
 Conv1_Optimize#(
     .COV_CORE_ROW(COV1_CORE_ROW),
     .COV_CORE_COLUMN(COV1_CORE_COLUMN),
     .INPUT_DW(INPUT_DW),
     .INPUT_FW(INPUT_FW),
     .INPUT_ROW(INPUT_ROW_NUM),
     .INPUT_COLUMN(INPUT_COLUMN_NUM),
     .INPUTNUM_DW(COV1_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV1_DW),
     .OUTPUT_FW(COV1_FW),
     .PROCESS_WIDTH(COV1_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore1_1.dat")
     )theConv1_1(
     .clk(clk),
     .rst(rst),
     .start(Conv1Start),
     .Din(Ram1DataOut),
     .DinAddr(Layer1RamAddr),
     .Dout_en(Cov1_1OutEn),
     .Dout(Cov1_1OutData),
     .DoutStart(Cov1_1OutStart),
     .Finish()
     );   
 logic signed[COV1_DW-1:0]Relu1_1OutData;
 logic Relu1_1OutEn;
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
 logic Cov1_2OutEn;
 logic Cov1_2OutStart;
 Conv1_Optimize#(
     .COV_CORE_ROW(COV1_CORE_ROW),
     .COV_CORE_COLUMN(COV1_CORE_COLUMN),
     .INPUT_DW(INPUT_DW),
     .INPUT_FW(INPUT_FW),
     .INPUT_ROW(INPUT_ROW_NUM),
     .INPUT_COLUMN(INPUT_COLUMN_NUM),
     .INPUTNUM_DW(COV1_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV1_DW),
     .OUTPUT_FW(COV1_FW),
     .PROCESS_WIDTH(COV1_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore1_2.dat")
     )theConv1_2(
     .clk(clk),
     .rst(rst),
     .start(Conv1Start),
     .Din(Ram1DataOut),
     .DinAddr(),
     .Dout_en(Cov1_2OutEn),
     .Dout(Cov1_2OutData),
     .DoutStart(Cov1_2OutStart),
     .Finish()
     );
     
 logic signed[COV1_DW-1:0]Relu1_2OutData;
 logic Relu1_2OutEn;
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
 
 logic signed[COV1_DW-1:0]Cov1_3OutData;
    logic Cov1_3OutEn;
    logic Cov1_3OutStart;
    Conv1_Optimize#(
        .COV_CORE_ROW(COV1_CORE_ROW),
        .COV_CORE_COLUMN(COV1_CORE_COLUMN),
        .INPUT_DW(INPUT_DW),
        .INPUT_FW(INPUT_FW),
        .INPUT_ROW(INPUT_ROW_NUM),
        .INPUT_COLUMN(INPUT_COLUMN_NUM),
        .INPUTNUM_DW(COV1_RAM_AW),
        .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
        .COV_CORE_FW(WEIGHT_FW),
        .OUTPUT_DW(COV1_DW),
        .OUTPUT_FW(COV1_FW),
        .PROCESS_WIDTH(COV1_PROCESS_WIDTH),
        .CONV_CORE_DATA_FILE("covcore1_3.dat")
        )theConv1_3(
        .clk(clk),
        .rst(rst),
        .start(Conv1Start),
        .Din(Ram1DataOut),
        .DinAddr(),
        .Dout_en(Cov1_3OutEn),
        .Dout(Cov1_3OutData),
        .DoutStart(Cov1_3OutStart),
        .Finish()
        );
        
    logic signed[COV1_DW-1:0]Relu1_3OutData;
    logic Relu1_3OutEn;
    Relu#(
        .INPUT_DW(COV1_DW),
        .OUTPUT_DW(COV1_DW)
        )theRelu1_3(
        .Din(Cov1_3OutData),
        .Din_en(Cov1_3OutEn),
        .Dout(Relu1_3OutData),
        .Dout_en(Relu1_3OutEn)
        );
    
    logic signed[COV1_DW-1:0]MaxPool1_3OutData;
    logic MaxPool1_3OutEn;
    logic MaxPool1_3OutStart;
    MaxPool#(
        .SIDE_LENGTH(2),
        .STRIDE(2),
        .DATA_ROW(COV1POOL_IN_ROWNUM),
        .DATA_COLUMN(COV1POOL_IN_COLUMNNUM),
        .DATA_WIDTH(COV1_DW),
        .DATA_FW(COV1_FW)
       )theMaxPool1_3(
        .clk(clk),
        .rst(rst),
        .start(Cov1_3OutStart),
        .Din(Relu1_3OutData),
        .Din_en(Relu1_3OutEn),
        .Dout(MaxPool1_3OutData),
        .Dout_en(MaxPool1_3OutEn),
        .DoutStart(MaxPool1_3OutStart),
        .Finish()
       );  
 /************************Layer2**************************/
 
 logic [COV2_RAM_AW-1:0]Layer2Ram1Addr;
 logic Conv2Start;
 logic signed[COV1_DW-1:0]Ram2DataOut[COV2_CORE_ROW];
 ImgRam#(
     .DW(COV1_DW),
     .AW(COV2_RAM_AW),
     .OUTROW_NUM(COV2_CORE_ROW),
     .IMG_ROW(COV1POOL_OUT_ROWNUM),
     .IMG_COLUMN(COV1POOL_OUT_COLUMNNUM)
     )theLayer2Ram1(
     .clk(clk),
     .rst(rst),
     .start(Cov1_1OutStart),
     .InputEn(MaxPool1_1OutEn),
     .InputData(MaxPool1_1OutData),
     .OutputAddr(Layer2Ram1Addr),
     .DataReady(Conv2Start),
     .OutData(Ram2DataOut)  
     );

 logic [COV2_RAM_AW-1:0]Layer2Ram2Addr;
 logic Conv3Start;
 logic signed[COV1_DW-1:0]Ram3DataOut[COV2_CORE_ROW];
 ImgRam#(
     .DW(COV1_DW),
     .AW(COV2_RAM_AW),
     .OUTROW_NUM(COV2_CORE_ROW),
     .IMG_ROW(COV1POOL_OUT_ROWNUM),
     .IMG_COLUMN(COV1POOL_OUT_COLUMNNUM)
     )theLayer2Ram2(
     .clk(clk),
     .rst(rst),
     .start(Cov1_2OutStart),
     .InputEn(MaxPool1_2OutEn),
     .InputData(MaxPool1_2OutData),
     .OutputAddr(Layer2Ram2Addr),
     .DataReady(Conv3Start),
     .OutData(Ram3DataOut)  
     ); 
 
 logic [COV2_RAM_AW-1:0]Layer2Ram3Addr;
     logic Conv4Start;
     logic signed[COV1_DW-1:0]Ram4DataOut[COV2_CORE_ROW];
     ImgRam#(
         .DW(COV1_DW),
         .AW(COV2_RAM_AW),
         .OUTROW_NUM(COV2_CORE_ROW),
         .IMG_ROW(COV1POOL_OUT_ROWNUM),
         .IMG_COLUMN(COV1POOL_OUT_COLUMNNUM)
         )theLayer2Ram3(
         .clk(clk),
         .rst(rst),
         .start(Cov1_3OutStart),
         .InputEn(MaxPool1_3OutEn),
         .InputData(MaxPool1_3OutData),
         .OutputAddr(Layer2Ram3Addr),
         .DataReady(Conv4Start),
         .OutData(Ram4DataOut)  
         ); 
              
 logic signed[COV2_DW-1:0]Cov2_1OutData;
 logic Cov2_1OutEn;
 logic Cov2_1OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_1.dat")
     )theConv2_1(
     .clk(clk),
     .rst(rst),
     .start(Conv2Start),
     .Din(Ram2DataOut),
     .DinAddr(Layer2Ram1Addr),
     .Dout_en(Cov2_1OutEn),
     .Dout(Cov2_1OutData),
     .DoutStart(Cov2_1OutStart),
     .Finish()
     );
     
 logic signed[COV2_DW-1:0]Cov2_2OutData;
 logic Cov2_2OutEn;
 logic Cov2_2OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_2.dat")
     )theConv2_2(
     .clk(clk),
     .rst(rst),
     .start(Conv3Start),
     .Din(Ram3DataOut),
     .DinAddr(Layer2Ram2Addr),
     .Dout_en(Cov2_2OutEn),
     .Dout(Cov2_2OutData),
     .DoutStart(Cov2_2OutStart),
     .Finish()
     );
 logic signed[COV2_DW-1:0]Cov2_3OutData;
     logic Cov2_3OutEn;
     logic Cov2_3OutStart;
     Conv_Op#(
         .COV_CORE_ROW(COV2_CORE_ROW),
         .COV_CORE_COLUMN(COV2_CORE_COLUMN),
         .INPUT_DW(COV1_DW),
         .INPUT_FW(COV1_FW),
         .INPUT_ROW(COV1POOL_OUT_ROWNUM),
         .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
         .INPUTNUM_DW(COV2_RAM_AW),
         .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
         .COV_CORE_FW(WEIGHT_FW),
         .OUTPUT_DW(COV2_DW),
         .OUTPUT_FW(COV2_FW),
         .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
         .CONV_CORE_DATA_FILE("covcore2_3.dat")
         )theConv2_3(
         .clk(clk),
         .rst(rst),
         .start(Conv4Start),
         .Din(Ram4DataOut),
         .DinAddr(Layer2Ram3Addr),
         .Dout_en(Cov2_3OutEn),
         .Dout(Cov2_3OutData),
         .DoutStart(Cov2_3OutStart),
         .Finish()
         );   
 logic signed[COV2_SIGMOID_DW-1:0]Sigmoid2_1OutData;
 (*mark_debug = "true"*)logic Sigmoid2_1OutEn;    
 Sigmoid#(
     .INPUT_DW(COV2_DW),
     .INPUT_FW(COV2_FW),
     .OUTPUT_DW(COV2_SIGMOID_DW),
     .OUTPUT_FW(COV2_FW)
     )theSigmoid2_1(
     .Din(Cov2_1OutData + Cov2_2OutData + Cov2_3OutData),
     .Din_en(Cov2_1OutEn),
     .Dout(Sigmoid2_1OutData),
     .Dout_en(Sigmoid2_1OutEn)
     );
 
 logic signed[COV2_SIGMOID_DW-1:0]MaxPool2_1OutData;
 logic MaxPool2_1OutEn;
 logic MaxPool2_1OutStart;
 MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV2POOL_IN_ROWNUM),
     .DATA_COLUMN(COV2POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV2_SIGMOID_DW),
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
     
 logic signed[COV2_DW-1:0]Cov2_4OutData;
 logic Cov2_4OutEn;
 logic Cov2_4OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_4.dat")
     )theConv2_4(
     .clk(clk),
     .rst(rst),
     .start(Conv2Start),
     .Din(Ram2DataOut),
     .DinAddr(),
     .Dout_en(Cov2_4OutEn),
     .Dout(Cov2_4OutData),
     .DoutStart(Cov2_4OutStart),
     .Finish()
     );
     
 logic signed[COV2_DW-1:0]Cov2_5OutData;
 logic Cov2_5OutEn;
 logic Cov2_5OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_5.dat")
     )theConv2_5(
     .clk(clk),
     .rst(rst),
     .start(Conv3Start),
     .Din(Ram3DataOut),
     .DinAddr(),
     .Dout_en(Cov2_5OutEn),
     .Dout(Cov2_5OutData),
     .DoutStart(Cov2_5OutStart),
     .Finish()
     );      
 
 logic signed[COV2_DW-1:0]Cov2_6OutData;
     logic Cov2_6OutEn;
     logic Cov2_6OutStart;
     Conv_Op#(
         .COV_CORE_ROW(COV2_CORE_ROW),
         .COV_CORE_COLUMN(COV2_CORE_COLUMN),
         .INPUT_DW(COV1_DW),
         .INPUT_FW(COV1_FW),
         .INPUT_ROW(COV1POOL_OUT_ROWNUM),
         .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
         .INPUTNUM_DW(COV2_RAM_AW),
         .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
         .COV_CORE_FW(WEIGHT_FW),
         .OUTPUT_DW(COV2_DW),
         .OUTPUT_FW(COV2_FW),
         .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
         .CONV_CORE_DATA_FILE("covcore2_6.dat")
         )theConv2_6(
         .clk(clk),
         .rst(rst),
         .start(Conv4Start),
         .Din(Ram4DataOut),
         .DinAddr(),
         .Dout_en(Cov2_6OutEn),
         .Dout(Cov2_6OutData),
         .DoutStart(Cov2_6OutStart),
         .Finish()
         );
     
 logic signed[COV2_SIGMOID_DW-1:0]Sigmoid2_2OutData;
 logic Sigmoid2_2OutEn;    
 Sigmoid#(
     .INPUT_DW(COV2_DW),
     .INPUT_FW(COV2_FW),
     .OUTPUT_DW(COV2_SIGMOID_DW),
     .OUTPUT_FW(COV2_FW)
     )theSigmoid2_2(
     .Din(Cov2_4OutData + Cov2_5OutData + Cov2_6OutData),
     .Din_en(Cov2_4OutEn),
     .Dout(Sigmoid2_2OutData),
     .Dout_en(Sigmoid2_2OutEn)
     );
 
 logic signed[COV2_SIGMOID_DW-1:0]MaxPool2_2OutData;
 logic MaxPool2_2OutEn;
 logic MaxPool2_2OutStart;
  MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV2POOL_IN_ROWNUM),
     .DATA_COLUMN(COV2POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV2_SIGMOID_DW),
     .DATA_FW(COV2_FW)
     )theMaxPool2_2(
     .clk(clk),
     .rst(rst),
     .start(Cov2_4OutStart),
     .Din(Sigmoid2_2OutData),
     .Din_en(Sigmoid2_2OutEn),
     .Dout(MaxPool2_2OutData),
     .Dout_en(MaxPool2_2OutEn),
     .DoutStart(MaxPool2_2OutStart),
     .Finish()
     ); 
     
 logic signed[COV2_DW-1:0]Cov2_7OutData;
 logic Cov2_7OutEn;
 logic Cov2_7OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_7.dat")
     )theConv2_7(
     .clk(clk),
     .rst(rst),
     .start(Conv2Start),
     .Din(Ram2DataOut),
     .DinAddr(),
     .Dout_en(Cov2_7OutEn),
     .Dout(Cov2_7OutData),
     .DoutStart(Cov2_7OutStart),
     .Finish()
     );
     
 logic signed[COV2_DW-1:0]Cov2_8OutData;
 logic Cov2_8OutEn;
 logic Cov2_8OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_8.dat")
     )theConv2_8(
     .clk(clk),
     .rst(rst),
     .start(Conv3Start),
     .Din(Ram3DataOut),
     .DinAddr(),
     .Dout_en(Cov2_8OutEn),
     .Dout(Cov2_8OutData),
     .DoutStart(Cov2_8OutStart),
     .Finish()
     );

 logic signed[COV2_DW-1:0]Cov2_9OutData;
 logic Cov2_9OutEn;
 logic Cov2_9OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_9.dat")
     )theConv2_9(
     .clk(clk),
     .rst(rst),
     .start(Conv4Start),
     .Din(Ram4DataOut),
     .DinAddr(),
     .Dout_en(Cov2_9OutEn),
     .Dout(Cov2_9OutData),
     .DoutStart(Cov2_9OutStart),
     .Finish()
     ); 
  
 logic signed[COV2_SIGMOID_DW-1:0]Sigmoid2_3OutData;
 logic Sigmoid2_3OutEn;    
 Sigmoid#(
     .INPUT_DW(COV2_DW),
     .INPUT_FW(COV2_FW),
     .OUTPUT_DW(COV2_SIGMOID_DW),
     .OUTPUT_FW(COV2_FW)
     )theSigmoid2_3(
     .Din(Cov2_7OutData + Cov2_8OutData + Cov2_9OutData),
     .Din_en(Cov2_7OutEn),
     .Dout(Sigmoid2_3OutData),
     .Dout_en(Sigmoid2_3OutEn)
     );
 
 logic signed[COV2_SIGMOID_DW-1:0]MaxPool2_3OutData;
 logic MaxPool2_3OutEn;
 logic MaxPool2_3OutStart;
 MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV2POOL_IN_ROWNUM),
     .DATA_COLUMN(COV2POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV2_SIGMOID_DW),
     .DATA_FW(COV2_FW)
     )theMaxPool2_3(
     .clk(clk),
     .rst(rst),
     .start(Cov2_7OutStart),
     .Din(Sigmoid2_3OutData),
     .Din_en(Sigmoid2_3OutEn),
     .Dout(MaxPool2_3OutData),
     .Dout_en(MaxPool2_3OutEn),
     .DoutStart(MaxPool2_3OutStart),
     .Finish()
     );  

 logic signed[COV2_DW-1:0]Cov2_10OutData;
 logic Cov2_10OutEn;
 logic Cov2_10OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_10.dat")
     )theConv2_10(
     .clk(clk),
     .rst(rst),
     .start(Conv2Start),
     .Din(Ram2DataOut),
     .DinAddr(),
     .Dout_en(Cov2_10OutEn),
     .Dout(Cov2_10OutData),
     .DoutStart(Cov2_10OutStart),
     .Finish()
     );
     
 logic signed[COV2_DW-1:0]Cov2_11OutData;
 logic Cov2_11OutEn;
 logic Cov2_11OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_11.dat")
     )theConv2_11(
     .clk(clk),
     .rst(rst),
     .start(Conv3Start),
     .Din(Ram3DataOut),
     .DinAddr(),
     .Dout_en(Cov2_11OutEn),
     .Dout(Cov2_11OutData),
     .DoutStart(Cov2_11OutStart),
     .Finish()
     );

 logic signed[COV2_DW-1:0]Cov2_12OutData;
 logic Cov2_12OutEn;
 logic Cov2_12OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_12.dat")
     )theConv2_12(
     .clk(clk),
     .rst(rst),
     .start(Conv4Start),
     .Din(Ram4DataOut),
     .DinAddr(),
     .Dout_en(Cov2_12OutEn),
     .Dout(Cov2_12OutData),
     .DoutStart(Cov2_12OutStart),
     .Finish()
     ); 
  
 logic signed[COV2_SIGMOID_DW-1:0]Sigmoid2_4OutData;
 logic Sigmoid2_4OutEn;    
 Sigmoid#(
     .INPUT_DW(COV2_DW),
     .INPUT_FW(COV2_FW),
     .OUTPUT_DW(COV2_SIGMOID_DW),
     .OUTPUT_FW(COV2_FW)
     )theSigmoid2_4(
     .Din(Cov2_10OutData + Cov2_11OutData + Cov2_12OutData),
     .Din_en(Cov2_10OutEn),
     .Dout(Sigmoid2_4OutData),
     .Dout_en(Sigmoid2_4OutEn)
     );
 
 logic signed[COV2_SIGMOID_DW-1:0]MaxPool2_4OutData;
 logic MaxPool2_4OutEn;
 logic MaxPool2_4OutStart;
 MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV2POOL_IN_ROWNUM),
     .DATA_COLUMN(COV2POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV2_SIGMOID_DW),
     .DATA_FW(COV2_FW)
     )theMaxPool2_4(
     .clk(clk),
     .rst(rst),
     .start(Cov2_10OutStart),
     .Din(Sigmoid2_4OutData),
     .Din_en(Sigmoid2_4OutEn),
     .Dout(MaxPool2_4OutData),
     .Dout_en(MaxPool2_4OutEn),
     .DoutStart(MaxPool2_4OutStart),
     .Finish()
     );  

 logic signed[COV2_DW-1:0]Cov2_13OutData;
 logic Cov2_13OutEn;
 logic Cov2_13OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_13.dat")
     )theConv2_13(
     .clk(clk),
     .rst(rst),
     .start(Conv2Start),
     .Din(Ram2DataOut),
     .DinAddr(),
     .Dout_en(Cov2_13OutEn),
     .Dout(Cov2_13OutData),
     .DoutStart(Cov2_13OutStart),
     .Finish()
     );
     
 logic signed[COV2_DW-1:0]Cov2_14OutData;
 logic Cov2_14OutEn;
 logic Cov2_14OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_14.dat")
     )theConv2_14(
     .clk(clk),
     .rst(rst),
     .start(Conv3Start),
     .Din(Ram3DataOut),
     .DinAddr(),
     .Dout_en(Cov2_14OutEn),
     .Dout(Cov2_14OutData),
     .DoutStart(Cov2_14OutStart),
     .Finish()
     );

 logic signed[COV2_DW-1:0]Cov2_15OutData;
 logic Cov2_15OutEn;
 logic Cov2_15OutStart;
 Conv_Op#(
     .COV_CORE_ROW(COV2_CORE_ROW),
     .COV_CORE_COLUMN(COV2_CORE_COLUMN),
     .INPUT_DW(COV1_DW),
     .INPUT_FW(COV1_FW),
     .INPUT_ROW(COV1POOL_OUT_ROWNUM),
     .INPUT_COLUMN(COV1POOL_OUT_COLUMNNUM),
     .INPUTNUM_DW(COV2_RAM_AW),
     .COV_CORE_DW(WEIGHT_DW),   //    Q6.10
     .COV_CORE_FW(WEIGHT_FW),
     .OUTPUT_DW(COV2_DW),
     .OUTPUT_FW(COV2_FW),
     .PROCESS_WIDTH(COV2_PROCESS_WIDTH),
     .CONV_CORE_DATA_FILE("covcore2_15.dat")
     )theConv2_15(
     .clk(clk),
     .rst(rst),
     .start(Conv4Start),
     .Din(Ram4DataOut),
     .DinAddr(),
     .Dout_en(Cov2_15OutEn),
     .Dout(Cov2_15OutData),
     .DoutStart(Cov2_15OutStart),
     .Finish()
     ); 
  
 logic signed[COV2_SIGMOID_DW-1:0]Sigmoid2_5OutData;
 logic Sigmoid2_5OutEn;    
 Sigmoid#(
     .INPUT_DW(COV2_DW),
     .INPUT_FW(COV2_FW),
     .OUTPUT_DW(COV2_SIGMOID_DW),
     .OUTPUT_FW(COV2_FW)
     )theSigmoid2_5(
     .Din(Cov2_13OutData + Cov2_14OutData + Cov2_15OutData),
     .Din_en(Cov2_13OutEn),
     .Dout(Sigmoid2_5OutData),
     .Dout_en(Sigmoid2_5OutEn)
     );
 
 logic signed[COV2_SIGMOID_DW-1:0]MaxPool2_5OutData;
 logic MaxPool2_5OutEn;
 logic MaxPool2_5OutStart;
 MaxPool#(
     .SIDE_LENGTH(2),
     .STRIDE(2),
     .DATA_ROW(COV2POOL_IN_ROWNUM),
     .DATA_COLUMN(COV2POOL_IN_COLUMNNUM),
     .DATA_WIDTH(COV2_SIGMOID_DW),
     .DATA_FW(COV2_FW)
     )theMaxPool2_5(
     .clk(clk),
     .rst(rst),
     .start(Cov2_13OutStart),
     .Din(Sigmoid2_5OutData),
     .Din_en(Sigmoid2_5OutEn),
     .Dout(MaxPool2_5OutData),
     .Dout_en(MaxPool2_5OutEn),
     .DoutStart(MaxPool2_5OutStart),
     .Finish()
     );  
   
 FullConnect#(
     .INPUT_DATA_WIDTH(COV2_SIGMOID_DW),
     .INPUT_DATA_FW(COV2_FW),
     .INPUT_WEIGHT_WIDTH(WEIGHT_DW),
     .INPUT_DATA_POOLING_NUM(COV2_DEPTH),
     .INPUT_DATA_POOLING_CNT(FC_IN_DATANUM),
     .OUTPUT_WIDTH(OUTPUT_DW),
     .PROCESS_WIDTH(FC_DW),
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
     .pooling2_4_output_data(MaxPool2_4OutData),
     .pooling2_5_output_data(MaxPool2_5OutData),
     .OutEn(Dout_en),
     .led(Dout)
     );
endmodule
