library	ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;

entity vga_rom is
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
end vga_rom;

architecture behavior of vga_rom is
	
	signal r1,g1,b1   : std_logic_vector(2 downto 0);					
	signal hs1,vs1    : std_logic;				
	signal vector_x : std_logic_vector(9 downto 0);		--X����
	signal vector_y : std_logic_vector(9 downto 0);		--Y����
	signal clk_50,clk: std_logic;
begin

	 process(clk_100)	--������������������������
	 begin
	 if clk_100'event and clk_100='1' then
			clk_50 <= not clk_50;
	 end if;
	 end process;

 -----------------------------------------------------------------------
	 process(clk_50)	--������������������������
	 begin
	 if clk_50'event and clk_50='1' then
			clk <= not clk;
	 end if;
	 end process;
 -----------------------------------------------------------------------
	 process(clk)	--������������������������
	 begin
	 if clk'event and clk='1' then
			if vector_x=799 then
				vector_x <= (others=>'0');
			else
				vector_x <= vector_x + 1;
			end if;
	 end if;
	 end process;

  -----------------------------------------------------------------------
	 process(clk)	--����������������������
	 begin
	  	if clk'event and clk='1' then
			if vector_x=799 then
				if vector_y=524 then
					vector_y <= (others=>'0');
				else
					vector_y <= vector_y + 1;
				end if;
			end if;
	  	end if;
	 end process;
 
  -----------------------------------------------------------------------
	 process(clk) --��ͬ���źŲ�����ͬ������96��ǰ��16��
	 begin
	 if clk'event and clk='1' then
		   	if vector_x>=656 and vector_x<752 then
		    	hs1 <= '0';
		   	else
		    	hs1 <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process(clk) --��ͬ���źŲ�����ͬ������2��ǰ��10��
	 begin
		if clk'event and clk='1' then
	   		if vector_y>=490 and vector_y<492 then
	    		vs1 <= '0';
	   		else
	    		vs1 <= '1';
	   		end if;
	  	end if; 
	 end process;
 -----------------------------------------------------------------------
	 process(clk) --��ͬ���ź�����
	 begin
		if clk'event and clk='1' then
	   		hs <=  hs1;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process(clk) --��ͬ���ź�����
	 begin
		if clk'event and clk='1' then
	   		vs <=  vs1;
	  	end if;
	 end process;
	
 -----------------------------------------------------------------------	
	process(clk,vector_x,vector_y) -- XY���궨λ����
	variable temp_background,temp_root,temp_trunk,temp_left,temp_man,temp_cutting,temp_rip:integer;
	variable temp_timer,temp_hundred,temp_ten,temp_one,temp_digit,temp_timer_1:integer;
	begin  
		if vector_x>=640 or vector_y>=480 then
			r1 <= "000";
			g1	<= "000";
			b1	<= "000";
		elsif(clk'event and clk='1')then
			temp_background := (CONV_INTEGER(vector_y)/4*160)+CONV_INTEGER(vector_x)/4;
			address <= CONV_STD_LOGIC_VECTOR(temp_background,15);
--------------------------------------------------------------------------------------------树根 
			if vector_x >= 220 and vector_x <420 and vector_y >=400 and vector_y <450 then
				temp_root := (CONV_INTEGER(vector_y-400)*200)+CONV_INTEGER(vector_x-220);
				address_root <= CONV_STD_LOGIC_VECTOR(temp_root,14);
				if q_root = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_root(8 downto 6);				  	
					g1 <=q_root(5 downto 3);
					r1 <=q_root(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------血量条
			elsif vector_x >= 590 and vector_x <610 and vector_y >=100 and vector_y <400 then
				temp_timer := (CONV_INTEGER(vector_y)-100)/3;
				temp_timer_1 := CONV_INTEGER(NOW_HP)/CONV_INTEGER(HP_MAXN)*100;
				if temp_timer < temp_timer_1 then 
					b1 <="000";				  	
					g1 <="000";
					r1 <="111";
				else
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------分数百位
			elsif vector_x >= 550 and vector_x <572 and vector_y >=20 and vector_y <50 then
				--temp_hundred := CONV_INTEGER(NOW_SCORE)/100;
				temp_digit := CONV_INTEGER(vector_x-550)+7*22+CONV_INTEGER(vector_y-20)*220;
				address_digit <= CONV_STD_LOGIC_VECTOR(temp_digit,13);
				if q_digit = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_digit(8 downto 6);				  	
					g1 <=q_digit(5 downto 3);
					r1 <=q_digit(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------分数十位
			elsif vector_x >= 580 and vector_x <602 and vector_y >=20 and vector_y <50 then
				--temp_ten := (CONV_INTEGER(NOW_SCORE)/10) MOD 10;
				temp_digit := CONV_INTEGER(vector_x-580)+8*22+CONV_INTEGER(vector_y-20)*220;
				address_digit <= CONV_STD_LOGIC_VECTOR(temp_digit,13);
				if q_digit = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_digit(8 downto 6);				  	
					g1 <=q_digit(5 downto 3);
					r1 <=q_digit(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------分数个位
			elsif vector_x >= 610 and vector_x <632 and vector_y >=20 and vector_y <50 then
				--temp_one := CONV_INTEGER(NOW_SCORE) MOD 10;
				temp_digit := CONV_INTEGER(vector_x-610)+9*22+CONV_INTEGER(vector_y-20)*220;
				address_digit <= CONV_STD_LOGIC_VECTOR(temp_digit,13);
				if q_digit = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_digit(8 downto 6);				  	
					g1 <=q_digit(5 downto 3);
					r1 <=q_digit(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------墓碑
			elsif vector_x >= 150 and vector_x <190 and vector_y >=400 and vector_y <450 and DEAD then
				temp_rip := (CONV_INTEGER(vector_y-400)*40)+CONV_INTEGER(vector_x-110);
				address_rip <= CONV_STD_LOGIC_VECTOR(temp_rip,11);
				if q_rip = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_rip(8 downto 6);				  	
					g1 <=q_rip(5 downto 3);
					r1 <=q_rip(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------左侧玩家普通状态
			elsif vector_x >= 110 and vector_x <220 and vector_y >=310 and vector_y <450 and NOW_PLAYER=PLAYER_LEFT and NOW_CUT=PLAYER_CUT_NONE and not(DEAD) then
				temp_man := (CONV_INTEGER(vector_y-310)*110)+CONV_INTEGER(vector_x-110);
				address_man <= CONV_STD_LOGIC_VECTOR(temp_man,14);
				if q_man = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_man(8 downto 6);				  	
					g1 <=q_man(5 downto 3);
					r1 <=q_man(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------右侧玩家普通状态
			elsif vector_x >= 110 and vector_x <220 and vector_y >=310 and vector_y <450 and NOW_PLAYER=PLAYER_RIGHT and NOW_CUT=PLAYER_CUT_NONE and not(DEAD) then
				temp_man := (CONV_INTEGER(vector_y-310)*110)+CONV_INTEGER(220-vector_x);
				address_man <= CONV_STD_LOGIC_VECTOR(temp_man,14);
				if q_man = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_man(8 downto 6);				  	
					g1 <=q_man(5 downto 3);
					r1 <=q_man(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------左侧玩家砍树状态
			elsif vector_x >= 420 and vector_x <530 and vector_y >=310 and vector_y <450 and NOW_PLAYER=PLAYER_LEFT and NOW_CUT=PLAYER_CUT_ING and not(DEAD) then
				temp_cutting := (CONV_INTEGER(vector_y-310)*110)+CONV_INTEGER(vector_x-420);
				address_cutting <= CONV_STD_LOGIC_VECTOR(temp_cutting,14);
				if q_cutting = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_cutting(8 downto 6);				  	
					g1 <=q_cutting(5 downto 3);
					r1 <=q_cutting(2 downto 0);	
				end if;
---------------------------------------------------------------------------------------------右侧玩家砍树状态
			elsif vector_x >= 420 and vector_x <530 and vector_y >=310 and vector_y <450 and NOW_PLAYER=PLAYER_RIGHT and NOW_CUT=PLAYER_CUT_ING and not(DEAD) then
				temp_cutting := (CONV_INTEGER(vector_y-310)*110)+CONV_INTEGER(530-vector_x);
				address_cutting <= CONV_STD_LOGIC_VECTOR(temp_cutting,14);
				if q_cutting = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_cutting(8 downto 6);				  	
					g1 <=q_cutting(5 downto 3);
					r1 <=q_cutting(2 downto 0);	
				end if;
---------------------------------------------------------------------------------------------第1截树干（从下往上计）
			elsif vector_x >= 246 and vector_x <396 and vector_y >=300 and vector_y <400 then
				temp_trunk := (CONV_INTEGER(vector_y-300)/2*75)+CONV_INTEGER(vector_x-246)/2;
				address_trunk <= CONV_STD_LOGIC_VECTOR(temp_trunk,12);
				b1 <=q_trunk(8 downto 6);				  	
				g1 <=q_trunk(5 downto 3);
				r1 <=q_trunk(2 downto 0);
			elsif vector_x >= 96 and vector_x <246 and vector_y >=300 and vector_y <400 and NOW_TRUNKS(0)=TRUNK_L then
				temp_left := (CONV_INTEGER(vector_y-300)*150)+CONV_INTEGER(vector_x-96);
				address_left <= CONV_STD_LOGIC_VECTOR(temp_left,14);
				if q_left = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_left(8 downto 6);				  	
					g1 <=q_left(5 downto 3);
					r1 <=q_left(2 downto 0);
				end if;
			elsif vector_x >= 396 and vector_x <546 and vector_y >=300 and vector_y <400 and NOW_TRUNKS(0)=TRUNK_R then
				temp_left := (CONV_INTEGER(vector_y-300)*150)+CONV_INTEGER(546-vector_x);
				address_left <= CONV_STD_LOGIC_VECTOR(temp_left,14);
				if q_left = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_left(8 downto 6);				  	
					g1 <=q_left(5 downto 3);
					r1 <=q_left(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------第2截树干
			elsif vector_x >= 246 and vector_x <396 and vector_y >=200 and vector_y <300 then
				temp_trunk := (CONV_INTEGER(vector_y-200)/2*75)+CONV_INTEGER(vector_x-246)/2;
				address_trunk <= CONV_STD_LOGIC_VECTOR(temp_trunk,12);
				b1 <=q_trunk(8 downto 6);				  	
				g1 <=q_trunk(5 downto 3);
				r1 <=q_trunk(2 downto 0);
			elsif vector_x >= 96 and vector_x <246 and vector_y >=200 and vector_y <300 and NOW_TRUNKS(1)=TRUNK_L then
				temp_left := (CONV_INTEGER(vector_y-200)*150)+CONV_INTEGER(vector_x-96);
				address_left <= CONV_STD_LOGIC_VECTOR(temp_left,14);
				if q_left = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_left(8 downto 6);				  	
					g1 <=q_left(5 downto 3);
					r1 <=q_left(2 downto 0);
				end if;
			elsif vector_x >= 396 and vector_x <546 and vector_y >=200 and vector_y <300 and NOW_TRUNKS(1)=TRUNK_R then
				temp_left := (CONV_INTEGER(vector_y-200)*150)+CONV_INTEGER(546-vector_x);
				address_left <= CONV_STD_LOGIC_VECTOR(temp_left,14);
				if q_left = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_left(8 downto 6);				  	
					g1 <=q_left(5 downto 3);
					r1 <=q_left(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------第3截树干
			elsif vector_x >= 246 and vector_x <396 and vector_y >=100 and vector_y <200 then
				temp_trunk := (CONV_INTEGER(vector_y-100)/2*75)+CONV_INTEGER(vector_x-246)/2;
				address_trunk <= CONV_STD_LOGIC_VECTOR(temp_trunk,12);
				b1 <=q_trunk(8 downto 6);				  	
				g1 <=q_trunk(5 downto 3);
				r1 <=q_trunk(2 downto 0);
			elsif vector_x >= 96 and vector_x <246 and vector_y >=100 and vector_y <200 and NOW_TRUNKS(2)=TRUNK_L then
				temp_left := (CONV_INTEGER(vector_y-100)*150)+CONV_INTEGER(vector_x-96);
				address_left <= CONV_STD_LOGIC_VECTOR(temp_left,14);
				if q_left = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_left(8 downto 6);				  	
					g1 <=q_left(5 downto 3);
					r1 <=q_left(2 downto 0);
				end if;
			elsif vector_x >= 396 and vector_x <546 and vector_y >=100 and vector_y <200 and NOW_TRUNKS(2)=TRUNK_R then
				temp_left := (CONV_INTEGER(vector_y-100)*150)+CONV_INTEGER(546-vector_x);
				address_left <= CONV_STD_LOGIC_VECTOR(temp_left,14);
				if q_left = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_left(8 downto 6);				  	
					g1 <=q_left(5 downto 3);
					r1 <=q_left(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------第4截树干
			elsif vector_x >= 246 and vector_x <396 and vector_y >=0 and vector_y <100 then
				temp_trunk := (CONV_INTEGER(vector_y)/2*75)+CONV_INTEGER(vector_x-246)/2;
				address_trunk <= CONV_STD_LOGIC_VECTOR(temp_trunk,12);
				b1 <=q_trunk(8 downto 6);				  	
				g1 <=q_trunk(5 downto 3);
				r1 <=q_trunk(2 downto 0);
			elsif vector_x >= 96 and vector_x <246 and vector_y >=0 and vector_y <100 and NOW_TRUNKS(3)=TRUNK_L then
				temp_left := (CONV_INTEGER(vector_y)*150)+CONV_INTEGER(vector_x-96);
				address_left <= CONV_STD_LOGIC_VECTOR(temp_left,14);
				if q_left = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_left(8 downto 6);				  	
					g1 <=q_left(5 downto 3);
					r1 <=q_left(2 downto 0);
				end if;
			elsif vector_x >= 396 and vector_x <546 and vector_y >=0 and vector_y <100 and NOW_TRUNKS(1)=TRUNK_R then
				temp_left := (CONV_INTEGER(vector_y)*150)+CONV_INTEGER(546-vector_x);
				address_left <= CONV_STD_LOGIC_VECTOR(temp_left,14);
				if q_left = "111111111" then 
					b1 <=q(8 downto 6);				  	
					g1 <=q(5 downto 3);
					r1 <=q(2 downto 0);
				else
					b1 <=q_left(8 downto 6);				  	
					g1 <=q_left(5 downto 3);
					r1 <=q_left(2 downto 0);
				end if;
---------------------------------------------------------------------------------------------填充背景
			else
				b1 <=q(8 downto 6);				  	
				g1 <=q(5 downto 3);
				r1 <=q(2 downto 0);
			end if;
			
		end if;		 
	end process;	

	-----------------------------------------------------------------------输出
	process (r1, g1, b1)	--ɫ������
	begin
		r	<= r1;
		g	<= g1;
		b	<= b1;
	end process;

end behavior;

