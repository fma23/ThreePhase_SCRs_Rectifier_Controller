# Three Phase SCRs Rectifier Controller

This VHDL project controls six semiconductor controlled rectifiers ICs used for a three phase AC to DC converter. The projects generhe erated 3 sine waves signals; each having a 120 degrees phase shift. The phase delay in this example is assumed to be zero, but it can be changed by modifying the FiringPulse_RisingEdge constant. For a 0 degree delay this value is:166667, but for a 30 degrees delay this value needs to be: 233334. The firing pulse duration is 10 degrees, with references to the full cycle duration which is 360 degrees.

The second VHDL generates SCRs gates pulses with a width of 120 degrees. This time the firing pulse falling edge occurs at 833333 clock cycle after zero crossing.

360 degrees corresponds to 20 ms, for a sine wave of 50 Hz frequency.
The clock frequency is 100Mhz.

More information about fully controlled 3 phase SCR rectifiers can be found at the links below:

http://www.worldcolleges.info/sites/default/files/enggnotes/three-phase_controlled_rectifiers.pdf 
http://www4.hcmut.edu.vn/~nvnho/Download/EngPE/Chapter3_Phase_Controlled_Rectifier.pdf 
http://www.euedia.tuiasi.ro/lab_ep/ep_files/Lab_no_13_c1.pdf 

Any feedbacks please share with me at: fma23@sfu.ca
