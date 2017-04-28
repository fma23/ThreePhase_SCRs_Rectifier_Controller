set_property IOSTANDARD LVCMOS33 [get_ports clock]
set_property PACKAGE_PIN Y9 [get_ports clock]
create_clock -period 10 [get_ports clock]

set_property IOSTANDARD LVCMOS33 [get_ports LED]
set_property PACKAGE_PIN T22 [get_ports {LED[0]}]
set_property PACKAGE_PIN T21 [get_ports {LED[1]}]
set_property PACKAGE_PIN U22 [get_ports {LED[2]}]
set_property PACKAGE_PIN U21 [get_ports {LED[3]}]
set_property PACKAGE_PIN V22 [get_ports {LED[4]}]
set_property PACKAGE_PIN W22 [get_ports {LED[5]}]
set_property PACKAGE_PIN U19 [get_ports {LED[6]}]
set_property PACKAGE_PIN U14 [get_ports {LED[7]}]
set_property PACKAGE_PIN F22 [get_ports {LED[0]}]

set_property IOSTANDARD LVCMOS25 [get_ports rset]
set_property PACKAGE_PIN P16 [get_ports {rset}]


set_property IOSTANDARD LVCMOS33 [get_ports {Thyristors}]
set_property PACKAGE_PIN Y11 [get_ports {Thyristors[0]}]  
set_property PACKAGE_PIN AA11 [get_ports {Thyristors[1]}]  
set_property PACKAGE_PIN Y10 [get_ports {Thyristors[2]}]
#JA   
set_property PACKAGE_PIN AA9 [get_ports {Thyristors[3]}] 
#JB1  
set_property PACKAGE_PIN W12  [get_ports {Thyristors[4]}] 
#JB3 
set_property PACKAGE_PIN V10  [get_ports {Thyristors[5]}]  

set_property IOSTANDARD LVCMOS33 [get_ports clk2]
set_property PACKAGE_PIN W8 [get_ports clk2]

#set_property PACKAGE_PIN R16 [get_ports {btn[3]}]
#set_property PACKAGE_PIN R18 [get_ports {btn[2]}]
#set_property PACKAGE_PIN T18 [get_ports {btn[1]}]
#set_property PACKAGE_PIN N15 [get_ports {btn[0]}

#set_property PACKAGE_PIN Y11 [get_ports {ssd[6]}]
#set_property PACKAGE_PIN AA11 [get_ports {ssd[5]}]
#set_property PACKAGE_PIN Y10 [get_ports {ssd[4]}]
#set_property PACKAGE_PIN AA9 [get_ports {ssd[3]}]
#set_property PACKAGE_PIN W12 [get_ports {ssd[2]}]
#set_property PACKAGE_PIN W11 [get_ports {ssd[1]}]
#set_property PACKAGE_PIN V10 [get_ports {ssd[0]}]





