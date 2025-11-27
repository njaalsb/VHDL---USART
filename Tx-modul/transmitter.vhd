-- Transmitter delen av USART'en
-- Skal være synkron med baud-klokka

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmitter is
    generic (
        tick_time :   natural := 15 --16 baud ticks
    );
    port (
        baud_clk    : in std_logic;
        tx_ready    : in std_logic;
        tx_reg      : in std_logic_vector(7 downto 0);
        tx_out      : out std_logic := '0';
        tx_fin      : out std_logic := '1'
    );
end entity transmitter;

architecture RTL of transmitter is 
    type tx_states is (IDLE, TRANSMIT, FINISH);
    signal tx_state : tx_states := IDLE;
    signal tx_count : natural range 0 to 10 := 0;
    signal div_count: natural range 0 to 15 := 0;

    signal shift_reg: std_logic_vector(9 downto 0) := "1000000000";

    begin
        pt:process(baud_clk)
        begin
            if rising_edge(baud_clk) then

                case tx_state is 
                    when IDLE => 
                        tx_out <= '1';
                        -- gjør ingenting
                        if tx_ready = '1' then
                            shift_reg(8 downto 1) <= tx_reg;
                            tx_state <= TRANSMIT;
                            tx_fin <= '0';
                        end if;

                    when TRANSMIT =>
                        -- sender alltid LSB først
                        tx_out <= shift_reg(0);
                        
                        if div_count = tick_time then
                            -- bitshift mot høyre (ny LSB)
                            shift_reg <= shift_right(unsigned(shift_reg));
                            div_count <= 0;
                            tx_count <= tx_count + 1;
                        elsif div_count /= tick_time then
                            div_count <= div_count + 1;
                        end if;

                        if tx_count = 10 then
                            tx_state <= FINISH;
                        end if;

                    when FINISH =>
                        -- finish
                        tx_count <= 0;
                        div_count <= 0;
                        tx_out <= '1';
                        -- sette flag for å indikere at transmisjonen er fullført
                        tx_fin <= '1';
                        shift_reg <= "1000000000";

                    when others =>
                        tx_state <= IDLE;
                end case;
            end if;

        end process;
end architecture RTL;