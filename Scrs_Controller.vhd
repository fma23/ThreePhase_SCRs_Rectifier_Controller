library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all; 
   
entity ThreePhase_SCRs_Controller is

generic (HalfCycle_Counts:integer:=1000000;       -- =20ms/10ns; 20ms is period of sinewave
         FiringPulse_RisingEdge:integer:=166667;  -- =30degrees+ Alpha=HalfCycle_Counts/12; Alpha here =0
	     FiringPulse_FallingEdge:integer:=833333  -- =30degrees+ Alpha+120 degrees=HalfCycle_Counts/9
	     );

port (
      clock        : in  std_logic;
      reset        : in  std_logic;
      Thyristors   : out std_logic_vector(5 downto 0);
      LED          : out std_logic_vector(7 downto 0)
      );
end ThreePhase_SCRs_Controller;

architecture rtl of ThreePhase_SCRs_Controller is

signal SW1_CrossUp_Pulse  : std_logic;
signal SW1_CrossDwn_Pulse : std_logic;
signal SW2_CrossUp_Pulse : std_logic;
signal SW2_CrossDwn_Pulse : std_logic;
signal SW3_CrossUp_Pulse : std_logic;
signal SW3_CrossDwn_Pulse : std_logic;
  
signal LED_Sig    : std_logic_vector(7 downto 0);

signal Pulse_sig      : std_logic; 
signal Sine1_out      : integer range -1241 to 1241; 
signal Sine1_out_dly  : integer range -1241 to 1241;
signal Sine2_out      : integer range -1241 to 1241; 
signal Sine2_out_dly  : integer range -1241 to 1241; 
signal Sine3_out      : integer range -1241 to 1241; 
signal Sine3_out_dly  : integer range -1241 to 1241;
signal Sine1_out_dly2 : integer range -1241 to 1241; 


signal Sinewave1_CrossUp:  std_logic;
signal Sinewave1_CrossUp_dly1:  std_logic;
signal Sinewave1_CrossUp_dly2:  std_logic;
signal Sinewave1_CrossDwn: std_logic;
signal Sinewave1_CrossDwn_dly1:  std_logic;
signal Sinewave1_CrossDwn_dly2:  std_logic;
signal Sinewave2_CrossUp:  std_logic;
signal Sinewave2_CrossUp_dly1:  std_logic;
signal Sinewave2_CrossUp_dly2:  std_logic;
signal Sinewave2_CrossDwn: std_logic;
signal Sinewave2_CrossDwn_dly1:  std_logic;
signal Sinewave2_CrossDwn_dly2:  std_logic;
signal Sinewave3_CrossUp:  std_logic;
signal Sinewave3_CrossUp_dly1:  std_logic;
signal Sinewave3_CrossUp_dly2:  std_logic;
signal Sinewave3_CrossDwn: std_logic;
signal Sinewave3_CrossDwn_dly1:  std_logic;
signal Sinewave3_CrossDwn_dly2:  std_logic;

signal Thyristors_Sig   : std_logic_vector(5 downto 0);

signal PhaseCounter1: integer range 0 to HalfCycle_Counts; --equal to 10 ms/half cycle
signal PhaseCounter2: integer range 0 to HalfCycle_Counts; --equal to 10 ms/half cycle
signal PhaseCounter3: integer range 0 to HalfCycle_Counts;
signal PhaseCounter4: integer range 0 to HalfCycle_Counts;
signal PhaseCounter5: integer range 0 to HalfCycle_Counts;
signal PhaseCounter6: integer range 0 to HalfCycle_Counts;

signal index1      : integer range 0 to 400;  -- 110001111  399
signal index2      : integer range 0 to 400;  -- 110001111  399
signal index3      : integer range 0 to 400;  -- 110001111  399

