----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:51:16 03/19/2019 
-- Design Name: 
-- Module Name:    VGAdisp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGAdisp is
      Port (
      Clk_50MHz : in STD_LOGIC;
      LeftY : in  STD_LOGIC_VECTOR (8 downto 0);
      RightY : in  STD_LOGIC_VECTOR (8 downto 0);
      BallX : in  STD_LOGIC_VECTOR (9 downto 0);
      BallY : in  STD_LOGIC_VECTOR (8 downto 0);
		VGA_HS : out STD_LOGIC;
		VGA_VS : out STD_LOGIC;
		VGA_R : out STD_LOGIC;
		VGA_G : out STD_LOGIC;
		VGA_B : out STD_LOGIC
	);


end VGAdisp;

architecture Behavioral of VGAdisp is

signal halfClock : STD_LOGIC;
signal horizontalPosition : integer range 0 to 800 := 0;
signal verticalPosition : integer range 0 to 521 := 0;
signal hsyncEnable : STD_LOGIC;
signal vsyncEnable : STD_LOGIC;

signal CoordX : integer range 0 to 640 := 0;
signal CoordY : integer range 0 to 480 := 0;


begin

clockScaler : process(Clk_50MHz)
	begin
		if Clk_50MHz'event and Clk_50MHz = '1' then
			halfClock <= not halfClock;
		end if;
	end process clockScaler;

signalTiming : process(halfClock)
	begin
		if halfClock'event and halfClock = '1' then
			if horizontalPosition = 800 then
				horizontalPosition <= 0;
				verticalPosition <= verticalPosition + 1;
				
				if verticalPosition = 521 then
					verticalPosition <= 0;
				else
					verticalPosition <= verticalPosition + 1;
				end if;
			else
				horizontalPosition <= horizontalPosition + 1;
			end if;
		end if;
	end process signalTiming;
   
coordinates : process(horizontalPosition, verticalPosition)
	begin
		CoordX <= horizontalPosition - 144;
		CoordY <= verticalPosition - 31;
	end process coordinates;


draw : process(CoordX, CoordY, halfClock, LeftY, RightY, BallX, BallY)
	begin
		if halfClock'event and halfClock = '1' then
			VGA_HS <= hsyncEnable;
			VGA_VS <= vsyncEnable;
      
         VGA_R <= '0';
         VGA_G <= '0';
         VGA_B <= '0';
      
         --left paddle
			if (CoordY < ( to_integer(unsigned(LeftY)) + 90 ) and CoordY > to_integer(unsigned(LeftY)) and CoordX < 30 and CoordX > 15) then
				VGA_R <= '1';
				VGA_G <= '1';
				VGA_B <= '1';
         end if;
         
         --right paddle
         if (CoordY < ( to_integer(unsigned(RightY)) + 90 ) and CoordY > to_integer(unsigned(RightY)) and CoordX < 625 and CoordX > 610) then
				VGA_R <= '1';
				VGA_G <= '1';
				VGA_B <= '1';
			end if;
         
         --ball
         if (CoordY < ( to_integer(unsigned(BallY)) + 15 ) and CoordY > to_integer(unsigned(BallY)) and CoordX < ( to_integer(unsigned(BallX)) + 15 ) and CoordX > to_integer(unsigned(BallX))) then
				VGA_R <= '1';
				VGA_G <= '1';
				VGA_B <= '1';
			end if;
         
		end if;
	end process draw;

vgaSync : process(halfClock, horizontalPosition, verticalPosition)
	begin
		if halfClock'event and halfClock = '1' then
			if horizontalPosition > 0 and horizontalPosition < 97 then
				hsyncEnable <= '0';
			else
				hsyncEnable <= '1';
			end if;
			
			if verticalPosition > 0 and verticalPosition < 3 then
				vsyncEnable <= '0';
			else
				vsyncEnable <= '1';
			end if;
		end if;
	end process vgaSync;

end Behavioral;

