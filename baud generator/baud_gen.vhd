-- Testet og kompilert i modelsim

-- Baud generator til USART
-- 8x oversampling incl (2x mtp aliasing)
-- 9600 baud -> krever 153 600 sampling rate

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen is 
    generic (
        CLK_DIV : natural := 326 -- divider som gir 153 600 klokkefrekvens 
    );
    port (
        clk : in std_logic; -- clk inn 
        rst : in std_logic; --rst
        baud_clk : out std_logic
    );
end entity baud_gen;

architecture RTL of baud_gen is 
    -- signal
    signal ena      : std_logic := '0';
    signal count0   : natural range 0 to CLK_DIV-1; --count er signal fordi den skal oppdatere seg en gang etter hver gjennomkjøring 
begin
    p1: process(clk)
    begin
        -- aktiv høy reset
        if rst = '1' then
            count0 <= 0;
        elsif rising_edge(clk) then
            -- inkrementerer counter til divider når den er ulik divider
            if count0 /= CLK_DIV-1 then
                count0 <= count0 + 1;
            else
                ena <= not ena;
                count0 <= 0;
                -- resten av logikken må skje her...
            end if;

            if ena = '1' then
                baud_clk <= '1';
            else 
                baud_clk <= '0';
            end if;
        end if;
    end process;
end architecture RTL;
