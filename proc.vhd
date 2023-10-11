LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.std_logic_signed.all; 
use work.erotima2;
ENTITY proc IS 
    PORT ( DIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
           Resetn, Clock, Run : IN STD_LOGIC; 
           Done : BUFFER STD_LOGIC; 
           BusWires : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0)); 
END proc; 

ARCHITECTURE Behavior OF proc IS 
signal R0, R1, R2, R3, R4, R5, R6, R7:std_logic_vector(15 downto 0);
signal A, G, Sum:std_logic_vector (15 downto 0);
signal IR:std_logic_vector (0 to 8);
signal Counter:std_logic_vector (1 downto 0);
signal Tstep_Q:std_logic_vector (1 downto 0);
signal ALUOp:std_logic_vector(2 downto 0);
signal Cout:std_logic;
signal I:std_logic_vector (1 to 3);
signal Clear, High, IRin:std_logic;
signal DINout,Ain,Aout,Gin,Gout:std_logic;
signal Rin,Rout,Xreg,Yreg:std_logic_vector (0 to 7);
signal Sel:std_logic_vector(0 to 9);
component regn
  GENERIC (n : INTEGER := 16); 
  PORT ( R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); 

  Rin, Clock : IN STD_LOGIC; 

  Q : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0)); 
END component;
component regn9
  GENERIC (n : INTEGER := 9); 
  PORT ( R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); 

  Rin, Clock : IN STD_LOGIC; 

  Q : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0)); 
END component;
component regn2 IS 
  GENERIC (n : INTEGER := 2); 
  PORT ( R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); 

  Rin, Clock : IN STD_LOGIC; 

  Q : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0)); 
END component; 
component upcount
  PORT ( Clear, Clock : IN STD_LOGIC; 
  Q : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)); 
END component; 
component dec3to8
  PORT ( W : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
  En : IN STD_LOGIC; 
  Y : OUT STD_LOGIC_VECTOR(0 TO 7)); 
END component;
component erotima2
    port (
        a:          in  std_logic_vector (15 downto 0);
        b:          in  std_logic_vector (15 downto 0);
        opcode:     in  std_logic_vector (2 downto 0);
        res:     out std_logic_vector (15 downto 0);
        co:  out std_logic);
end component;	  

BEGIN 
  High <= '1'; 
  Clear <= Cout or not Resetn or Done or (not Run and not Tstep_Q(0) and not Tstep_Q(1));--clear mono otan exoume kratoumeno h teleiwse entolh h otan eimaste se prwto xrono xwris entolh run 
  Tstep: upcount PORT MAP (Clear, Clock, Tstep_Q);--orismos toy metrhth xronou twn entolwn
  I <= IR(0 TO 2);--lhpsh twn prwtwn triwn bit san entolh
  decX: dec3to8 PORT MAP (IR(3 TO 5), High, Xreg);--lhpsh twn epomenwn triwn san thesi register X me decoder
  decY: dec3to8 PORT MAP (IR(6 TO 8), High, Yreg);--lhpsh twn epomenwn triwn san thesi register Y me decoder



	-- Instruction Table
	--  000: mv			Rx,Ry
	--  001: mvi		Rx,#D
	--  010: and        Rx,Ry	
	--  011: or         Rx,Ry	
	--  100: add		Rx,Ry				: Rx <- [Rx] + [Ry]
	--  101: sub		Rx,Ry				: Rx <- [Rx] - [Ry]
	--  110: xor        Rx,Ry	
	--  111: nor        Rx,Ry
	-- 	OPCODE format: III XXX YYY, where 
	-- 	III = instruction, XXX = Rx, and YYY = Ry. For mvi,
	-- 	a second word of data is loaded from DIN

  controlsignals: PROCESS (Tstep_Q, I, Xreg, Yreg) 

  BEGIN 
	Done<='0';
	DINout<='0';
	--arxikes times twn shmatwn prin arxisei h lhpsh shmatwn
	Ain<='0';Gin<='0';Gout<='0';ALUOp<="000";
	Rin<="00000000";Rout<="00000000";
    CASE Tstep_Q IS 
      WHEN "00" =>  --lhpsh entolhs
        IRin <= '1'; 
      WHEN "01" =>  --elegxos entolhs gia analogh praksi kai antistoixh anathesi twn shmatwn
        CASE I IS 
			when "000" => --load
				DINout<='1';Rin<=Xreg;Done<='1';
			when "001" => --move
				Rout<=Yreg;Rin<=Xreg;Done<='1';
			when others => --add,sub,xor,not,and,or
				Rout<=Xreg;Ain<='1';

        END CASE; 
      WHEN "10" =>  --synexeia twn antistoiisewn kai xrhsh ths alu gia tis praksis
        CASE I IS 
			when "010" => --and
				Rout<=Yreg;ALUOp<="000";Gin<='1';
			when "011" => --or	
				Rout<=Yreg;ALUOp<="001";Gin<='1';
			when "100" => --add
				Rout<=Yreg;ALUOp<="011";Gin<='1';
			when "101" => --sub
				Rout<=Yreg;ALUOp<="010";Gin<='1';
			when "110" => --xor
				Rout<=Yreg;ALUOp<="100";Gin<='1';
			when "111" => --nor
				Rout<=Yreg;ALUOp<="101";Gin<='1';
			when others => --load,move
				null;--kamia energeia efoson oloklhrwthhkan oi entoles load,move se ena xrono
        END CASE; 
      WHEN "11" =>  --anathesi twn apotelesmatwn twn praksewn sta antistoixa register
        CASE I IS 
			when "000" => --load
				null;
			when "001" => --move
				null;
			when others => --add,sub,and,or,xor,not
				Gout<='1';Rin<=Xreg;Done<='1';
        END CASE; 
    END CASE; 
  END PROCESS; 
	------ orismos twn registers thw alu kai tou bus
  reg_0: regn PORT MAP (BusWires, Rin(0), Clock, R0); 
  reg_1: regn PORT MAP (BusWires, Rin(1), Clock, R1);
  reg_2: regn PORT MAP (BusWires, Rin(2), Clock, R2);
  reg_3: regn PORT MAP (BusWires, Rin(3), Clock, R3);
  reg_4: regn PORT MAP (BusWires, Rin(4), Clock, R4);
  reg_5: regn PORT MAP (BusWires, Rin(5), Clock, R5);
  reg_6: regn PORT MAP (BusWires, Rin(6), Clock, R6);
  reg_7: regn PORT MAP (BusWires, Rin(7), Clock, R7);
  reg_A: regn PORT MAP (BusWires, Ain, Clock, A);
  alu_proc: erotima2 port map (A,BusWires,ALUOp,Sum,Cout);
  reg_G: regn PORT MAP (Sum, Gin, Clock, G);
  reg_IR: regn9 port map (DIN(15 downto 7),IRin,Clock,IR);
  reg_Count: regn2 port map(Tstep_Q,Clear,Clock,Counter);
  Sel<= Rout & Gout & DINout;
  with Sel select
	BusWires<=R0 when "1000000000",
		R1 when "0100000000",
		R2 when "0010000000",
		R3 when "0001000000",
		R4 when "0000100000",
		R5 when "0000010000",
		R6 when "0000001000",
		R7 when "0000000100",
		G when "0000000010",
		DIN when others;
