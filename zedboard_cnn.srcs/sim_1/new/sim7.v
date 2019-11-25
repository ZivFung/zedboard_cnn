`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2017 12:07:25 PM
// Design Name: 
// Module Name: sim7
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


module sim7(

    );
    reg clk;initial clk=0;
    reg rst;initial begin rst =1;#20 rst = 0;  end
    always #5 clk=~clk;
    
    reg clk25m;initial clk25m = 0;
    always #20 clk25m = ~clk25m;
    reg mode;initial begin mode = 0;#200 mode = 1;#1000 mode = 0;#17000000 mode = 1; end
    reg [1:0]mode_capture;initial mode_capture = 0;
    
    always@(posedge clk)begin
      mode_capture <= {mode_capture[0],mode};
    end
    wire mode_rise = mode_capture == 2'b01;
    reg [7:0]img_data[307199:0];initial $readmemh("img_input.dat",img_data);
    //reg [15:0]fc1_core_data[299:0];initial $readmemh("fc1_core.dat", fc1_core_data);
    reg [11:0]ram_data_delay;initial ram_data_delay = 0;
    
//    reg [11:0]ram_data_in;initial begin ram_data_in <= 12'hFFF ; end
    wire [18:0]ram_addr_out;
//    always@(posedge clk25m)begin
//      ram_data_delay <= (img_data[ram_addr_out] > 0)? 12'hFFF:0;
//      ram_data_in <= ram_data_delay;
//    end
    reg ram_wr;initial ram_wr =1;
    reg [18:0]ram_wr_addr;initial ram_wr_addr = 20;
    reg [11:0]ram_wr_data;initial ram_wr_data = 12'hFF;
     wire [11:0]ram_data_in;    
        blk_mem_gen_0 bran
       (
        .clka(clk25m),
        .ena(1),
        .wea(ram_wr),
        .addra(ram_wr_addr),
        .dina(ram_wr_data),
        
        .clkb(clk25m),
        .enb(1'b1),
        .addrb(ram_addr_out),
        .doutb(ram_data_in)
      );
    
    wire [1:0]Dout;
    wire Den;
    Resizeimg#(                    //Nearest interpolation
        .INPUT_DW(4),
        .RAM_AW(19),
        .INPUT_ROWNUM(480),
        .INPUT_COLUMNNUM(640),
        .OUTPUT_ROWNUM(32),
        .OUTPUT_COLUMNNUM(32),
        .OUTPUT_DW(2)
        )theResize(
        .clk(clk),
        .clk_25m(clk25m),
        .rst(rst),
        .start(mode_rise),
        .ImageIn(ram_data_in[3:0]),
        .AddrOut(ram_addr_out),
        .ImgOut(Dout),
        .OutEn(Den)
        );
     wire [10:0]cnt0;
     wire co;
     Counter#(1025)theCnt(clk,rst,Den,cnt0,co);
//    wire signed[31:0]test2 = -32'sd1024;
    
//    wire signed[31:0]test4 = -32'sd32768;
//    wire signed[15:0]test3 = {test4[31],test4[14:0]};
//    wire signed[15:0] test;
//    assign test = 0.81 *(2**10);
//    wire signed[31:0] test1;
//    assign test1 = -629248;
    reg input_en;initial input_en = 1;
    wire [3:0]led;
//    CnnTest#(12,19)cnn(clk,rst,clk25m,mode,ram_data_in,ram_addr_out,led);
//    wire [15:0]sigmoid2_3_output_data;
//    wire sigmoid2_3_output_data_valid;
//sigmoid#(.INPUT_DATA_WIDTH(16),.INPUT_DATA_FW(10),.NONCONSTANT_INPUT_DATA_FW(10),.OUTPUT_DATA_WIDTH(16),.OUTPUT_DATA_FW(10))
//sig2_3(clk,test,input_en,sigmoid2_3_output_data,sigmoid2_3_output_data_valid);  
endmodule
