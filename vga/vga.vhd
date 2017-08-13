library ieee;
use ieee.std_logic_1164.all;

entity vga is
port(
	CLK_MAIN, CLK_11, CLK_25, CLK_100, RST: in std_logic;
	NOW_PLAYER: in std_logic;
	NOW_CUT: in std_logic;
	NOW_TRUNKS: in ITrunkList;
	NOW_HP: in std_logic_vector(9 downto 0);
	NOW_SCORE: in std_logic_vector(9 downto 0);
	NOW_TIMER: in std_logic_vector(31 downto 0);
	HS, VS: out std_logic; --行同步、场同步信号
	oRed : out std_logic_vector (2 downto 0);
	oGreen : out std_logic_vector (2 downto 0);
	oBlue : out std_logic_vector (2 downto 0)
);
end vga;

architecture vga of vga is

component vga_rom is
	 port(
			NOW_PLAYER: in std_logic;
			NOW_CUT: in std_logic;
			NOW_TRUNKS: in ITrunkList;
			NOW_HP: in std_logic_vector(9 downto 0);
			NOW_SCORE: in std_logic_vector(9 downto 0);
			NOW_TIMER: in std_logic_vector(31 downto 0);
			address		:		  out	STD_LOGIC_VECTOR(14 DOWNTO 0);
			address_root,address_left : out STD_LOGIC_VECTOR(13 downto 0);
			address_trunk : out STD_LOGIC_VECTOR(11 downto 0);
			address_man,address_cutting : out STD_LOGIC_VECTOR(13 downto 0);
			address_rip : out STD_LOGIC_VECTOR(10 downto 0);
			address_digit :out STD_LOGIC_VECTOR(12 downto 0);
			q,q_root		:		  in STD_LOGIC_VECTOR(8 DOWNTO 0);
			q_trunk,q_left		:		  in STD_LOGIC_VECTOR(8 DOWNTO 0);
			q_man,q_cutting,q_rip 	: in STD_LOGIC_VECTOR(8 DOWNTO 0);
			q_digit		:		  in STD_LOGIC_VECTOR(8 DOWNTO 0);
			clk_100     :         in  STD_LOGIC; --50Mʱ������
			hs,vs       :         out STD_LOGIC; --��ͬ������ͬ���ź�
			r,g,b       :         out STD_LOGIC_vector(2 downto 0)
	  );
end component;

component background IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
end component;

component tree_root IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END component;

component trunk IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END component;

component left_tree IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END component;

component man IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END component;

component man_cutting IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END component;

component rip IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END component;

component digit IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END component;

signal address_tmp: std_logic_vector(14 downto 0);
signal address_tmp_root,address_tmp_left: std_logic_vector(13 downto 0);
signal address_tmp_trunk: std_logic_vector(11 downto 0);
signal address_tmp_man,address_tmp_cutting: std_logic_vector(13 downto 0);
signal address_tmp_rip: std_logic_vector(10 downto 0);
signal address_tmp_digit: std_logic_vector(12 downto 0);
signal q_tmp,q_tmp_root,q_tmp_trunk,q_tmp_left,q_tmp_man,q_tmp_cutting,q_tmp_rip,q_tmp_digit: std_logic_vector(8 downto 0);

begin

u1: vga_rom port map(
						NOW_PLAYER=>NOW_PLAYER,
						NOW_CUT=>NOW_CUT,
						NOW_TRUNKS=>NOW_TRUNKS,
						NOW_HP=>NOW_HP,
						NOW_SCORE=>NOW_SCORE,
						NOW_TIMER=>NOW_TIMER,
						address=>address_tmp, 
						address_root=>address_tmp_root,
						address_trunk=>address_tmp_trunk,
						address_left=>address_tmp_left,
						address_man=>address_tmp_man,
						address_cutting=>address_tmp_cutting,
						address_rip=>address_tmp_rip,
						address_digit=>address_tmp_digit,
						q=>q_tmp,
						q_root=>q_tmp_root,
						q_trunk=>q_tmp_trunk,
						q_left=>q_tmp_left,
						q_man=>q_tmp_man,
						q_cutting=>q_tmp_cutting,
						q_rip=>q_tmp_rip,
						q_digit=>q_tmp_digit,
						clk_100=>CLK_MAIN, 
						hs=>HS, vs=>VS, 
						r=>oRed, g=>oGreen, b=>oBlue
					);
u2: background port map(	
						address=>address_tmp, 
						clock=>CLK_MAIN, 
						q=>q_tmp
					);
u3: tree_root port map(
						address=>address_tmp_root, 
						clock=>CLK_MAIN, 
						q=>q_tmp_root
					);
u4: trunk port map(
						address=>address_tmp_trunk, 
						clock=>CLK_MAIN, 
						q=>q_tmp_trunk
					);
u5: left_tree port map(
						address=>address_tmp_left, 
						clock=>CLK_MAIN, 
						q=>q_tmp_left
					);
u6: man port map(
						address=>address_tmp_man, 
						clock=>CLK_MAIN, 
						q=>q_tmp_man
					);
u7: man_cutting port map(
						address=>address_tmp_cutting, 
						clock=>CLK_MAIN, 
						q=>q_tmp_cutting
					);
u8: rip port map(
						address=>address_tmp_rip, 
						clock=>CLK_MAIN, 
						q=>q_tmp_rip
					);
u9: digit port map(
						address=>address_tmp_digit, 
						clock=>CLK_MAIN, 
						q=>q_tmp_digit
					);
end vga;