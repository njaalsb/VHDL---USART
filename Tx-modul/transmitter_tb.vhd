-- transmitter testbenk 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmitter_tb is
    generic(
        constant test_byte : std_logic_vector(9 downto 0) := "1" & "01011101" & "0"
    );
end entity transmitter_tb;

architecture RTL of transmitter_tb is

    component transmitter is
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
    end component transmitter;
    
    -- DOOT signaler 

    -- Andre signaler

    begin

        i_transmitter : component transmitter
            port map (

            );


        -- klokkeprosess
        p_clk : process
        begin
            --høy
            wait for 10 ns;
            -- lav 
            wait for 10 ns;
        end process;

        p_tx : process 
        begin
            -- main prosess, målet med denne prosessen:
            -- Sjekke at det utsendte signalet er riktig
            -- Sjekke at det er nøyaktig 16 ticks per bit
        end process;

end architecture RTL;