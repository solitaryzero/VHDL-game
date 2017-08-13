library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity keyboard is
port (
	CLK_MAIN, CLK_11, CLK_25, CLK_100, RST: in std_logic;
	PS2_CODE: in std_logic_vector(7 downto 0);
	PS2_OE: in std_logic;
	R_KEY, L_ARROW, R_ARROW: out std_logic -- 三个键输出使能，每次按下之后只在CLK_MAIN的一个周期内置1
	) ;
end keyboard ;

architecture kbd of keyboard is
type state_type is (delay,arrow,la,ra,rb,rb_releasing,la_releasing_1,la_releasing_2,ra_releasing_1,ra_releasing_2,la_done,ra_done,rb_done);
signal state:state_type;

begin
	process(RST,PS2_OE,CLK_MAIN,PS2_CODE)
	begin
		if rising_edge(CLK_MAIN) then
			R_KEY <= '0';
			L_ARROW <= '0';
			R_ARROW <= '0';
			case state is 
				when delay =>
					if PS2_OE = '1' then
						if PS2_CODE = "11100000" then
							state <= arrow;
						elsif PS2_CODE = "00101101" then
							state <= rb;
						else 
							state <= delay;
						end if;
					end if;
				when arrow =>
					if PS2_OE = '1' then
						if PS2_CODE = "01101011" then 
							state <= la;
						elsif PS2_CODE = "01110100" then
							state <= ra;
						else 
							state <= delay;
						end if;
					end if;
				when la =>
					if PS2_OE = '1' then
						if PS2_CODE = "11100000" then 
							state <= la_releasing_1;
						else 
							state <= la;
						end if;
					end if;
				when la_releasing_1 =>
					if PS2_OE = '1' then
						if PS2_CODE = "11110000" then 
							state <= la_releasing_2;
						else 
							state <= la;
						end if;
					end if;
				when la_releasing_2 =>
					if PS2_OE = '1' then
						if PS2_CODE = "01101011" then 
							state <= la_done;
						else 
							state <= la;
						end if;
					end if;
				when ra =>
					if PS2_OE = '1' then
						if PS2_CODE = "11100000" then 
							state <= ra_releasing_1;
						else 
							state <= ra;
						end if;
					end if;
				when ra_releasing_1 =>
					if PS2_OE = '1' then
						if PS2_CODE = "11110000" then 
							state <= ra_releasing_2;
						else 
							state <= ra;
						end if;
					end if;
				when ra_releasing_2 =>
					if PS2_OE = '1' then
						if PS2_CODE = "01110100" then 
							state <= ra_done;
						else 
							state <= ra;
						end if;
					end if;
				when rb =>
					if PS2_OE = '1' then
						if PS2_CODE = "11110000" then 
							state <= rb_releasing;
						else 
							state <= rb;
						end if;
					end if;
				when rb_releasing =>
					if PS2_OE = '1' then
						if PS2_CODE = "00101101" then 
							state <= rb_done;
						else 
							state <= rb;
						end if;
					end if;
				when la_done =>
					R_KEY <= '0';
					L_ARROW <= '1';
					R_ARROW <= '0';
					state <= delay;
				when ra_done =>
					R_KEY <= '0';
					L_ARROW <= '0';
					R_ARROW <= '1';
					state <= delay;		
				when rb_done =>
					R_KEY <= '1';
					L_ARROW <= '0';
					R_ARROW <= '0';
					state <= delay;	
				when others =>
					state <= delay;
			end case;
		end if;
	end process;
					
end kbd;
						