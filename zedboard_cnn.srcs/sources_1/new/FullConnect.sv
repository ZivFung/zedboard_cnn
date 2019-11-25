`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2018 01:42:16 PM
// Design Name: 
// Module Name: FullConnect
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


module FullConnect#(
    parameter INPUT_DATA_WIDTH = 16,
    parameter INPUT_DATA_FW = 10,
    parameter INPUT_WEIGHT_WIDTH = 16,
    parameter INPUT_DATA_POOLING_NUM = 5,
    parameter INPUT_DATA_POOLING_CNT = 25,
    parameter OUTPUT_WIDTH = 10,
    parameter PROCESS_WIDTH = 18,
    parameter FCW_FILE = "fc1_core.dat",
    parameter FCB_FILE = "FCBData.dat"
    )(
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed[INPUT_DATA_WIDTH - 1:0]pooling2_1_output_data,
    input wire pooling_data_input_en,
    input wire signed[INPUT_DATA_WIDTH - 1:0]pooling2_2_output_data,
    input wire signed[INPUT_DATA_WIDTH - 1:0]pooling2_3_output_data,
    input wire signed[INPUT_DATA_WIDTH - 1:0]pooling2_4_output_data,
    input wire signed[INPUT_DATA_WIDTH - 1:0]pooling2_5_output_data,
    output logic OutEn,
    output logic [OUTPUT_WIDTH-1:0]led
    );
    localparam INPUTNUM = INPUT_DATA_POOLING_CNT*INPUT_DATA_POOLING_NUM;
    localparam CORENUM = INPUTNUM*OUTPUT_WIDTH;
    localparam BiasCntWidth = $clog2(OUTPUT_WIDTH);
    
    logic [2:0]FCState;
    logic [$clog2(INPUT_DATA_POOLING_CNT)-1:0]InputCnt;
    reg signed[INPUT_WEIGHT_WIDTH-1:0]FCCoreData[0:CORENUM-1];initial $readmemh(FCW_FILE, FCCoreData,0,CORENUM-1);
    reg signed [INPUT_WEIGHT_WIDTH-1:0]FCBias[0:OUTPUT_WIDTH-1];initial $readmemh(FCB_FILE, FCBias,0,OUTPUT_WIDTH-1);
    logic signed[INPUT_DATA_WIDTH-1:0]FCInputData[INPUTNUM];
    logic signed[INPUT_WEIGHT_WIDTH-1:0]FCBiasData[OUTPUT_WIDTH];
    
    logic [BiasCntWidth-1:0]BiasCnt;
//    Counter#(OUTPUT_WIDTH)BiasReadCnt(clk,rst,1,BiasCnt,);
    always_ff@(posedge clk)begin
      if(rst)BiasCnt <= 0;
      else if(BiasCnt < OUTPUT_WIDTH)
        BiasCnt <= BiasCnt + 1;
      else BiasCnt <= BiasCnt;
    end
    always_ff@(posedge clk)begin
      if(rst)FCBiasData<='{OUTPUT_WIDTH{'0}};
      else begin
        if(BiasCnt < OUTPUT_WIDTH)
          FCBiasData[BiasCnt] <= FCBias[BiasCnt];
      end
    end
    
    always_ff@(posedge clk)begin
      if(rst)begin FCState <= 0;InputCnt <= 0;FCInputData <= '{INPUTNUM{'0}};end
      else begin
        case(FCState)
          0:begin
              if(start)FCState <= 1;
              else begin FCState <= FCState;InputCnt <= 0;end
          end
          1:begin
              if(InputCnt < INPUT_DATA_POOLING_CNT)begin
                if(pooling_data_input_en)begin
                  FCInputData[5*InputCnt] <= pooling2_1_output_data;
                  FCInputData[5*InputCnt+1] <= pooling2_2_output_data;
                  FCInputData[5*InputCnt+2] <= pooling2_3_output_data;
                  FCInputData[5*InputCnt+3] <= pooling2_4_output_data;
                  FCInputData[5*InputCnt+4] <= pooling2_5_output_data;
                  InputCnt <= InputCnt + 1;
                end
              end
              else FCState <= 2;
          end
          2:begin
              FCState <= 0;
          end
        endcase
      end
    end
    
    (*mark_debug = "true"*)logic [$clog2(INPUT_DATA_POOLING_NUM*INPUT_DATA_POOLING_CNT*OUTPUT_WIDTH)-1:0]MulCnt;
    logic signed[INPUT_WEIGHT_WIDTH-1:0]Coeff;
    logic signed[INPUT_DATA_WIDTH-1:0]NetOut;
    wire  signed[PROCESS_WIDTH-1:0]MulResult =
     (INPUT_WEIGHT_WIDTH+INPUT_DATA_WIDTH)'(Coeff * NetOut) >>> INPUT_DATA_FW;
//       28'sd1* Coeff * NetOut >>> INPUT_DATA_FW;
    logic signed[PROCESS_WIDTH-1:0]Sum[OUTPUT_WIDTH];
    logic [$clog2(OUTPUT_WIDTH)-1:0]ResultCnt;
    always_ff@(posedge clk)begin
     if(rst)begin ResultCnt <= 0;end
     else begin
       if(MulCnt == INPUTNUM-1 | MulCnt == INPUTNUM*2-1 | MulCnt == INPUTNUM*3-1 | MulCnt == INPUTNUM*4-1
          | MulCnt == INPUTNUM*5-1 | MulCnt == INPUTNUM*6-1 | MulCnt == INPUTNUM*7-1 | MulCnt == INPUTNUM*8-1
          | MulCnt == INPUTNUM*9-1 | MulCnt == INPUTNUM*10-1)begin
         ResultCnt <= ResultCnt + 1;
       end
     end
    end
    
    always_ff@(posedge clk)begin
      if(rst)begin MulCnt <= 0;Sum <= '{OUTPUT_WIDTH{'0}};Coeff <= 0;NetOut <= 0;end
      else begin
        if((FCState == 2) & (MulCnt == 0))begin
          Coeff <= FCCoreData[MulCnt];
          NetOut <= FCInputData[MulCnt-ResultCnt*INPUTNUM];
          MulCnt <= 1;
        end

        else if((MulCnt > 0) & (MulCnt < INPUT_DATA_POOLING_NUM*INPUT_DATA_POOLING_CNT*OUTPUT_WIDTH))begin
          Coeff <= FCCoreData[MulCnt];
          NetOut <= FCInputData[MulCnt-ResultCnt*INPUTNUM];
          MulCnt <= MulCnt + 1;
          Sum[ResultCnt] <= Sum[ResultCnt] + MulResult;
        end
        else if(MulCnt == INPUT_DATA_POOLING_NUM*INPUT_DATA_POOLING_CNT*OUTPUT_WIDTH)begin Sum[ResultCnt] <= Sum[ResultCnt] + MulResult;MulCnt <= MulCnt +1; end
        else MulCnt <= 0;
      end
    end
    logic signed [PROCESS_WIDTH-1:0]ReluOut[OUTPUT_WIDTH];
//    logic ReluOutEn[OUTPUT_WIDTH];
    
//    generate 
//      for(genvar k = 0;k < OUTPUT_WIDTH;k++) begin : Relus
//           Relu#(
//           .INPUT_DW(PROCESS_WIDTH),
//           .OUTPUT_DW(PROCESS_WIDTH)
//           )theFCRelu(
//           .Din(Sum[k]+FCBiasData[k]),
//           .Din_en(MulCnt == INPUT_DATA_POOLING_NUM*INPUT_DATA_POOLING_CNT*OUTPUT_WIDTH),
//           .Dout(ReluOut[k]),
//           .Dout_en(ReluOutEn[k])
//           );  
//      end
//    endgenerate
    
//    generate
//      for(genvar k = 0;k < OUTPUT_WIDTH;k++) begin : ASSI
//        assign led[k] = (ReluOutEn[k])?(ReluOut[k] > 1024)?1:0:0;
//      end
//    endgenerate
    logic signed[PROCESS_WIDTH-1:0]ReluOutReg[OUTPUT_WIDTH];
    generate
      for(genvar k = 0;k < OUTPUT_WIDTH;k++) begin : ASSI
        always_ff@(posedge clk)begin
          if(rst)ReluOutReg[k] <= 0;
          else if(MulCnt == INPUT_DATA_POOLING_NUM*INPUT_DATA_POOLING_CNT*OUTPUT_WIDTH)ReluOutReg[k] <= Sum[k]+FCBiasData[k];
        end
      end
    endgenerate
    
    logic [$clog2(OUTPUT_WIDTH)-1:0]CmpCnt;
    (*mark_debug = "true"*)logic [$clog2(OUTPUT_WIDTH)-1:0]MaxCnt;
    (*mark_debug = "true"*)logic signed[PROCESS_WIDTH-1:0]Max;
    logic [1:0]CmpState;
    
    always_ff@(posedge clk)begin
      if(rst)begin CmpState <= 0;Max <= -18'sd131072;CmpCnt <= 0;MaxCnt <= 0;end
      else begin
        case(CmpState)
          0:if(MulCnt == INPUT_DATA_POOLING_NUM*INPUT_DATA_POOLING_CNT*OUTPUT_WIDTH)CmpState <= 1;
            else begin CmpState <= CmpState;Max <= -18'sd131072;CmpCnt <= 0;MaxCnt <= 0;end
          1:begin
            if(CmpCnt == OUTPUT_WIDTH)CmpState <= 2;
            else if(ReluOutReg[CmpCnt] > Max)begin
              Max <= ReluOutReg[CmpCnt];
              MaxCnt <= CmpCnt + 1;
              CmpCnt <= CmpCnt + 1;
            end
            else begin CmpState <= CmpState;CmpCnt <= CmpCnt + 1;end
          end
          2:CmpState <= 0;
        endcase
      end
    end
    
    assign led = (CmpState==2)?((MaxCnt==0)? 0:(1 << (MaxCnt-1))):0;
    assign OutEn = (CmpState==2);
endmodule
