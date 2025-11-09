library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_ctrl is
    port (
        clk       : in std_logic;                            -- Klokke
        rstn      : in std_logic;                            -- Aktiv lav reset
        rx_data   : in std_logic_vector(7 downto 0);        -- Mottatt data
        rx_valid  : in std_logic;                            -- Indikator for gyldig mottatt data
        baud_sel  : in std_logic_vector(3 downto 0);         -- Valg av baud rate (Brukes ikke enda)

        sevenseg  : out std_logic_vector(7 downto 0)         -- Data til 7-segment display
        led_pulse : out std_logic                             -- Led på kortet (kort blink ved mottak)
        baud_value : out std_logic_vector(7 downto 0)               -- Baud rate verdi til baud generator (Brukes ikke enda)
    );
end entity uart_ctrl;

--=============================================================================
----------------------- Arkitektur ----------------------------------------------
--=============================================================================     


architecture rtl of uart_ctrl is

type state_type is (IDLE, LATCH_RX);                                 -- Tilstander, vent og latch mottatt data
signal state: state_type := IDLE;                                    -- Nåværende tilstand
signal led_cnt: integer range 0 to 2_000_000;                        -- Juster størrelsen etter ønsket puls lengde
signal reg_rx: std_logic_vector(7 downto 0) := (others =>); '0';     -- Register for mottatt data

process(clk, rstn)
begin   
    if rstn = '0' then
        sevenseg <= (others => '0');
        led_pulse <= '0';
        baud_value <= (others => '0');
        state <= IDLE;
    elsif rising_edge(clk) then
        case state is
            when IDLE =>
             if rx_valid = '1' then
                    reg_rx <= rx_data;
                    sevenseg <= rx_data;
                    led_cnt <= '2_000_000';  -- Juster etter klokkehastighet for ønsket LED puls lengde
                    state <= LATCH_RX;
                else
                    if led_cnt > 0 then
                        led_cnt <= led_cnt - 1;
                        led_pulse <= '1';
                    else
                    led_pulse <= '0';
                end if;
            end if;

            when LATCH_RX =>
                led_pulse <= '0';
                state <= IDLE;

            when others =>
                state <= IDLE;
        end case;
    end if;
end process;

end architecture rtl;