--attribute mark_debug: string;
--attribute mark_debug of clock: signal is "true";
--attribute mark_debug of reset: signal is "true";
--attribute mark_debug of Sinewave1_CrossUp: signal is "true";
--attribute mark_debug of Sinewave1_CrossDwn: signal is "true";
--attribute mark_debug of Sinewave2_CrossUp: signal is "true";
--attribute mark_debug of Sinewave2_CrossDwn: signal is "true";
--attribute mark_debug of Sinewave3_CrossUp: signal is "true";
--attribute mark_debug of Sinewave3_CrossDwn: signal is "true";
--attribute mark_debug of PhaseCounter1: signal is "true";
--attribute mark_debug of PhaseCounter4: signal is "true";
--attribute mark_debug of PhaseCounter2: signal is "true";
--attribute mark_debug of PhaseCounter3: signal is "true";
--attribute mark_debug of PhaseCounter5: signal is "true";
--attribute mark_debug of PhaseCounter6: signal is "true";
--attribute mark_debug of Thyristors_Sig: signal is "true";


type SineConstants_Array is array(0 to 399) of integer range -1241 to 1241;     --signed(12 downto 0); --400 constants 11 bits each
constant SineConstants  : SineConstants_Array := (

19,39,58,78,97,117,136,156,175,194,213,233,252,271,290,309,328,346,365,384,402,420,439,457,475,493,511,528,546,563,581,
598,615,632,649,665,681,698,714,730,745,761,776,791,806,821,835,850,864,878,891,905,918,931,944,956,969,981,993,1004,1015,
1027,1037,1048,1058,1068,1078,1088,1097,1106,1115,1123,1131,1139,1147,1154,1161,1168,1174,1180,1186,1192,1197,1202,1207,
1211,1215,1219,1223,1226,1229,1231,1234,1236,1237,1239,1240,1241,1241,1241,1241,1241,1240,1239,1237,1236,1234,1231,1229,
1226,1223,1219,1215,1211,1207,1202,1197,1192,1186,1180,1174,1168,1161,1154,1147,1139,1131,1123,1115,1106,1097,1088,1078,
1068,1058,1048,1037,1027,1015,1004,993,981,969,956,944,931,918,905,891,878,864,850,835,821,806,791,776,761,745,730,714,
698,681,665,649,632,615,598,581,563,546,528,511,493,475,457,439,420,402,384,365,346,328,309,290,271,252,233,213,194,175,
156,136,117,97,78,58,39,19,0,-19,-39,-58,-78,-97,-117,-136,-156,-175,-194,-213,-233,-252,-271,-290,-309,-328,-346,-365,
-384,-402,-420,-439,-457,-475,-493,-511,-528,-546,-563,-581,-598,-615,-632,-649,-665,-681,-698,-714,-730,-745,-761,-776,
-791,-806,-821,-835,-850,-864,-878,-891,-905,-918,-931,-944,-956,-969,-981,-993,-1004,-1015,-1027,-1037,-1048,-1058,-1068,
-1078,-1088,-1097,-1106,-1115,-1123,-1131,-1139,-1147,-1154,-1161,-1168,-1174,-1180,-1186,-1192,-1197,-1202,-1207,-1211,
-1215,-1219,-1223,-1226,-1229,-1231,-1234,-1236,-1237,-1239,-1240,-1241,-1241,-1241,-1241,-1241,-1240,-1239,-1237,-1236,
-1234,-1231,-1229,-1226,-1223,-1219,-1215,-1211,-1207,-1202,-1197,-1192,-1186,-1180,-1174,-1168,-1161,-1154,-1147,-1139,
-1131,-1123,-1115,-1106,-1097,-1088,-1078,-1068,-1058,-1048,-1037,-1027,-1015,-1004,-993,-981,-969,-956,-944,-931,-918,
-905,-891,-878,-864,-850,-835,-821,-806,-791,-776,-761,-745,-730,-714,-698,-681,-665,-649,-632,-615,-598,-581,-563,-546,
-528,-511,-493,-475,-457,-439,-420,-402,-384,-365,-346,-328,-309,-290,-271,-252,-233,-213,-194,-175,-156,-136,-117,-97,
-78,-58,-39,-19,0);

