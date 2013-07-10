LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Testbench entity
entity Stepper_Controller_Test is
end Stepper_Controller_Test;

architecture behavior of Stepper_Controller_Test is
	-- Declare the Unit Under Test
	component Stepper_Controller
		port(
			i_direction:	in	std_logic;
			i_step:		in	std_logic;
			i_reset:	in	std_logic;
			--i_microsteps:	in	std_logic_vector(7 downto 0);
			--o_position:	out	natural range 0 to 1000;
			--o_quadrant:	out	std_logic_vector(1 downto 0);
			o_a1:		out	unsigned (9 downto 0);
			o_a3:		out	unsigned (9 downto 0);
			o_b1:		out	unsigned (9 downto 0);
			o_b3:		out	unsigned (9 downto 0)
		);
	end component;
	
	-- Declare inputs, and initialize them
	signal direction:	std_logic			:= '0';
	signal step:		std_logic			:= '0';
	signal reset:		std_logic			:= '0';
	--signal microsteps:	std_logic_vector(7 downto 0)	:= "00000000";
	
	-- Declare outputs, and initialize them.
	--signal position:	natural range 0 to 1000;
	--signal quadrant:	std_logic_vector(1 downto 0);
	signal a1:		unsigned (9 downto 0)		:= (others => '0');
	signal a3:		unsigned (9 downto 0)		:= (others => '0');
	signal b1:		unsigned (9 downto 0)		:= (others => '0');
	signal b3:		unsigned (9 downto 0)		:= (others => '0');
	
begin
	UUT: Stepper_Controller port map (
		i_direction => direction,
		i_step => step,
		i_reset => reset,
		--i_microsteps => microsteps,
		--o_position => position,
		--o_quadrant => quadrant,
		o_a1 => a1,
		o_a3 => a3,
		o_b1 => b1,
		o_b3 => b3
	);
	
	-- Clock process
	clk_process : process
	begin
		step <= '0';
		wait for 1 ns;
		step <= '1';
		wait for 1 ns;
	end process;
	
	-- Stimulus process
	stimulus : process
	begin
		wait for 4 ns;
		reset <= '1';
		wait for 3 ns;
		reset <= '0';
		wait for 10 ns;
		direction <= '1';
		wait for 100 ns;
		direction <= '0';
		wait for 150 ns;
		direction <= '1';
		wait;
	end process;
end;