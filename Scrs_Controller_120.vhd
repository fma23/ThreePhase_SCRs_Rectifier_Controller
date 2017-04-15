library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;

   
entity ThreePhase_SCRs_Controller is

generic (HalfCycle_Counts:integer:=1000000;       -- =20ms/10ns; 20ms is period of sinewave
         FiringPulse_RisingEdge:integer:=166667;  -- =30degrees+ Alpha=HalfCycle_Counts/12; Alpha here =0
			FiringPulse_FallingEdge:integer:=833333  -- =30degrees+ Alpha+120 degrees=HalfCycle_Counts/9
			);


port (
      clock        : in  std_logic;
      rset         : in  std_logic;
      Thyristors   : out std_logic_vector(5 downto 0);
      clk2         : out std_logic);
end ThreePhase_SCRs_Controller;

architecture rtl of ThreePhase_SCRs_Controller is

signal Pulse_sig      : std_logic; 
signal Sine1_out      : Std_logic_vector( 11 downto 0); --integer range -1241 to 1241;
signal Sine1_out_dly  : Std_logic_vector( 11 downto 0);--integer range -1241 to 1241;
signal Sine2_out      : Std_logic_vector( 11 downto 0);--integer range -1241 to 1241;
signal Sine2_out_dly  : Std_logic_vector( 11 downto 0);--integer range -1241 to 1241;
signal Sine3_out      : Std_logic_vector( 11 downto 0);--integer range -1241 to 1241;
signal Sine3_out_dly  : Std_logic_vector( 11 downto 0);--integer range -1241 to 1241;
signal Sine1_out_dly2  : Std_logic_vector( 11 downto 0);--integer range -1241 to 1241;

signal Comparator1_Dwn: std_logic;
signal Comparator1_Up:  std_logic;
signal Comparator2_Dwn: std_logic;
signal Comparator2_Up:  std_logic;
signal Comparator3_Dwn: std_logic;
signal Comparator3_Up:  std_logic;

signal Sinewave1_CrossUp:  std_logic;
signal Sinewave1_CrossDwn: std_logic;
signal Sinewave2_CrossUp:  std_logic;
signal Sinewave2_CrossDwn: std_logic;
signal Sinewave3_CrossUp:  std_logic;
signal Sinewave3_CrossDwn: std_logic;

signal Thyristors_Sig   : std_logic_vector(5 downto 0);

signal PhaseCounter1: integer range 0 to HalfCycle_Counts; --equal to 10 ms/half cycle
signal PhaseCounter2: integer range 0 to HalfCycle_Counts; --equal to 10 ms/half cycle
signal PhaseCounter3: integer range 0 to HalfCycle_Counts;
signal PhaseCounter4: integer range 0 to HalfCycle_Counts;
signal PhaseCounter5: integer range 0 to HalfCycle_Counts;
signal PhaseCounter6: integer range 0 to HalfCycle_Counts;

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

--------------------------------------------------------------------------------------
-- 50 Hz SINE waves generation
--------------------------------------------------------------------------------------
counter:process (clock)

variable counter_phA      : integer range 0 to 2500; --unsigned(20 downto 0);

begin

  if(rset='1') then
    counter_phA      := 0; --(others=>'0');
    Pulse_sig    <= '0';
  elsif(rising_edge(clock)) then
     counter_phA :=counter_phA+1;
         if(counter_phA=2500) then   --clock frequency here is 20Khz: generate a sample every 50us gives a total of 400 points in 20ms
            Pulse_sig<= not Pulse_sig;
            counter_phA:= 0; --(others=>'0');
         else
            Pulse_sig<=Pulse_sig;
         end if;         
   end if;
end process counter;

clk2<=Pulse_sig;

--------------------------------------------------------------------------
--Sine waves generation:
--------------------------------------------------------------------------
SineWaves:process (Pulse_sig,rset)
variable index1      : integer range 0 to 399;
variable index2      : integer range 0 to 399;
variable index3      : integer range 0 to 399;

begin

   if(rset='1') then
		Sine1_out<=(others=>'0');
		Sine2_out<=(others=>'Z');
		Sine3_out<=(others=>'Z');
		
		index1 :=0;
		index2 :=133;
		index3 :=266;
   elsif(rising_edge(Pulse_sig)) then
      Sine1_out<= conv_std_logic_vector(SineConstants(index1),12);
      Sine2_out<= conv_std_logic_vector(SineConstants(index2),12);
      Sine3_out<= conv_std_logic_vector(SineConstants(index3),12);

      index1:=index1+1;
         if(index1=400) then 
			   index1:=0;
          end if;
      index2:=index2+1;
        if(index2=400) then
    		  index2:=0;
        end if;
      index3:=index3+1;
		   if(index3=400) then 
			  index3:=0;
         end if;
    end if;