END Behavior; 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;


ENTITY upcount IS 

  PORT ( Clear, Clock : IN STD_LOGIC; 
  Q : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)); 
END upcount; 

ARCHITECTURE Behavior OF upcount IS 
 SIGNAL Count : STD_LOGIC_VECTOR(1 DOWNTO 0); 

BEGIN 
  PROCESS (Clock) 
  BEGIN 

    IF (Clock'EVENT AND Clock = '1') THEN 

     IF Clear = '1' THEN 
       Count <= "00"; 
     ELSE 
       Count <= Count + 1; 
     END IF; 

   END IF; 
  END PROCESS; 
  Q <= Count; 

END Behavior; 


LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY dec3to8 IS


  PORT ( W : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
  En : IN STD_LOGIC; 
  Y : OUT STD_LOGIC_VECTOR(0 TO 7)); 
END dec3to8; 

ARCHITECTURE Behavior OF dec3to8 IS 

BEGIN 
  PROCESS (W, En) 
  BEGIN 

    IF En = '1' THEN 
--------ylopoihsh tou kwdika tou dec3to8 po epilegei ena apo ta 8 registers
      CASE W IS 
		when "000" => --R0
			Y<="10000000";
		when "001" => --R1
			Y<="01000000";
		when "010" => --R2
			Y<="00100000";
		when "011" => --R3
			Y<="00010000";
		when "100" => --R4
			Y<="00001000";
		when "101" => --R5
			Y<="00000100";
		when "110" => --R6
			Y<="00000010";
		when "111" => --R7
			Y<="00000001";
      END CASE; 
    ELSE 
      Y <= "00000000"; 
    END IF; 
   END PROCESS; 
END Behavior; 




LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY regn IS 
  GENERIC (n : INTEGER := 16); 
  PORT ( R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); 

  Rin, Clock : IN STD_LOGIC; 

  Q : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0)); 
END regn; 

ARCHITECTURE Behavior OF regn IS 

BEGIN 
  PROCESS (Clock) 
  BEGIN 

    IF Clock'EVENT AND Clock = '1' THEN 
      IF Rin = '1' THEN 
        Q <=R; 
      END IF; 
    END IF; 
  END PROCESS; 
END Behavior; 

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY regn9 IS 
  GENERIC (n : INTEGER := 9); 
  PORT ( R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); 

  Rin, Clock : IN STD_LOGIC; 

  Q : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0)); 
END regn9; 

ARCHITECTURE Behavior9 OF regn9 IS 

BEGIN 
  PROCESS (Clock) 
  BEGIN 

    IF Clock'EVENT AND Clock = '1' THEN 
      IF Rin = '1' THEN 
        Q <=R; 
      END IF; 
    END IF; 
  END PROCESS; 
END Behavior9;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY regn2 IS 
  GENERIC (n : INTEGER := 2); 
  PORT ( R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); 

  Rin, Clock : IN STD_LOGIC; 

  Q : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0)); 
END regn2; 

ARCHITECTURE Behavior2 OF regn2 IS 

BEGIN 
  PROCESS (Clock) 
  BEGIN 

    IF Clock'EVENT AND Clock = '1' THEN 
      IF Rin = '1' THEN 
        Q <=R; 
      END IF; 
    END IF; 
  END PROCESS; 
END Behavior2; 