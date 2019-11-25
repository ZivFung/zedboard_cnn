#Clock signal
create_clock -period 10.000 -name sys_clk_pin -add [get_ports clk]
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]

#set_property PACKAGE_PIN  N15  [get_ports {BTN_UP}]
#set_property IOSTANDARD LVCMOS33 [get_ports {BTN_UP}]

set_property PACKAGE_PIN N15 [get_ports {keyin[0]}]
set_property PACKAGE_PIN R16 [get_ports {keyin[1]}]
set_property PACKAGE_PIN P16 [get_ports {keyin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keyin[*]}]

set_property PACKAGE_PIN Y19 [get_ports v_synch]
set_property IOSTANDARD LVCMOS33 [get_ports v_synch]

set_property PACKAGE_PIN AA19 [get_ports h_synch]
set_property IOSTANDARD LVCMOS33 [get_ports h_synch]

set_property PACKAGE_PIN V20 [get_ports {R[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[0]}]
set_property PACKAGE_PIN U20 [get_ports {R[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[1]}]
set_property PACKAGE_PIN V19 [get_ports {R[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[2]}]
set_property PACKAGE_PIN V18 [get_ports {R[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[3]}]

set_property PACKAGE_PIN AB22 [get_ports {G[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[0]}]
set_property PACKAGE_PIN AA22 [get_ports {G[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[1]}]
set_property PACKAGE_PIN AB21 [get_ports {G[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[2]}]
set_property PACKAGE_PIN AA21 [get_ports {G[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[3]}]

set_property PACKAGE_PIN Y21 [get_ports {B[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[0]}]
set_property PACKAGE_PIN Y20 [get_ports {B[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[1]}]
set_property PACKAGE_PIN AB20 [get_ports {B[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[2]}]
set_property PACKAGE_PIN AB19 [get_ports {B[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[3]}]





#  set_property  -dict {PACKAGE_PIN  Y11    IOSTANDARD LVCMOS33}           [get_ports OV7670_PWDN ]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {ov7670_din[0]}]
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS33} [get_ports {ov7670_din[2]}]
set_property -dict {PACKAGE_PIN AA9 IOSTANDARD LVCMOS33} [get_ports {ov7670_din[4]}]

#  set_property  -dict {PACKAGE_PIN  AB11  IOSTANDARD LVCMOS33}           [get_ports OV7670_RESET ]
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports {ov7670_din[1]}]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS33} [get_ports {ov7670_din[3]}]
set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS33} [get_ports {ov7670_din[5]}]

set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33} [get_ports {ov7670_din[6]}]
set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33} [get_ports ov7670_xclk]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports ov7670_href]
set_property -dict {PACKAGE_PIN W8 IOSTANDARD LVCMOS33} [get_ports ov7670_siod]

set_property PULLUP true [get_ports ov7670_siod]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {ov7670_din[7]}]
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS33} [get_ports ov7670_pclk]
#create_clock -period 40.000 -name ov7670_clk_pin -add [get_ports ov7670_pclk]
set_property -dict {PACKAGE_PIN V9 IOSTANDARD LVCMOS33} [get_ports ov7670_vsync]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports ov7670_sioc]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports ov7670_reset]
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports ov7670_pwdn]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ov7670_pclk_IBUF]

#  set_property  -dict {PACKAGE_PIN  T22  IOSTANDARD LVCMOS33}           [get_ports ERROR_LED ]
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports sw0]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports sw1]
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33} [get_ports sw2]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports sw6]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports sw7]

set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN AB7 IOSTANDARD LVCMOS33} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS33} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {seg[6]}]
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS33} [get_ports {seg[7]}]

set_property PACKAGE_PIN T22 [get_ports {led[0]}]
set_property PACKAGE_PIN T21 [get_ports {led[1]}]
set_property PACKAGE_PIN U22 [get_ports {led[2]}]
set_property PACKAGE_PIN U21 [get_ports {led[3]}]
#set_property PACKAGE_PIN V22 [get_ports {led[4]}]
#set_property PACKAGE_PIN W22 [get_ports {led[5]}]
#set_property PACKAGE_PIN U19 [get_ports {led[6]}]
#set_property PACKAGE_PIN U14 [get_ports {led[7]}]
#set_property PACKAGE_PIN V15 [get_ports {led[8]}]
#set_property PACKAGE_PIN V14 [get_ports {led[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]






create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk25/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 18 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {theCNN/fc1/Max[0]} {theCNN/fc1/Max[1]} {theCNN/fc1/Max[2]} {theCNN/fc1/Max[3]} {theCNN/fc1/Max[4]} {theCNN/fc1/Max[5]} {theCNN/fc1/Max[6]} {theCNN/fc1/Max[7]} {theCNN/fc1/Max[8]} {theCNN/fc1/Max[9]} {theCNN/fc1/Max[10]} {theCNN/fc1/Max[11]} {theCNN/fc1/Max[12]} {theCNN/fc1/Max[13]} {theCNN/fc1/Max[14]} {theCNN/fc1/Max[15]} {theCNN/fc1/Max[16]} {theCNN/fc1/Max[17]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 4 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {theCNN/fc1/MaxCnt[0]} {theCNN/fc1/MaxCnt[1]} {theCNN/fc1/MaxCnt[2]} {theCNN/fc1/MaxCnt[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 11 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {theCNN/fc1/MulCnt[0]} {theCNN/fc1/MulCnt[1]} {theCNN/fc1/MulCnt[2]} {theCNN/fc1/MulCnt[3]} {theCNN/fc1/MulCnt[4]} {theCNN/fc1/MulCnt[5]} {theCNN/fc1/MulCnt[6]} {theCNN/fc1/MulCnt[7]} {theCNN/fc1/MulCnt[8]} {theCNN/fc1/MulCnt[9]} {theCNN/fc1/MulCnt[10]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets ov7670_xclk_OBUF]