end process SineWaves;

----------------------------------------------------
--Zero Crossing detection
------------------------------------------------------
CompProc: process(clock,rset)

variable Sine1_out_signed: signed (11 downto 0);
variable Sine1_out_dly_signed: signed (11 downto 0);

begin

     if(rset='1') then
        Sine1_out_dly<= "ZZZZZZZZZZZZ";
        Sine2_out_dly<= "ZZZZZZZZZZZZ";
        Sine3_out_dly<= "ZZZZZZZZZZZZ";
        
		  Comparator1_Dwn<='0';
        Comparator1_Up<='0';
        Comparator2_Dwn<='0';
        Comparator2_Up<='0';
        Comparator3_Dwn<='0';
        Comparator3_Up<='0';
       
		  Sinewave1_CrossDwn<='0';
        Sinewave1_CrossUp<='0';
        Sinewave2_CrossDwn<='0';
        Sinewave2_CrossUp<='0';
        Sinewave3_CrossDwn<='0';
        Sinewave3_CrossUp<='0';

    elsif(rising_edge(clock)) then
	 
         Sine1_out_dly<=Sine1_out;
            if(signed(Sine1_out_dly) >=0 and signed(Sine1_out)<0)then
              Comparator1_Dwn<='1'; --going down
              Comparator1_Up<='0';
              Sinewave1_CrossDwn<='1';
              Sinewave1_CrossUp<='0';
            elsif(signed(Sine1_out_dly) <=0 and signed(Sine1_out) >0)then
              Comparator1_Up<='1';
              Comparator1_Dwn<='0';
              Sinewave1_CrossUp<='1';
              Sinewave1_CrossDwn<='0';
            elsif(signed(Sine1_out_dly) < 0 and signed(Sine1_out) <0)then
              Comparator1_Up<='0';
				  Comparator1_Dwn<='0';
            elsif(signed(Sine1_out_dly) > 0 and signed(Sine1_out) >0)then
              Comparator1_Up<='0';
              Comparator1_Dwn<='0';
				end if; 
				
       Sine2_out_dly <=Sine2_out;
           if(signed(Sine2_out_dly) >=0 and signed(Sine2_out)<0)then
              Comparator2_Dwn<='1'; --going down
              Comparator2_Up<='0';
              Sinewave2_CrossDwn<='1';
				  Sinewave2_CrossUp<='0';
           elsif(signed(Sine2_out_dly) <=0 and signed(Sine2_out) >0)then
              Comparator2_Up<='1';
              Comparator2_Dwn<='0';
              Sinewave2_CrossUp<='1';
              Sinewave2_CrossDwn<='0';
           elsif(signed(Sine2_out_dly) < 0 and  signed(Sine2_out) <0)then
              Comparator2_Up<='0';
              Comparator2_Dwn<='0';
           elsif(signed(Sine2_out_dly) > 0 and  signed(Sine2_out) >0)then
              Comparator2_Up<='0';
              Comparator2_Dwn<='0';
           end if;
     
	 Sine3_out_dly <=Sine3_out;
        if(signed(Sine3_out_dly) >=0 and signed(Sine3_out)<0)then
          Comparator3_Dwn<='1'; 
          Comparator3_Up<='0';
          Sinewave3_CrossDwn<='1';
          Sinewave3_CrossUp<='0';
       elsif(signed(Sine3_out_dly) <=0 and signed(Sine3_out) >0)then
          Comparator3_Up<='1';
          Comparator3_Dwn<='0';
          Sinewave3_CrossDwn<='0';
          Sinewave3_CrossUp<='1';
       elsif(signed(Sine3_out_dly) < 0 and  signed(Sine3_out) <0)then
          Comparator3_Up<='0';
          Comparator3_Dwn<='0';
       elsif(signed(Sine3_out_dly) > 0 and  signed(Sine3_out) >0)then
          Comparator3_Up<='0';
          Comparator3_Dwn<='0';
	    end if;    
     end if;
end process CompProc;

  
SCRs_Control:process (clock,rset)

