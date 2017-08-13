library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity test is
port (
	CLK_MAIN, CLK_11, CLK_25, CLK_100, RST: in std_logic;
	PS2_DATA, PS2_CLK: in std_logic; -- PS2 clk and data
	R_KEY, L_ARROW, R_ARROW: out std_logic -- 三个键输出使能，每次按下之后只在CLK_MAIN的一个周期内置1
	) ;
end test ;

architecture test of test is
component PS2
	port (
	CLK_MAIN, CLK_11, CLK_25, CLK_100, RST: in std_logic;
	PS2_DATA, PS2_CLK: in std_logic; -- PS2 clk and data
	SCANCODE: out std_logic_vector(7 downto 0); -- scan code signal output, 每接收到一组数据即输出
	OE: out std_logic -- 输出使能，每次输出的时候置1，无输出时置0
	) ;
end component;

component keyboard
port (
	CLK_MAIN, CLK_11, CLK_25, CLK_100, RST: in std_logic;
	PS_CODE: in std_logic_vector(7 downto 0);
	PS_OE: in std_logic;
	R_KEY, L_ARROW, R_ARROW: out std_logic -- 三个键输出使能，每次按下之后只在CLK_MAIN的一个周期内置1
	) ;
end component ;

signal ps_code:std_logic_vector(7 downto 0);
signal ps_oe:std_logic;

begin
	a0:PS2 port map (
		CLK_MAIN => CLK_MAIN,
		CLK_11 => CLK_11,
		CLK_25 => CLK_25,
		CLK_100 => CLK_100,
		RST => RST,
		PS2_DATA => PS2_DATA,
		PS2_CLK => PS2_CLK,
		SCANCODE => ps_code,
		OE => ps_oe		
	);
	
	a1:keyboard port map (
		CLK_MAIN => CLK_MAIN,
		CLK_11 => CLK_11,
		CLK_25 => CLK_25,
		CLK_100 => CLK_100,
		RST => RST,
		PS_CODE => ps_code,
		PS_OE => ps_oe,
		R_KEY => R_KEY,
		R_ARROW => R_ARROW,
		L_ARROW => L_ARROW
	);
	
end test;