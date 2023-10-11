library ieee;
use ieee.std_logic_1164.all;

entity erotima2 is                                       -- erotima2 einai h ALU 16-bit
    port (
        a:          in  std_logic_vector (15 downto 0);
        b:          in  std_logic_vector (15 downto 0);
        opcode:     in  std_logic_vector (2 downto 0);
        res:     out std_logic_vector (15 downto 0);
        co:  out std_logic
    );
end entity;

architecture total of erotima2 is
    component erotima1 is                                    --apoteleitai apo slices ALU 1-bit
       port (a, b, ainv, binv, ci: in std_logic;
       op: in std_logic_vector(1 downto 0);
       res ,co: out std_logic);
    end component;
    component controlcircuit is                             --monada pou elegxei poia praksh tha pragmatopoieitai
        port (
            opcode:  in  std_logic_vector(2 downto 0);
            ainv:    out std_logic;
            binv:    out std_logic;
            op:  out std_logic_vector(1 downto 0);
            ci:    out std_logic  
        );
    end component;

    signal ainv:     std_logic;
    signal binv:     std_logic;
    signal op:   std_logic_vector (1 downto 0);
    signal carry:       std_logic_vector (16 downto 0);
begin

K1: controlcircuit port map (
            opcode => opcode,
            ainv => ainv,
            binv => binv,
            op => op,
            ci => carry(0)   
        );

GEN:    for i in 0 to 15 generate                       --dhmiourgia 16 ALU 1-bit
K2: erotima1  port map (
                a => a(i),
                b => b(i),
                ainv => ainv,
                binv => binv,
                ci => carry(i),
                op => op,
                res => res(i),
                co => carry(i + 1)                     --carryout ths kathe ALU einai to carryin ths epomenhs
            );
    end generate;
    
    co <= carry(16) when op = "10" else '0';           --overflow twn praksewn prosthesis/afairesis

end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity controlcircuit is
        port (
            opcode:  in  std_logic_vector(2 downto 0);
            ainv:    out std_logic;
            binv:    out std_logic;
            op:  out std_logic_vector(1 downto 0);
            ci:    out std_logic);  
		 end controlcircuit;

architecture model_conc8 of controlcircuit is	
begin
process(opcode)
begin

case opcode is 

    --AND--
    when "000"=>
        op <= "00";
        ainv <= '0';
        binv  <= '0';
        ci  <= '0';

    --OR--
    when "001" =>
        op <= "01";
        ainv   <= '0';
        binv      <= '0';
        ci  <= '0';

    --ADD--         
    when "011" =>
        op <= "10";
        ainv   <= '0';
        binv   <= '0';
        ci  <= '0';

    --SUB--
    when "010" =>
        op <= "10";
        ainv   <= '0';
        binv      <='1';
        ci  <= '1';

    --NOR--
    when "101"=>
        op <= "00";
        ainv  <= '1';
        binv      <= '1';
        ci  <= '0';

    --xor
    when "100" =>
        op <= "11";
        ainv  <= '0';
        binv      <= '0';
        ci  <= '0';

    --Adiafores times--
when others =>
        op <= "00";
        ainv   <= '0';
        binv      <= '0';
        ci  <= '0';
    end case;
    end process;
end model_conc8;	 