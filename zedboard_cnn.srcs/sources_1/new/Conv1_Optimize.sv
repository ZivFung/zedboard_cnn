`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2018 07:21:16 PM
// Design Name: 
// Module Name: Conv1_Optimize
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


module Conv1_Optimize#(
    COV_CORE_ROW = 5,
    COV_CORE_COLUMN = 5,
    INPUT_DW = 2,
    INPUT_FW = 0,
    INPUT_ROW = 32,
    INPUT_COLUMN = 32,
    INPUTNUM_DW = 10,
    COV_CORE_DW = 16,   //    Q6.10
    COV_CORE_FW = 10,
    OUTPUT_DW = 16,
    OUTPUT_FW = 10,
    PROCESS_WIDTH = 12,
    CONV_CORE_DATA_FILE = "conv_core.dat"
    )(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [INPUT_DW-1:0]Din[COV_CORE_ROW],
    output logic [INPUTNUM_DW-1:0]DinAddr,
    output logic Dout_en,
    output logic signed[OUTPUT_DW-1:0]Dout,
    output logic DoutStart,
    output logic Finish
    );
    localparam INPUT_NUM = INPUT_COLUMN * INPUT_ROW;
    localparam CORENUM = COV_CORE_ROW * COV_CORE_COLUMN;
    localparam CORENUM_WIDTH = $clog2(CORENUM);
    localparam COREROW_WIDTH = $clog2(COV_CORE_ROW);
    localparam CONVSHIFTER_NUM = (COV_CORE_COLUMN - 1) * COV_CORE_ROW;  
    localparam SHIFTER_COLUMN_NUM = INPUT_ROW - COV_CORE_ROW + 1;
    localparam SHIFTER_ROW_NUM = INPUT_ROW - COV_CORE_ROW + 1;
    localparam COLUMN_WIDTH = $clog2(SHIFTER_COLUMN_NUM);
    localparam ROW_WIDTH = $clog2(SHIFTER_ROW_NUM); 
    localparam MULT_WIDTH = INPUT_DW + COV_CORE_DW;
    
    assign DoutStart = start;
    assign Finish = PixelFinish;
    reg signed[COV_CORE_DW-1:0]ConvCoreData[0:CORENUM-1];initial $readmemh(CONV_CORE_DATA_FILE,ConvCoreData,0,CORENUM-1);
    logic signed[COV_CORE_DW-1:0]CoreData[CORENUM];
    logic [CORENUM_WIDTH-1:0]CoreReadIndex;

    always_ff@(posedge clk)begin
      if(rst)CoreReadIndex <= 0;
      else if(CoreReadIndex < CORENUM)
        CoreReadIndex <= CoreReadIndex + 1;
      else CoreReadIndex <= CoreReadIndex;
    end
    
    always_ff@(posedge clk)begin
      if(rst)CoreData <= '{CORENUM{'0}};
      else begin
        if(CoreReadIndex < CORENUM)
          CoreData[CoreReadIndex] <= ConvCoreData[CoreReadIndex];
      end
    end
    
    logic [1:0]ConvState;
    always_ff@(posedge clk)begin
      if(rst)ConvState <= 0;
      else begin
        case(ConvState)
          0:begin
            if(start)ConvState <= 1;
            else ConvState <= ConvState;
          end
          1:begin
            if(PixelFinish)ConvState <= 2;
            else ConvState <= ConvState;
          end
          2:begin
            ConvState <= 0;
          end
        endcase
      end
    end
    
    logic ShifterCo1,ShifterCo2;
    logic ShifterEn;
    logic PixelFinish;
    logic [COREROW_WIDTH-1:0]ShifterIndex;
    logic [COLUMN_WIDTH-1:0]ColumnIndex;
    logic ColumnCo;
    logic [ROW_WIDTH-1:0]RowIndex;
    Counter2#(COV_CORE_COLUMN)ShifterCnt(clk,rst,ShifterEn,ShifterIndex,ShifterCo1,ShifterCo2);
    Counter#(SHIFTER_COLUMN_NUM)ColumnCnt(clk,rst,ShifterCo1,ColumnIndex,ColumnCo);
    Counter#(SHIFTER_ROW_NUM)PixelCnt(clk,rst,ColumnCo,RowIndex,PixelFinish);
    assign ShifterEn = ConvState == 1;
    
    logic [PROCESS_WIDTH-1:0]ConvShifter[CONVSHIFTER_NUM];
    logic signed[PROCESS_WIDTH-1:0]Mult[COV_CORE_ROW];
    logic signed[COV_CORE_DW-1:0]MultWeight[COV_CORE_ROW];
    
    generate
      for(genvar k = 0 ; k < COV_CORE_ROW ; k++)begin : Multiply
        assign Mult[k] = MULT_WIDTH'(MultWeight[k] * Din[k]) >>> (COV_CORE_FW + INPUT_FW - OUTPUT_FW);
      end
    endgenerate
    
    always_ff@(posedge clk)begin
      if(rst)DinAddr <= 0;
      else begin
        if(ShifterEn)DinAddr <= RowIndex * INPUT_COLUMN + ColumnIndex + ShifterIndex;
      end
    end
    
    generate
      for(genvar k = 0 ; k < COV_CORE_ROW ; k++)begin : Weight
        always_ff@(posedge clk)begin
          if(rst)MultWeight[k] <= '0;
          else MultWeight[k] <= CoreData[ShifterIndex + k * COV_CORE_COLUMN];
        end
      end 
    endgenerate
    
    generate
      for(genvar k = 0 ; k < COV_CORE_ROW ; k++)begin : Shifter 
        always_ff@(posedge clk)begin
          if(rst)ConvShifter[k*(COV_CORE_ROW-1):(k+1)*(COV_CORE_ROW-1)-1] <= '{(COV_CORE_ROW-1){'0}};
          else begin
            if(ShifterEn)begin
              ConvShifter[k*(COV_CORE_ROW-1):(k+1)*(COV_CORE_ROW-1)-1] <= 
                         {Mult[k],ConvShifter[k*(COV_CORE_ROW-1):(k+1)*(COV_CORE_ROW-1)-2]};
            end
          end
        end
      end
    endgenerate
    
    logic signed [OUTPUT_DW-1:0]RowAdder[COV_CORE_ROW-1:0]; 
    logic signed [OUTPUT_DW-1:0]ParallelAdder;
    generate 
      for(genvar k = 0; k < COV_CORE_ROW; k++)begin : AddrRows
        assign RowAdder[k] =Mult[k] + ConvShifter[k * (COV_CORE_COLUMN-1)] + ConvShifter[k * (COV_CORE_COLUMN-1)+1] +
                           ConvShifter[k * (COV_CORE_COLUMN-1)+2] + ConvShifter[k * (COV_CORE_COLUMN-1)+3];
      end
    endgenerate 
    assign ParallelAdder = RowAdder[0] + RowAdder[1] + RowAdder[2] + RowAdder[3] + RowAdder[4];
    
    always_ff@(posedge clk)begin
      if(rst)begin Dout <= '0;Dout_en <= 0;end
      else begin
        if(ShifterCo2)begin
          Dout_en <= 1;
          Dout <= ParallelAdder;
        end
        else begin
          Dout_en <= 0;
          Dout <= 0;
        end
      end
    end
    
endmodule
