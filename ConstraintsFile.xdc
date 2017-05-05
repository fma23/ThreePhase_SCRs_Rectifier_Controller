set_property IOSTANDARD LVCMOS33 [get_ports clock]
set_property PACKAGE_PIN Y9 [get_ports clock]
create_clock -period 10.000 [get_ports clock]

set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN T22 [get_ports {LED[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN T21 [get_ports {LED[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN U22 [get_ports {LED[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property PACKAGE_PIN U21 [get_ports {LED[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property PACKAGE_PIN V22 [get_ports {LED[4]}]

set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property PACKAGE_PIN W22 [get_ports {LED[5]}]

set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property PACKAGE_PIN U19 [get_ports {LED[6]}]

set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
set_property PACKAGE_PIN U14 [get_ports {LED[7]}]


set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PACKAGE_PIN F22 [get_ports reset]

set_property IOSTANDARD LVCMOS33 [get_ports {Thyristors[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Thyristors[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Thyristors[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Thyristors[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Thyristors[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Thyristors[0]}]
#JA1
set_property PACKAGE_PIN Y11 [get_ports {Thyristors[0]}]
#JA2
set_property PACKAGE_PIN AA11 [get_ports {Thyristors[1]}]
#JA3
set_property PACKAGE_PIN Y10 [get_ports {Thyristors[2]}]
#JA4
set_property PACKAGE_PIN AA9 [get_ports {Thyristors[3]}]
#JA7
set_property PACKAGE_PIN AB11 [get_ports {Thyristors[4]}]
#JA8
set_property PACKAGE_PIN AB10 [get_ports {Thyristors[5]}]