begin

  if(rset='1') then
     PhaseCounter1<=0;
     PhaseCounter2<=0;
     PhaseCounter3<=0;
     PhaseCounter4<=0;
     PhaseCounter5<=0;
     PhaseCounter6<=0;

     Thyristors_Sig<=(others=>'0');
	  
  elsif(rising_edge(clock)) then
     --------------------------------------------------------------
	  --SCR T1 Control
	  ---------------------------------------------------------------
     if(Sinewave1_CrossUp='1' and PhaseCounter1<(FiringPulse_FallingEdge+1))then          
			 PhaseCounter1<=PhaseCounter1+1;
            if(PhaseCounter1=FiringPulse_RisingEdge) then
              Thyristors_Sig(0)<='1'; --T1
            elsif(PhaseCounter1=FiringPulse_FallingEdge)then
              Thyristors_Sig(0)<='0';
				else
		        Thyristors_Sig(0)<=Thyristors_Sig(0);
			   end if;
		else 
		PhaseCounter1<=PhaseCounter1;
      end if;
	  --------------------------------------------------------------
	  --SCR T2 Control
	  -------------------------------------------------------
     if(Sinewave3_CrossDwn='1' and PhaseCounter2<(FiringPulse_FallingEdge+1))then
        PhaseCounter2<=PhaseCounter2+1; 
           if(PhaseCounter2=FiringPulse_RisingEdge) then
			    Thyristors_Sig(1)<='1'; --
           elsif(PhaseCounter2=FiringPulse_FallingEdge)then
             Thyristors_Sig(1)<='0';
			  else
		       Thyristors_Sig(1)<=Thyristors_Sig(1);
			  end if;
	   else 
		  PhaseCounter2<=PhaseCounter2;
		end if;
     --------------------------------------------------------------
	  --SCR T3 Control		
     -----------------------------------------------------------
	  if(Sinewave2_CrossUp='1' and PhaseCounter3<(FiringPulse_FallingEdge+1)) then
       PhaseCounter3<=PhaseCounter3+1;
         if(PhaseCounter3=FiringPulse_RisingEdge) then
           Thyristors_Sig(2)<='1';  --
         elsif(PhaseCounter3=FiringPulse_FallingEdge)then
           Thyristors_Sig(2)<='0';
			else
		     Thyristors_Sig(2)<=Thyristors_Sig(2);
         end if;
     else 
		PhaseCounter3<=PhaseCounter3;			
	  end if;
	 --------------------------------------------------------------
	 --SCR T4 Control
	 -----------------------------------------------------------
	 if(Sinewave1_CrossDwn='1' and PhaseCounter4<(FiringPulse_FallingEdge+1))then 
        PhaseCounter4<=PhaseCounter4+1;
          if(PhaseCounter4=FiringPulse_RisingEdge) then
             Thyristors_Sig(3)<='1'; --T3 and T2
          elsif(PhaseCounter4=FiringPulse_FallingEdge)then
             Thyristors_Sig(3)<='0';
			 else
		       Thyristors_Sig(3)<=Thyristors_Sig(3);
          end if;
	 else 
	    PhaseCounter4<=PhaseCounter4;
	 end if;
	-------------------------------------------------------------
	--SCR T5 Control
	-------------------------------------------------------------
	if(Sinewave3_CrossUp='1' and PhaseCounter5<(FiringPulse_FallingEdge+1))then 
      PhaseCounter5<=PhaseCounter5+1;
          if(PhaseCounter5=FiringPulse_RisingEdge) then
             Thyristors_Sig(4)<='1'; 
          elsif(PhaseCounter5=FiringPulse_FallingEdge)then
             Thyristors_Sig(4)<='0';
			 else
		       Thyristors_Sig(4)<=Thyristors_Sig(4);
          end if;
	 else 
		PhaseCounter5<=PhaseCounter5;
	 end if;
	--------------------------------------------------------------
	--SCR T6 Control
	--------------------------------------------------------------
   if(Sinewave2_CrossDwn='1' and PhaseCounter6<(FiringPulse_FallingEdge+1))then 
     PhaseCounter6<=PhaseCounter6+1;
       if(PhaseCounter6=FiringPulse_RisingEdge) then
          Thyristors_Sig(5)<='1'; 
       elsif(PhaseCounter6=FiringPulse_FallingEdge)then
          Thyristors_Sig(5)<='0';
		 else
		    Thyristors_Sig(5)<=Thyristors_Sig(5);
       end if;
	 else 
		PhaseCounter6<=PhaseCounter6;
	 end if;
	--------------------------------------------------------------
	--Phases counter resets
	---------------------------------------------------------------
    if(Sinewave1_CrossUp='0')then
       PhaseCounter1<=0;
    end if;
	 
	 if(Sinewave3_CrossDwn='0')then
      PhaseCounter2<=0;		
	 end if;
	
	 if(Sinewave2_CrossUp='0')then
      PhaseCounter3<=0;			
	 end if;
	 
	 if(Sinewave1_CrossDwn='0')then
      PhaseCounter4<=0;	 
	 end if;
	
	 if(Sinewave3_CrossUp='0')then
      PhaseCounter5<=0;	
	 end if;
	
	 if(Sinewave2_CrossDwn='0')then
      PhaseCounter6<=0;		 
	 end if;
  end if;
end process;

    Thyristors<=Thyristors_Sig;

end rtl;

 
