-- transmitter testbenk 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmitter_tb is
    generic(
        constant test_byte : std_logic_vector(7 downto 0) := "01011101"  -- data only (LSB first)
        --bit_time  : time := 104.32 ns  -- 16 baud_clk ticks * 6.52 ns per tick
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
    signal baud_clk     : std_logic;
    signal tx_ready     : std_logic := '0';
    signal tx_reg       : std_logic_vector(7 downto 0) := test_byte;
    signal tx_out       : std_logic := '1';
    signal tx_fin       : std_logic;
    -- Andre signaler

    begin

        i_transmitter : component transmitter
            port map (
                baud_clk => baud_clk,
                tx_ready => tx_ready,
                tx_reg => tx_reg,
                tx_out => tx_out,
                tx_fin => tx_fin
            );


        -- klokkeprosess
        p_clk : process
        begin
            baud_clk <= '1';
            wait for 10 ps;
            baud_clk <= '0';
            wait for 10 ps;
        end process;

        p_tx : process 
        begin
            -- main prosess, målet med denne prosessen:
            -- Sjekke at det utsendte signalet er riktig
            -- Sjekke at det er nøyaktig 16 ticks per bit
            wait for 100 ns;

            tx_ready <= '1';
            wait for 20 ps;  -- hold for one clock cycle
            tx_ready <= '0';

            wait;

        end process;

end architecture RTL;