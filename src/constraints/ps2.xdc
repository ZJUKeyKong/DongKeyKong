# clk
set_property -dict {PACKAGE_PIN AC18       IOSTANDARD LVCMOS18} [get_ports {clk}]; 
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

# ps/2 location
set_property -dict {PACKAGE_PIN N18       IOSTANDARD LVCMOS33} [get_ports {ps2c}];
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {ps2d}];
 
set_property -dict {PACKAGE_PIN W23   IOSTANDARD LVCMOS33} [get_ports {led}];

set_property -dict {PACKAGE_PIN T20       IOSTANDARD LVCMOS33} [get_ports {b[0]}]; 
set_property -dict {PACKAGE_PIN R20       IOSTANDARD LVCMOS33} [get_ports {b[1]}];
set_property -dict {PACKAGE_PIN T22       IOSTANDARD LVCMOS33} [get_ports {b[2]}];
set_property -dict {PACKAGE_PIN T23       IOSTANDARD LVCMOS33} [get_ports {b[3]}];
set_property -dict {PACKAGE_PIN R22       IOSTANDARD LVCMOS33} [get_ports {g[0]}];
set_property -dict {PACKAGE_PIN R23       IOSTANDARD LVCMOS33} [get_ports {g[1]}];
set_property -dict {PACKAGE_PIN T24       IOSTANDARD LVCMOS33} [get_ports {g[2]}];
set_property -dict {PACKAGE_PIN T25       IOSTANDARD LVCMOS33} [get_ports {g[3]}];
set_property -dict {PACKAGE_PIN N21       IOSTANDARD LVCMOS33} [get_ports {r[0]}];
set_property -dict {PACKAGE_PIN N22       IOSTANDARD LVCMOS33} [get_ports {r[1]}]; 
set_property -dict {PACKAGE_PIN R21       IOSTANDARD LVCMOS33} [get_ports {r[2]}];
set_property -dict {PACKAGE_PIN P21       IOSTANDARD LVCMOS33} [get_ports {r[3]}];
set_property -dict {PACKAGE_PIN M22       IOSTANDARD LVCMOS33} [get_ports {hs}];
set_property -dict {PACKAGE_PIN M21       IOSTANDARD LVCMOS33} [get_ports {vs}]; 

set_property -dict {PACKAGE_PIN M24 IOSTANDARD LVCMOS33} [get_ports {seg_clk}];
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {seg_clrn}];
set_property -dict {PACKAGE_PIN L24 IOSTANDARD LVCMOS33} [get_ports {seg_sout}];
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {SEG_PEN}];