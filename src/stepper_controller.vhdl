library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Stepper_Controller is
	port (
		-- Determines the direction of the next step.
		i_direction:	in	std_logic;
		
		-- Signal to move to the next step.
		i_step:		in	std_logic;
		
		-- Debug output for position
		o_position:	out	unsigned(1 downto 0)	:= "00";
		
		-- Stepper motor coil outputs, in tenths of a percent
		o_a1:		out	integer range 0 to 1000	:= 0;
		o_a3:		out	integer range 0 to 1000	:= 0;
		o_b1:		out	integer range 0 to 1000	:= 0;
		o_b3:		out	integer range 0 to 1000	:= 0
	);
end Stepper_Controller;

architecture Behavioral of Stepper_Controller is
	signal position:	unsigned (1 downto 0)	:= "00";
	
	-- Sine wave look up table
	type sine_table_type is array ( 0 to 1 ) of integer range 0 to 1000;
	constant power_table:	sine_table_type := (
		0 => 0,
		1 => 1000
	);
begin

	o_position <= position;
	
	process(i_step) begin
		-- Compare to truth table
		if ( rising_edge( i_step ) ) then
			if ( i_direction = '1' ) then
				position <= position + 1;
			else
				position <= position - 1;
			end if;
		end if;
	end process;
	
	process(position) begin
		case position is
			when "00" =>
				o_a1 <= power_table(1);
				o_a3 <= power_table(0);
				o_b1 <= power_table(0);
				o_b3 <= power_table(0);
				
			when "01" =>
				o_a1 <= power_table(0);
				o_a3 <= power_table(0);
				o_b1 <= power_table(1);
				o_b3 <= power_table(0);
				
			when "10" =>
				o_a1 <= power_table(0);
				o_a3 <= power_table(1);
				o_b1 <= power_table(0);
				o_b3 <= power_table(0);
				
			when "11" =>
				o_a1 <= power_table(0);
				o_a3 <= power_table(0);
				o_b1 <= power_table(0);
				o_b3 <= power_table(1);
			when others =>			
				o_a1 <= power_table(0);
				o_a3 <= power_table(0);
				o_b1 <= power_table(0);
				o_b3 <= power_table(0);
			
		end case;
	end process;
end;
