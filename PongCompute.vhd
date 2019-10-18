library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity PongCompute is
    Port ( RotL : in  STD_LOGIC;
           RotR : in  STD_LOGIC;
           Clk_50MHz : in STD_LOGIC;
           DO : in STD_LOGIC_VECTOR (7 downto 0);
           FO : in STD_LOGIC;
           LeftY : out  STD_LOGIC_VECTOR (8 downto 0);
           Line : out  STD_LOGIC_VECTOR (63 downto 0);
           Blank : out  STD_LOGIC_VECTOR (15 downto 0) := "1110111111110111";
           RightY : out  STD_LOGIC_VECTOR (8 downto 0);
           BallX : out  STD_LOGIC_VECTOR (9 downto 0);
           BallY : out  STD_LOGIC_VECTOR (8 downto 0));
end PongCompute;

architecture Behavioral of PongCompute is



signal posLeftY : integer range 0 to 390 := 150;
signal posRightY : integer range 0 to 390 := 150;
signal posBallX : integer range 0 to 625 := 312;
signal posBallY : integer range 0 to 465 := 232;
signal moveBallDirX : integer range -1 to 1 := -1;
signal moveBallDirY : integer range -1 to 1 := -1;
signal count : integer range 0 to 300000 := 0;
signal countBall : integer range 0 to 300000 := 0;
signal leftPoints : integer range 0 to 10 := 0;
signal rightPoints : integer range 0 to 10 := 0;
signal clk1s : STD_LOGIC := '0';
signal clkball : STD_LOGIC := '0';



begin

clockScaler : process(Clk_50MHz)
	begin
		if rising_edge(Clk_50MHz) then
			count <= count + 1;
         
         if count = 250000 then
            clk1s <= not clk1s;
            count <= 0;
         end if;
		end if;
	end process clockScaler;
   
clockScalerBall : process(Clk_50MHz)
	begin
		if rising_edge(Clk_50MHz) then
			countBall <= countBall + 1;
         
         if countBall = 100000 then
            clkball <= not clkball;
            countBall <= 0;
         end if;
		end if;
	end process clockScalerBall;


--move left paddle
reading: process(Clk_50Mhz, RotL, RotR, posLeftY)
   begin
		if rising_edge(Clk_50Mhz) then
         if RotR = '1' and posLeftY < 380 then
            posLeftY <= posLeftY + 10;
         elsif RotL = '1' and posLeftY > 10 then
            posLeftY <= posLeftY - 10;
         end if;
      end if;
		     
   end process reading;

---move right paddle
readingKdb: process(clk1s, DO, FO)
   begin
		if rising_edge(clk1s) and FO = '0' then
         if to_integer(unsigned(DO)) = 29 and posRightY > 10 then 
            posRightY <= posRightY - 10;
         end if;
         if to_integer(unsigned(DO)) = 27 and posRightY < 380 then 
            posRightY <= posRightY + 10;
         end if;
		end if;     
   end process readingKdb;

--move ball
moveBall: process(clkball, posBallX, posBallY, moveBallDirX, moveBallDirY, posLeftY, posRightY)
   begin
      --move in XY axis
      if rising_edge(clkball) then
         --top edge
         if posBallY = 0 then
            moveBallDirY <= 1;
         end if;
		 
         --bottom edge
         if posBallY = 465 then
            moveBallDirY <= -1;
         end if;
		 
         posBallY <= posBallY + moveBallDirY;
         posBallX <= posBallX + moveBallDirX;
		 
         --left edge
         if posBallX = 0 then
            moveBallDirX <= 1;
            posBallX <= 312;
            posBallY <= 232;
            rightPoints <= rightPoints + 1;
			
         end if;
         --right edge
         if posBallX = 625 then
            moveBallDirX <= -1;
            posBallX <= 312;
            posBallY <= 232;
            leftPoints <= leftPoints + 1;
         end if;
         
      end if;
      
      --hit left paddle
      if moveBallDirX = -1 and posBallX = 30 and posBallY > posLeftY - 15 and posBallY < posLeftY + 90 then
         moveBallDirX <= 1;
      end if;
	  
      --hit right paddle
      if moveBallDirX = 1 and posBallX = 595 and posBallY > posRightY - 15 and posBallY < posRightY + 90 then
         moveBallDirX <= -1;
      end if;
      
	  --restart score
      if leftPoints = 10 or rightPoints = 10 then
         leftPoints <= 0;
         rightPoints <= 0;
      end if;
      
	  --write score on LCD
      Line <= "000000000000" & std_logic_vector(to_unsigned(leftPoints,4)) & "00000000000000000000000000000000" & std_logic_vector(to_unsigned(rightPoints,4)) & "000000000000";

end process moveBall;

--send positions to VGAdisp  
writing: process(clk1s, posLeftY, posRightY, posBallX, posBallY)
   begin
		if rising_edge(clk1s) then
         LeftY <= std_logic_vector(to_unsigned(posLeftY, 9));
         RightY <= std_logic_vector(to_unsigned(posRightY, 9));
         BallY <= std_logic_vector(to_unsigned(posBallY, 9));
         BallX <= std_logic_vector(to_unsigned(posBallX, 10));
      end if;
   end process writing;
   
   

end Behavioral;

