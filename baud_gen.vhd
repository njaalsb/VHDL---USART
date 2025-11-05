-- Baud generator til USART
-- 8x oversampling incl (2x mtp aliasing)
-- 9600 baud -> krever 153 600 sampling rate

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen is 
    generic (
        F_CLK : integer := 5208; -- divider
    );
    port (
        clk : in std_logic; -- clk inn 
        rst : in std_logic; --rst
        baud: in std_logic_vector(7 downto 0); -- ønsket baud som input
        baud_clk : out std_logic;
    );
end entity baud_gen;

architecture RTL of baud_gen is 
    -- signal
    signal count0   : natural range 0 to F_CLK-1; --count er signal fordi den skal oppdatere seg en gang etter hver gjennomkjøring 
begin
    p1: process(clk) is
        if rst = '1' then
            count0 <= 0;
        elsif rising_edge(clk) then
            -- inkrementerer counter til divider når den er ulik divider
            if count0 /= F_CLK-1 then
                count0 <= count0 + 1;
            else
                count0 <= 0;
                -- resten av logikken må skje her...
            end if;
        end if;
    end process p1;
end architecture RTL;