begin

--------------------------------------------------------------------------
--Sine waves generation:
--------------------------------------------------------------------------
SineWaves:process (clock,reset)


variable counter      : integer range 0 to 5000;

begin

   if(reset='1') then
		Sine1_out<=0;
		Sine2_out<=0;
		Sine3_out<=0;
		
		index1 <=0;
		index2 <=133;
		index3 <=266;
   elsif(rising_edge(clock)) then
      counter :=counter+1;
           if(counter=5000) then
              Sine1_out<= SineConstants(index1);  
              Sine2_out<= SineConstants(index2); 
              Sine3_out<= SineConstants(index3);
        
              if(index1<399) then
              index1<=index1+1;
              else
              index1<=0;
              end if;
              
              if(index2<399) then
              index2<=index2+1;
              else
              index2<=0;
              end if;
                          
              if(index3<399) then
              index3<=index3+1;
              else
              index3<=0;
              end if;
                                                     
             counter :=0;
        end if;
            
   end if;        
end process SineWaves;

----------------------------------------------------
--Zero Crossing detection
------------------------------------------------------
CompProc: process(clock,reset)


begin

     if(reset='1') then
        Sine1_out_dly<=0;
        Sine2_out_dly<=0;
        Sine3_out_dly<=0;
       
		Sinewave1_CrossDwn<='0';
		Sinewave1_CrossDwn_dly1<='0';
		Sinewave1_CrossDwn_dly2<='0';
        
        Sinewave1_CrossUp<='0';
        Sinewave1_CrossUp_dly1<='0';
        Sinewave1_CrossUp_dly2<='0';
        
        Sinewave2_CrossDwn<='0';
        Sinewave2_CrossDwn_dly1<='0';
        Sinewave2_CrossDwn_dly2<='0';
        
        Sinewave2_CrossUp<='0';
        Sinewave2_CrossUp_dly1<='0';
        Sinewave2_CrossUp_dly2<='0';
        
        Sinewave3_CrossDwn<='0';
        Sinewave3_CrossDwn_dly1<='0';
        Sinewave3_CrossDwn_dly2<='0';
        
        Sinewave3_CrossUp<='0';
        Sinewave3_CrossUp_dly1<='0';
        Sinewave3_CrossUp_dly2<='0';
              
    elsif(rising_edge(clock)) then
	 
         Sine1_out_dly<=Sine1_out;
            --if(signed(Sine1_out_dly) >0 and signed(Sine1_out)<0)then
            if(to_signed(Sine1_out,12)<=0)then
              Sinewave1_CrossDwn<='1';
              Sinewave1_CrossDwn_dly1<=Sinewave1_CrossDwn;
              Sinewave1_CrossDwn_dly2<= Sinewave1_CrossDwn_dly1; 
              Sinewave1_CrossUp<='0';
             
            --elsif(signed(Sine1_out_dly) <0 and signed(Sine1_out) >0)then
            elsif(to_signed(Sine1_out,12) >0)then
              Sinewave1_CrossUp<='1';
              Sinewave1_CrossUp_dly1<=Sinewave1_CrossUp;
              Sinewave1_CrossUp_dly2<= Sinewave1_CrossUp_dly1;
              Sinewave1_CrossDwn<='0';
		    end if; 
				
         Sine2_out_dly <=Sine2_out;
           --if(signed(Sine2_out_dly) >0 and signed(Sine2_out)<0)then
           if(to_signed(Sine2_out,12)<=0)then
              Sinewave2_CrossDwn<='1';
              Sinewave2_CrossDwn_dly1<=Sinewave2_CrossDwn;
              Sinewave2_CrossDwn_dly2<= Sinewave2_CrossDwn_dly1;
			  Sinewave2_CrossUp<='0';
           --elsif(signed(Sine2_out_dly) <0 and signed(Sine2_out) >0)then
           elsif(to_signed(Sine2_out,12)>0)then
              Sinewave2_CrossUp<='1';
              Sinewave2_CrossUp_dly1<=Sinewave2_CrossUp;
              Sinewave2_CrossUp_dly2<= Sinewave2_CrossUp_dly1;
              Sinewave2_CrossDwn<='0';
           end if;
     
         Sine3_out_dly <=Sine3_out;
                --if(signed(Sine3_out_dly) >0 and signed(Sine3_out)<0)then
              if(to_signed(Sine3_out,12)<=0)then
                  Sinewave3_CrossDwn<='1';
                  Sinewave3_CrossDwn_dly1<=Sinewave3_CrossDwn;
                  Sinewave3_CrossDwn_dly2<= Sinewave3_CrossDwn_dly1;
                  Sinewave3_CrossUp<='0';
              -- elsif(signed(Sine3_out_dly) <0 and signed(Sine3_out) >0)then
              elsif(to_signed(Sine3_out,12) >0)then
                  Sinewave3_CrossUp<='1';
                  Sinewave3_CrossUp_dly1<=Sinewave3_CrossUp;
                  Sinewave3_CrossUp_dly2<= Sinewave3_CrossUp_dly1;
                  Sinewave3_CrossDwn<='0';
                end if;    
             end if;
