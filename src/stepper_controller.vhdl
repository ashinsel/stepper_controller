library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;
use work.config.all;


entity Stepper_Controller is
    port (
        -- Determines the direction of the next step.
        i_direction:    in  std_logic;

        -- Signal to move to the next step.
        i_step:     in  std_logic;

        -- Use microsteps instead of whole steps
        --i_microsteps: in  std_logic_vector(7 downto 0);

        -- Reset signal
        i_reset:    in  std_logic;

        -- Debug output for position, and quadrant
        --o_position:   out std_logic_vector(7 downto 0);
        --o_quadrant:   out std_logic_vector( 1 downto 0 );

        -- Stepper motor coil outputs, in tenths of a percent
        o_a1_m:       out unsigned(9 downto 0)    := (others => '0');
        o_a3_m:       out unsigned(9 downto 0)    := (others => '0');
        o_b1_m:       out unsigned(9 downto 0)    := (others => '0');
        o_b3_m:       out unsigned(9 downto 0)    := (others => '0')
    );
end Stepper_Controller;

architecture Behavioral of Stepper_Controller is
    signal quadrant:    unsigned( 1 downto 0 )          := (others => '0');
    signal position:    unsigned( 7 downto 0 )          := (others => '0');

 type power_table_type is array (0 to 256) of unsigned(15 downto 0);
-- Power table: holds the values of a quarter sine wave, in 0.1%
    constant power_table        :power_table_type   := (
        X"03E8",   X"03E8",   X"03E8",   X"03E8",   X"03E8",   X"03E8",   X"03E7",   X"03E7",
        X"03E7",   X"03E6",   X"03E6",   X"03E6",   X"03E5",   X"03E5",   X"03E4",   X"03E4",
        X"03E3",   X"03E3",   X"03E2",   X"03E1",   X"03E0",   X"03E0",   X"03DF",   X"03DE",
        X"03DD",   X"03DC",   X"03DB",   X"03DA",   X"03D9",   X"03D8",   X"03D7",   X"03D6",
        X"03D5",   X"03D4",   X"03D2",   X"03D1",   X"03D0",   X"03CE",   X"03CD",   X"03CC",
        X"03CA",   X"03C9",   X"03C7",   X"03C5",   X"03C4",   X"03C2",   X"03C0",   X"03BF",
        X"03BD",   X"03BB",   X"03B9",   X"03B7",   X"03B6",   X"03B4",   X"03B2",   X"03B0",
        X"03AE",   X"03AB",   X"03A9",   X"03A7",   X"03A5",   X"03A3",   X"03A1",   X"039E",
        X"039C",   X"039A",   X"0397",   X"0395",   X"0392",   X"0390",   X"038D",   X"038B",
        X"0388",   X"0385",   X"0383",   X"0380",   X"037D",   X"037A",   X"0378",   X"0375",
        X"0372",   X"036F",   X"036C",   X"0369",   X"0366",   X"0363",   X"0360",   X"035D",
        X"035A",   X"0357",   X"0353",   X"0350",   X"034D",   X"034A",   X"0346",   X"0343",
        X"033F",   X"033C",   X"0339",   X"0335",   X"0332",   X"032E",   X"032A",   X"0327",
        X"0323",   X"0320",   X"031C",   X"0318",   X"0314",   X"0311",   X"030D",   X"0309",
        X"0305",   X"0301",   X"02FD",   X"02F9",   X"02F5",   X"02F1",   X"02ED",   X"02E9",
        X"02E5",   X"02E1",   X"02DD",   X"02D8",   X"02D4",   X"02D0",   X"02CC",   X"02C7",

        -- 45 Degrees
        X"02C3",   X"02BF",   X"02BA",   X"02B6",   X"02B2",   X"02AD",   X"02A9",   X"02A4",
        X"02A0",   X"029B",   X"0296",   X"0292",   X"028D",   X"0289",   X"0284",   X"027F",
        X"027A",   X"0276",   X"0271",   X"026C",   X"0267",   X"0262",   X"025E",   X"0259",
        X"0254",   X"024F",   X"024A",   X"0245",   X"0240",   X"023B",   X"0236",   X"0231",
        X"022C",   X"0226",   X"0221",   X"021C",   X"0217",   X"0212",   X"020D",   X"0207",
        X"0202",   X"01FD",   X"01F8",   X"01F2",   X"01ED",   X"01E8",   X"01E2",   X"01DD",
        X"01D7",   X"01D2",   X"01CD",   X"01C7",   X"01C2",   X"01BC",   X"01B7",   X"01B1",
        X"01AC",   X"01A6",   X"01A0",   X"019B",   X"0195",   X"0190",   X"018A",   X"0184",
        X"017F",   X"0179",   X"0173",   X"016E",   X"0168",   X"0162",   X"015C",   X"0157",
        X"0151",   X"014B",   X"0145",   X"0140",   X"013A",   X"0134",   X"012E",   X"0128",
        X"0122",   X"011C",   X"0117",   X"0111",   X"010B",   X"0105",   X"00FF",   X"00F9",
        X"00F3",   X"00ED",   X"00E7",   X"00E1",   X"00DB",   X"00D5",   X"00CF",   X"00C9",
        X"00C3",   X"00BD",   X"00B7",   X"00B1",   X"00AB",   X"00A5",   X"009F",   X"0099",
        X"0093",   X"008D",   X"0087",   X"0080",   X"007A",   X"0074",   X"006E",   X"0068",
        X"0062",   X"005C",   X"0056",   X"0050",   X"004A",   X"0043",   X"003D",   X"0037",
        X"0031",   X"002B",   X"0025",   X"001F",   X"0019",   X"0012",   X"000C",   X"0006",
        X"0000"
    );

begin
    -- Resets the controller to a known state.
    --process(i_reset) begin
    --  if( rising_edge(i_reset) ) then
    --      quadrant <= (others => '0');
    --      position <= (others => '0');
    --      out1 <= 0;
    --      out2 <= 0;
    --  end if;
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

    --o_position <= std_logic_vector(position);
    --o_quadrant <= quadrant;

    o_a1_m <= power_table(to_integer(position))(9 downto 0) when quadrant="00"
        else  power_table( 256 - to_integer(position))(9 downto 0) when quadrant="11"
        else (others => '0');

    o_a3_m <= power_table(to_integer(position))(9 downto 0) when quadrant="10"
        else power_table( 256 - to_integer(position))(9 downto 0) when quadrant="01"
        else (others => '0');

    o_b1_m <= power_table(to_integer(position))(9 downto 0) when quadrant="01"
        else power_table( 256 - to_integer(position))(9 downto 0) when quadrant="00"
        else (others => '0');

    o_b3_m <= power_table(to_integer(position))(9 downto 0) when quadrant="11"
        else power_table( 256 - to_integer(position))(9 downto 0) when quadrant="10"
        else (others => '0');
end;
