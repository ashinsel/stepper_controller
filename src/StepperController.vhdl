library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity StepperDriver is
    port (
            clk:        in  std_logic           :='0';
            prescaler:  in  std_logic_vector(15 downto 0) := (others => '0');
            direction:  in  std_logic           :='0';
            reset:      in  std_logic           :='0';
            step:       in  std_logic           :='0';
            --counter:    out std_logic_vector(9 downto 0);
            a1:         out std_logic;
            a3:         out std_logic;
            b1:         out std_logic;
            b3:         out std_logic--;
            --o_leds:     out std_logic_vector(7 downto 0);
            --o_a1_match:   out std_logic_vector(9 downto 0)
    );
end StepperDriver;

architecture structural of StepperDriver is
    component stepper_controller is
        port (
            i_direction:    in  std_logic;
            i_step:         in  std_logic;
            i_reset:        in  std_logic;
            --o_position:     out std_logic_vector(7 downto 0);
            o_a1_m:         out unsigned(9 downto 0)    := (others => '0');
            o_a3_m:         out unsigned(9 downto 0)    := (others => '0');
            o_b1_m:         out unsigned(9 downto 0)    := (others => '0');
            o_b3_m:         out unsigned(9 downto 0)    := (others => '0')
        );
    end component;

    component stepper_pwm is
        port (
            i_clk:      in  std_logic;
            i_prescaler:    in  std_logic_vector(15 downto 0);
            i_reset:    in  std_logic;
            i_match_a1: in  unsigned(9 downto 0);
            i_match_a3: in  unsigned(9 downto 0);
            i_match_b1: in  unsigned(9 downto 0);
            i_match_b3: in  unsigned(9 downto 0);
            o_a1:       out std_logic;
            o_a3:       out std_logic;
            o_b1:       out std_logic;
            o_b3:       out std_logic--;
            --o_counter:  out std_logic_vector(9 downto 0)
        );
    end component;

    signal a1_match: unsigned(9 downto 0)   := (others => '0');
    signal a3_match: unsigned(9 downto 0)   := (others => '0');
    signal b1_match: unsigned(9 downto 0)   := (others => '0');
    signal b3_match: unsigned(9 downto 0)   := (others => '0');

begin
    --o_a1_match <= std_logic_vector(a1_match);
    controller: stepper_controller port map (
        i_step => step,
        i_direction => direction,
        i_reset => reset,
        --o_position => o_leds,
        o_a1_m => a1_match,
        o_a3_m => a3_match,
        o_b1_m => b1_match,
        o_b3_m => b3_match
    );

    pwm_out: stepper_pwm port map (
        i_clk => clk,
        i_prescaler => prescaler,
        i_reset => reset,
        i_match_a1 => a1_match,
        i_match_a3 => a3_match,
        i_match_b1 => b1_match,
        i_match_b3 => b3_match,
        o_a1 => a1,
        o_a3 => a3,
        o_b1 => b1,
        o_b3 => b3
        --o_counter => counter
    );

end structural;