end process CompProc;
-------------------------------------------------------------------------------------
--Combinatorial logics for counter synchronization with zero crossings
-------------------------------------------------------------------------------------
 SW1_CrossDwn_Pulse<= Sinewave1_CrossDwn XOR Sinewave1_CrossDwn_dly2;
 SW1_CrossUp_Pulse<= Sinewave1_CrossUp XOR Sinewave1_CrossUp_dly2;
 SW2_CrossDwn_Pulse<= Sinewave2_CrossDwn XOR Sinewave2_CrossDwn_dly2;
 SW2_CrossUp_Pulse<= Sinewave2_CrossUp XOR Sinewave2_CrossUp_dly2;
 SW3_CrossDwn_Pulse<= Sinewave3_CrossDwn XOR Sinewave3_CrossDwn_dly2;
 SW3_CrossUp_Pulse<= Sinewave3_CrossUp XOR Sinewave3_CrossUp_dly2;
------------------------------------------------------------------------------------- 

counters:process (clock,reset)

begin

  if(reset='1') then
  
   PhaseCounter1<=0;
   PhaseCounter2<=0;
   PhaseCounter3<=0;
   PhaseCounter4<=0;
   PhaseCounter5<=0;
   PhaseCounter6<=0;
     
   elsif(rising_edge(clock)) then
   
   PhaseCounter1<=PhaseCounter1+1;
      if(SW1_CrossUp_Pulse='1')then
        PhaseCounter1<=3;              --set to 3 to account for latching delay of Sinewave1_CrossUp
        end if;
               
   PhaseCounter2<=PhaseCounter2+1; 
      if(SW3_CrossDwn_Pulse='1')then
         PhaseCounter2<=3;              --set to 3 to account for latching delay of Sinewave3_CrossDwn
        end if; 
        
   PhaseCounter3<=PhaseCounter3+1; 
     if(SW2_CrossUp_Pulse='1')then       --set to 3 to account for latching delay of Sinewave2_CrossUp
       PhaseCounter3<=3;
       end if;
       
   PhaseCounter4<=PhaseCounter4+1;
      if(SW1_CrossDwn_Pulse='1')then
        PhaseCounter4<=3;              --set to 3 to account for latching delay of Sinewave1_CrossDwn
       end if; 
       
   PhaseCounter5<=PhaseCounter5+1; 
   if(SW3_CrossUp_Pulse='1')then
     PhaseCounter5<=3;                -- --set to 3 to account for latching delay of Sinewave3_CrossUp
    end if;
    
   PhaseCounter6<=PhaseCounter6+1; 
   if(SW2_CrossDwn_Pulse='1')then         
      PhaseCounter6<=3;              --set to 3 to account for latching delay of Sinewave2_CrossDwn
    end if;
  
   
   end if;  
 end process counters; 
