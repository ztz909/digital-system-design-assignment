library ieee;
use ieee.std_logic_1164.all;

entity erotima1 is                         --dhmioutgia mias ALU 1-bit
port (a, b, ainv, binv, ci: in std_logic;
       op: in std_logic_vector(1 downto 0);
       res ,co: out std_logic);
end erotima1;

architecture structure of erotima1 is 	
 signal s1, s2, s3, s4, s5, s6: std_logic;

  component and1					
    port (in1, in2: in std_logic; 
      out1: out std_logic);
  end component;

  component or1				
    port (in1, in2: in std_logic;
      out1: out std_logic);
  end component; 
  
  component fulladder                             --ulopoihsh tou fulladder me vash th dosmenh sunarthsh
    port (in1,in2,in3: in std_logic;
	         out1,out2: out std_logic);
	end component;
	
	component mux
    port (in1,in2,in3,in5: in std_logic;
	         in4: in std_logic_vector(1 downto 0);
	         out1: out std_logic);
	end component;
	
	 component invB
    port (in1,in2, in3: in std_logic;
	         out1: out std_logic);
	end component;
	
	  component invA
    port (in1,in2, in3: in std_logic;
	         out1: out std_logic);
	end component;
	
	 component xor1			
    port (in1, in2: in std_logic;
      out1: out std_logic);
  end component; 

begin
   I1: and1 port map (in1 => s5, in2 => s4, out1 => s1);
   I2: or1 port map (in1 => s5, in2 => s4, out1 => s2);
	I3: fulladder port map (in1 => s5, in2 => s4, in3 => ci, out1 => s3, out2 => co);
	I4: mux port map (in1 => s1, in2 => s2, in3 => s3,in4 => op,in5 => s6, out1 => res);
	I5: invB port map (in1 => b, in2 => b, in3 => binv, out1 => s4);
	I6: invA port map (in1 => a, in2 => a, in3 => ainv, out1 => s5);
	I7: xor1 port map (in1 => s5, in2 => s4, out1 => s6);
end structure;
	 
library ieee;
use ieee.std_logic_1164.all;

entity and1 is
	port (in1,in2:in std_logic;
	         out1:out std_logic);
end and1;

architecture model_conc of and1 is
begin
	out1 <= in1 and in2;
end model_conc;

library ieee;
use ieee.std_logic_1164.all;

entity or1 is
	port (in1,in2:in std_logic;
	         out1:out std_logic);
end or1;

architecture model_conc2 of or1 is
begin
	out1<=in1 or in2;
end model_conc2;

library ieee;
use ieee.std_logic_1164.all;

entity fulladder is
	port(in1,in2,in3:in std_logic;
	       out1,out2:out std_logic);
end fulladder;

architecture model_conc3 of fulladder is
begin
	out1<=(in1 AND NOT(in2)AND NOT(in3)) OR ((NOT(in1) AND in2 AND (NOT(in3)))) OR ((NOT(in1) AND (NOT(in2)) AND in3)) OR (in1 AND in2 AND in3) ; 
	out2<=(in2 AND in3) OR (in1 AND in3) OR (in1 AND in2);
end model_conc3;

library ieee;
use ieee.std_logic_1164.all;

entity mux is
	port (in1,in2,in3,in5:in std_logic;
	         in4: in std_logic_vector(1 downto 0);
	         out1:out std_logic);
end mux;

architecture model_conc4 of mux is
begin
		WITH in4 SELECT
		out1 <= in1 WHEN "00",
			in2 WHEN "01",
			in3 WHEN "10", 
			in5 WHEN OTHERS;
end model_conc4;

library ieee;
use ieee.std_logic_1164.all;

entity invA is
	port (in1,in2,in3:in std_logic;
	         out1:out std_logic);
end invA;

architecture model_conc5 of invA is
begin
        out1 <= in1 when in3 = '0' else (not in2);
end model_conc5;

library ieee;
use ieee.std_logic_1164.all;

entity invB is
	port (in1,in2,in3:in std_logic;
	         out1:out std_logic);
end invB;

architecture model_conc6 of invB is
begin
        out1 <= in1 when in3 = '0' else (not in2);
end model_conc6;

library ieee;
use ieee.std_logic_1164.all;

entity xor1 is
	port (in1,in2:in std_logic;
	         out1:out std_logic);
end xor1;

architecture model_conc6 of xor1 is
begin
      out1 <= (in1 xor in2);
end model_conc6;