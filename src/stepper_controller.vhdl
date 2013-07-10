library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;
use work.config.all;


entity Stepper_Controller is
	port (
		-- Determines the direction of the next step.
		i_direction:	in	std_logic;
		
		-- Signal to move to the next step.
		i_step:		in	std_logic;
		
		-- Use microsteps instead of whole steps
		--i_microsteps:	in	std_logic_vector(7 downto 0);
		
		-- Reset signal
		i_reset:	in	std_logic;
		
		-- Debug output for position, and quadrant
		--o_position:	out	natural range 0 to 1000;--snum_microsteps;
		--o_quadrant:	out	std_logic_vector( 1 downto 0 );
		
		-- Stepper motor coil outputs, in tenths of a percent
		o_a1:		out	unsigned(9 downto 0)	:= (others => '0');
		o_a3:		out	unsigned(9 downto 0)	:= (others => '0');
		o_b1:		out	unsigned(9 downto 0)	:= (others => '0');
		o_b3:		out	unsigned(9 downto 0)	:= (others => '0')
	);
end Stepper_Controller;

architecture Behavioral of Stepper_Controller is
	signal quadrant:	unsigned( 1 downto 0 )			:= (others => '0');
	signal position:	unsigned( 7 downto 0 )			:= (others => '0');

begin	
	-- Resets the controller to a known state.
	--process(i_reset) begin
	--	if( rising_edge(i_reset) ) then
	--		quadrant <= (others => '0');
	--		position <= (others => '0');
	--		out1 <= 0;
	--		out2 <= 0;
	--	end if;		
	--end process;
		
	process(i_reset, i_step) begin
		if ( i_reset = '1' ) then
			quadrant <= (others => '0');
			position <= (others => '0');
		
		else if ( rising_edge( i_step ) ) then
		
			-- Increasing position
			if ( i_direction = '0' ) then
				if ( position = 255 ) then
					-- Switch quadrants.
					quadrant <= quadrant + 1;
				end if;
				position <= position + 1;				
				
			-- Decreasing position
			else
				if ( position = 0 ) then
					-- Switch quadrants.
					quadrant <= quadrant - 1;
				end if;
				position <= position - 1;

			end if;	
		end if;
		end if;
	end process;
	
	process(position) begin		
	end process;	
	
	--o_position <= position;
	--o_quadrant <= quadrant;
	
	o_a1 <= to_unsigned( power_table(to_integer(position))  , 10) when quadrant="00"
		else to_unsigned( power_table( 256 - to_integer(position)), 10) when quadrant="11"
		else (others => '0');
	
	o_a3 <= to_unsigned( power_table(to_integer(position))  , 10) when quadrant="10"
		else to_unsigned( power_table( 256 - to_integer(position)), 10) when quadrant="01"
		else (others => '0');
	
	o_b1 <= to_unsigned( power_table(to_integer(position))  , 10) when quadrant="01"
		else to_unsigned( power_table( 256 - to_integer(position)), 10) when quadrant="00"
		else (others => '0');
	
	o_b3 <= to_unsigned( power_table(to_integer(position))  , 10) when quadrant="11"
		else to_unsigned( power_table( 256 - to_integer(position)), 10) when quadrant="10"
		else (others => '0');
end;
