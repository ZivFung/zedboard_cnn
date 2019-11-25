`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2017 11:00:32 PM
// Design Name: 
// Module Name: top
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


module top(
    input  wire clk,
    input  wire [2:0]keyin,
    input  wire sw0,
    input  wire sw1,
    input  wire sw2,
    input  wire sw6,
    input  wire sw7, 
    output wire [3:0]led,
    output wire [7:0]seg,
    output wire ov7670_sioc,
    inout  wire ov7670_siod, 
    output wire ov7670_xclk,
    input  wire [7:0]ov7670_din, 
    input  wire ov7670_pclk,
    input  wire ov7670_href,
    input  wire ov7670_vsync,
    output wire ov7670_pwdn,
    output wire ov7670_reset,
    
    inout [14:0]DDR_addr,
    inout [2:0]DDR_ba,
    inout DDR_cas_n,
    inout DDR_ck_n,
    inout DDR_ck_p,
    inout DDR_cke,
    inout DDR_cs_n,
    inout [3:0]DDR_dm,
    inout [31:0]DDR_dq,
    inout [3:0]DDR_dqs_n,
    inout [3:0]DDR_dqs_p,
    inout DDR_odt,
    inout DDR_ras_n,
    inout DDR_reset_n,
    inout DDR_we_n,
    inout FIXED_IO_ddr_vrn,
    inout FIXED_IO_ddr_vrp,
    inout [53:0]FIXED_IO_mio,
    inout FIXED_IO_ps_clk,
    inout FIXED_IO_ps_porb,
    inout FIXED_IO_ps_srstb,
    
    output wire [3:0]R,
    output wire [3:0]G,
    output wire [3:0]B,
    output wire h_synch,
    output wire v_synch
    );
    
    wire [2:0]keydown;
    wire clk25M;
    wire locked;
    wire error;
    wire [11:0]ram_wr_data;
    wire [0:0] ram_wr;
    wire [18:0]ram_wr_addr;
    wire [11:0]ram_rd_data;
    wire [18:0]ram_rd_addr;
    
    wire [11:0]ram_ov7670_wr_data;
    wire [0:0] ram_ov7670_wr;
    wire [18:0]ram_ov7670_wr_addr;
    wire [18:0]ram_vga_rd_addr;
    wire [11:0]ResizWrData;
    wire [18:0]ResizWrAddr;  
    wire [11:0]ResizeImgDout;
    wire ResizeImgOutEn;
    wire ResizWrEn;
    wire CnnReset =  keydown[0] | (sw2 & keydown[2]);
    (*mark_debug = "true"*)wire IdentifyStart; 
    (*mark_debug = "true"*)reg CnnStart;initial CnnStart = 0;   
    reg [3:0]LedReg;
    wire [0:0]CnnInputData = (ResizeImgDout>0)? 1:0;
    wire Dout_en;
    wire [9:0]Dout;
    
    clk_wiz_0 clk25
     (clk25M,1'b0,locked,clk);
     
    keysprocess#(3)keys(clk25M,keyin,keydown);
    assign ov7670_xclk=clk25M;
    assign ov7670_pwdn = 0;
    assign ov7670_reset = 1;
    
    init_ov7670 #(123,"ov7670_RamData.dat") the_ov7670(clk25M,keydown[0],ov7670_siod,ov7670_sioc,error);
    ov_7670_capture capture(clk,keydown[0],ov7670_pclk,ov7670_href,ov7670_vsync,ov7670_din ,sw7,
            ram_ov7670_wr_data,
            ram_ov7670_wr,
            ram_ov7670_wr_addr);
            
    blk_mem_gen_0 bran
       (
        .clka(clk25M),
        .ena(~sw0),
        .wea(ram_wr),
        .addra(ram_wr_addr),
        .dina(ram_wr_data),
        
        .clkb(clk25M),
        .enb(1'b1),
        .addrb(ram_rd_addr),
        .doutb(ram_rd_data)
      );

           
    assign ram_wr = (sw1)? (ResizWrEn):ram_ov7670_wr;
    assign ram_wr_data = (sw1)?ResizWrData:ram_ov7670_wr_data;
    assign ram_wr_addr = (sw1)?ResizWrAddr:ram_ov7670_wr_addr;
    assign ram_rd_addr = ram_vga_rd_addr;     

    vga#(307200,19,4,12,480,11,2,31,640,16,96,48)the_vga
        (clk25M,keydown[0],ram_rd_data,ram_vga_rd_addr,R,G,B,h_synch,v_synch);

    Counter#(500000)IdentifyCnt(clk25M,keydown[0],sw6,,IdentifyStart);  
    
    always@(posedge clk25M)
      CnnStart <= (sw2 & keydown[2]) | (IdentifyStart);

    Resizeimg25M#(                    //Nearest interpolation
    .INPUT_DW(12),
    .RAM_AW(19),
    .INPUT_ROWNUM(480),
    .INPUT_COLUMNNUM(640),
    .OUTPUT_ROWNUM(32),
    .OUTPUT_COLUMNNUM(32)
    )theResize(
    .clk(clk25M),
    .rst(CnnReset| IdentifyStart),
    .start(CnnStart),
    .ImageIn(ram_rd_data),
    .VgaAddrIn(ram_vga_rd_addr),
    .ResizWrAddr(ResizWrAddr),
    .ResizWrData(ResizWrData),
    .ResizWrEn(ResizWrEn),
    .ImgOut(ResizeImgDout),
    .OutEn(ResizeImgOutEn)
    );
        
    Cnn_Optimize#(
         .INPUT_DW(1),
         .INPUT_FW(0),
         .INPUT_ROW_NUM(32),
         .INPUT_COLUMN_NUM(32),
         .OUTPUT_DW(10)
        )theCNN(
         .clk(clk25M),
         .rst(CnnReset| IdentifyStart),
         .start(CnnStart),
         .Din(CnnInputData),
         .Din_en(ResizeImgOutEn),
         .Dout_en(Dout_en),
         .Dout(Dout)
         );
         
    Seg#(
        .INPUT_DW(10),
        .OUTPUT_DW(8) 
        )(
        .clk(clk25M),
        .rst(CnnReset| IdentifyStart),
        .Din(Dout),
        .Din_en(Dout_en),
        .SegOut(seg)
        );

    always@(posedge clk25M)begin
     if(CnnReset)LedReg <= LedReg;
     else begin
       if(Dout_en)begin
         case(Dout)
           10'h1:LedReg <= 1;
           10'h2:LedReg <= 2;
           10'h4:LedReg <= 3;
           10'h8:LedReg <= 4;
           10'h10:LedReg <= 5;
           10'h20:LedReg <= 6;
           10'h40:LedReg <= 7;
           10'h80:LedReg <= 8; 
           10'h100:LedReg <= 9; 
           10'h200:LedReg <= 10;
           10'h0: LedReg <= 15;
           default:LedReg <= 15;
         endcase
       end
     end
    end
    assign led = LedReg;
      
         
  zynq zynq_i
      (.DDR_addr(DDR_addr),
       .DDR_ba(DDR_ba),
       .DDR_cas_n(DDR_cas_n),
       .DDR_ck_n(DDR_ck_n),
       .DDR_ck_p(DDR_ck_p),
       .DDR_cke(DDR_cke),
       .DDR_cs_n(DDR_cs_n),
       .DDR_dm(DDR_dm),
       .DDR_dq(DDR_dq),
       .DDR_dqs_n(DDR_dqs_n),
       .DDR_dqs_p(DDR_dqs_p),
       .DDR_odt(DDR_odt),
       .DDR_ras_n(DDR_ras_n),
       .DDR_reset_n(DDR_reset_n),
       .DDR_we_n(DDR_we_n),
       .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
       .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
       .FIXED_IO_mio(FIXED_IO_mio),
       .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
       .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
       .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
       );
endmodule