----------------------------------------------------------------------------------------------------------------------------------------

SCRs_Control:process (clock,reset)

begin

  if(reset='1') then
 
   Thyristors_Sig<=(others=>'0');
	  
  elsif(rising_edge(clock)) then
     --------------------------------------------------------------
	  --SCR T1 Control   --Sinewave1_CrossUp='1'
	  ---------------------------------------------------------------   
            if(PhaseCounter1=FiringPulse_RisingEdge) then
              Thyristors_Sig(0)<='1'; --T1
            elsif(PhaseCounter1=FiringPulse_FallingEdge)then
              Thyristors_Sig(0)<='0';
			 end if;
	  --------------------------------------------------------------
	  --SCR T2 Control  --Sinewave3_CrossDwn='1' 
	  -------------------------------------------------------  
           if(PhaseCounter2=FiringPulse_RisingEdge) then
			  Thyristors_Sig(1)<='1'; --
           elsif(PhaseCounter2=FiringPulse_FallingEdge)then
             Thyristors_Sig(1)<='0';
		  end if;
     --------------------------------------------------------------
	  --SCR T3 Control	--Sinewave2_CrossUp='1'	
     -----------------------------------------------------------
         if(PhaseCounter3=FiringPulse_RisingEdge) then
           Thyristors_Sig(2)<='1';  --
         elsif(PhaseCounter3=FiringPulse_FallingEdge)then
           Thyristors_Sig(2)<='0';
         end if;	
	 --------------------------------------------------------------
	 --SCR T4 Control    --Sinewave1_CrossDwn='1'
	 ----------------------------------------------------------
          if(PhaseCounter4=FiringPulse_RisingEdge) then
             Thyristors_Sig(3)<='1'; --T3 and T2
          elsif(PhaseCounter4=FiringPulse_FallingEdge)then
             Thyristors_Sig(3)<='0';
          end if;
	-------------------------------------------------------------
	--SCR T5 Control  --Sinewave3_CrossUp='1'
	-------------------------------------------------------------
          if(PhaseCounter5=FiringPulse_RisingEdge) then
             Thyristors_Sig(4)<='1'; 
          elsif(PhaseCounter5=FiringPulse_FallingEdge)then
             Thyristors_Sig(4)<='0';
          end if;
	--------------------------------------------------------------
	--SCR T6 Control  --Sinewave2_CrossDwn='1'
	--------------------------------------------------------------
       if(PhaseCounter6=FiringPulse_RisingEdge) then
          Thyristors_Sig(5)<='1'; 
       elsif(PhaseCounter6=FiringPulse_FallingEdge)then
          Thyristors_Sig(5)<='0';
       end if;  
  end if;
end process;
------------------------------------------------------------------------------------------------------------------------------------------

 -- 0 to max_count counter
 compteur : process(clock,reset)
   variable count : natural range 0 to 100000000;
    begin
       if reset = '1' then
            count := 0;
            LED_Sig <= "00000000";
        elsif rising_edge(clock) then
                count := count + 1;
                if (count=100000000) then
                  LED_Sig <= not LED_Sig;
                  count := 0;
                end if;
         end if;
    end process compteur; 
       
    LED<= LED_Sig;

     Thyristors(0)<=Thyristors_Sig(0);
     Thyristors(1)<=Thyristors_Sig(1);
     Thyristors(2)<=Thyristors_Sig(2);
     Thyristors(3)<=Thyristors_Sig(3);
     Thyristors(4)<=Thyristors_Sig(4);
     Thyristors(5)<=Thyristors_Sig(5);
     

end rtl;

 
