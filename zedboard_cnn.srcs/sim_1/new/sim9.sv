`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2018 01:40:25 PM
// Design Name: 
// Module Name: sim9
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


module sim9(

    );
    reg clk;initial clk=0;
    reg rst;initial begin rst =1;#20 rst = 0;  end
    always #5 clk=~clk;
    reg mode;initial begin mode = 0;#200 mode = 1;#1000 mode = 0;#17000000 mode = 1; end
//    reg [7:0]x;initial begin
//     x = 8'd16;
//     #100 x= 8'd64;
//     #10 x =8'd81;
//     #10 x =8'd100;
//     #10 x = 8'd121;
//    end
//    logic out_valid;
//    logic [7:0]Dout;
//    cordic_0  test(
//        .aclk(clk),
//        .s_axis_cartesian_tvalid(1),
//        .s_axis_cartesian_tdata(x),
//        .m_axis_dout_tvalid(out_valid),
//        .m_axis_dout_tdata(Dout)
//      );
    reg [7:0]Zreg[1023:0];initial $readmemh("eight2_32x32.dat", Zreg);
    logic [7:0]z_in;
    logic z_in_en;
    
    logic [10:0]ZRdCnt;
    reg [1:0]mode_capture;
    
    always_ff@(posedge clk)begin
      mode_capture <= {mode_capture[0],mode};
    end
    wire mode_rise = mode_capture == 2'b01;   
    logic [1:0]state;
    always_ff@(posedge clk)begin
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
    
    always_ff@(posedge clk)begin
    if(rst | mode_rise)begin ZRdCnt <= 0;z_in <= 0;z_in_en <= 0;end
    else begin
      if(ZRdCnt < 1024 & state == 1)begin
        z_in_en <= 1;
        z_in <= Zreg[ZRdCnt];
        ZRdCnt <= ZRdCnt + 1;
      end
      else if(ZRdCnt == 1024)begin ZRdCnt <= 0;z_in_en <= 0; end
      else begin 
        ZRdCnt <= ZRdCnt;
        z_in_en <= 0;
      end
    end
    end
    logic EgdeOutEn;
    logic [7:0]EdgeOytData;
EdgeSobelGray#(
        .ROW_NUM(32),
        .COLUMN_NUM(32),
        .INPUT_DW(8),
        .OUTPUT_DW(8),
        .T(10)       
    )theEdge(
        .clk(clk),
        .rst(rst), 
        .start(mode_rise),          
        .InputEn(z_in_en),
        .InputData(z_in),
        .OutputEn(EgdeOutEn),
        .OutputData(EdgeOytData)
        );
endmodule
