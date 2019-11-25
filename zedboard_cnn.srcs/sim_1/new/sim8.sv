`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2018 03:07:28 PM
// Design Name: 
// Module Name: sim8
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


module sim8(

    );
    reg clk;initial clk=0;
    reg rst;initial begin rst =0;#20 rst = 1;#40 rst = 0;#501100 rst = 1;#40 rst =0;  end
    always #5 clk=~clk;
    reg addrrst;initial begin addrrst = 0;#400 addrrst = 1;#40 addrrst = 0;end 
    
    reg clk25m;initial clk25m = 0;
    always #20 clk25m = ~clk25m;
//    reg [1:0]Clk25mCnt;
//    always_ff@(posedge clk)begin
//      if(rst)Clk25mCnt <= 0;
//      else
//      Clk25mCnt <= Clk25mCnt + 1;
//    end
//    wire clk25m = Clk25mCnt > 1;
//    wire Clk25mEn = Clk25mCnt == 2;
    reg mode;initial begin mode = 0;#200 mode = 1;#1000 mode = 0;#500000 mode = 1;#100 mode = 0; end
    
    reg [7:0]Zreg[1023:0];initial $readmemh("seven130.dat", Zreg);
    logic z_in;
    logic z_in_en;
    
    logic [10:0]ZRdCnt;
    reg [1:0]mode_capture;
    
    always_ff@(posedge clk25m)begin
      mode_capture <= {mode_capture[0],mode};
    end
    wire mode_rise = mode_capture == 2'b01;
    reg start;
    reg [11:0]test;initial test =12'hddd;
    wire [11:0]test1 = ~test;
    always_ff@(posedge clk25m)start <= rst;
    logic [18:0]VgaAddr;
//    logic IdentifyStart;
    Counter#(307200)IdentifyCnt(clk25m,addrrst,1,VgaAddr,);  
    logic [1:0]state;
    always_ff@(posedge clk25m)begin
      if(rst)state <= 0;
      else begin
        case(state)
          0:begin
            if(mode_rise)state <= 1;
          end
          1:begin
            if(ZRdCnt == 1024)state <= 0;
          end
        endcase
      end
    end
    
    always_ff@(posedge clk25m)begin
    if(rst | mode_rise)begin ZRdCnt <= 0;z_in <= 0;z_in_en <= 0;end
    else begin
      if(ZRdCnt < 1024 & state == 1)begin
        z_in_en <= 1;
        z_in <= Zreg[ZRdCnt]>8'd100 ? 1:0;
        ZRdCnt <= ZRdCnt + 1;
      end
      else if(ZRdCnt == 1024)begin ZRdCnt <= 0;z_in_en <= 0; end
      else begin 
        ZRdCnt <= ZRdCnt;
        z_in_en <= 0;
      end
    end
    end
    reg [7:0]img_data[307199:0];initial $readmemh("img_input.dat",img_data);
    reg [11:0]ram_data_delay;
    
    reg [11:0]ram_data_in;
    wire [18:0]ram_addr_out;
    always_ff@(posedge clk25m)begin
      ram_data_delay <= (img_data[ram_addr_out] > 0)? 12'hFFF:0;
      ram_data_in <= ram_data_delay;
    end  
    wire [11:0]resizeDout;
    wire Den;
    wire [11:0]ResizWrData;
    wire [18:0]ResizWrAddr;  
    logic ResizWrEn;
    Resizeimg25M#(                    //Nearest interpolation
        .INPUT_DW(12),
        .RAM_AW(19),
        .INPUT_ROWNUM(480),
        .INPUT_COLUMNNUM(640),
        .OUTPUT_ROWNUM(32),
        .OUTPUT_COLUMNNUM(32),
        .OUTPUT_DW(12)
        )theResize(
        .clk(clk25m),
//        .Clk25m(clk25m),
        .rst(rst),
        .start(mode_rise),
        .ImageIn(ram_data_in),
        .VgaAddrIn(VgaAddr),
        .ResizWrAddr(ResizWrAddr),
        .ResizWrData(ResizWrData),
        .ResizWrEn(ResizWrEn),
//        .AddrOut(ram_addr_out),
        .ImgOut(resizeDout),
        .OutEn(Den)
        );
      wire [7:0]GrayImgData;
        wire GrayDataEn;
        RGB2Gray#(
            .R_DW(4),
            .G_DW(4),
            .B_DW(4),
            .GRAY_DW(8),
            .SCALE_W(0)
            )theRGB2Gray(
            .InputEn(Den),
            .R(resizeDout[11:8]),
            .G(resizeDout[7:4]),
            .B(resizeDout[3:0]),
            .OutputEn(GrayDataEn),
            .Gray(GrayImgData)
            );
        
        wire [7:0]EdgeImgData;
        wire EdgeDataEn; 
        wire EdgeDataStart;  
//        wire [11:0]EdgeWrData;
//        wire [18:0]EdgeWrAddr;
        EdgeSobelApprox#(
            .ROW_NUM(32),
            .COLUMN_NUM(32),
            .INPUT_DW(8),
            .OUTPUT_DW(1),
            .T(28)       
        )theEdge(
            .clk(clk),
            .rst(rst), 
            .start(mode_rise),          
            .InputEn(GrayDataEn),
            .InputData(GrayImgData),
//            .EdgeWrAddr(EdgeWrAddr),
//            .EdgeWrData(EdgeWrData),
            .OutputStart(EdgeDataStart),
            .OutputEn(EdgeDataEn),
            .OutputData(EdgeImgData)
            );
    logic [9:0]dout;
    logic dout_en;
Cnn_Optimize#(
     .INPUT_DW(1),
     .INPUT_FW(0),
     .INPUT_ROW_NUM(32),
     .INPUT_COLUMN_NUM(32),
     .OUTPUT_DW(10)
    )theCNN(
     .clk(clk25m),
     .rst(rst),
     .start(mode_rise),
     .Din(z_in),
     .Din_en(z_in_en),
     .Dout_en(dout_en),
     .Dout(dout)
     );   
//logic ConvStart;
//logic [9:0]ConvAddr;
//logic signed[1:0]RamDataOut[5];
//ImgRam#(
//    .DW(2),
//    .AW(10),
//    .OUTROW_NUM(5),
//    .IMG_ROW(32),
//    .IMG_COLUMN(32)
//    )ram(
//    .clk(clk),
//    .rst(rst),
//    .start(mode_rise),
//    .InputEn(z_in_en),
//    .InputData(z_in),
//    .OutputAddr(ConvAddr),
//    .DataReady(ConvStart),
//    .OutEn(),
//    .OutData(RamDataOut)  
//    );
//    logic Dout_en;
//    logic signed[15:0]Dout;
//    logic Finish;
//Conv_Op#(
//    .COV_CORE_ROW(5),
//    .COV_CORE_COLUMN(5),
//    .INPUT_DW(2),
//    .INPUT_FW(0),
//    .INPUT_ROW(32),
//    .INPUT_NUM(1024),
//    .INPUTNUM_DW(10),
//    .COV_CORE_DW(16),   //    Q6.10
//    .COV_CORE_FW(10),
//    .OUTPUT_DW(16),
//    .OUTPUT_FW(10),
//    .CONV_CORE_DATA_FILE("covcore1_1.dat")
//    )cov(
//    .clk(clk),
//    .rst(rst),
//    .start(ConvStart),
//    .Din(RamDataOut),
//    .DinAddr(ConvAddr),
//    .Dout_en(Dout_en),
//    .Dout(Dout),
//    .DoutStart(),
//    .Finish(Finish)
//    );
    logic [9:0]cnt;
    always_ff@(posedge clk25m)begin
      if(rst) cnt <= 0;
      else if(Den)
        cnt <= cnt +1 ;
    end
endmodule
