-- Baud generator til USART
-- 8x oversampling incl (2x mtp aliasing)
-- 9600 baud -> krever 153 600 sampling rate

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen is 
    generic (
        F_CLk : integer := 50_000_000;
    );
    port (
        clk : in std_logic;
        baud: in std_logic_vector(7 downto 0);
        baud_clk : out std_logic;
    );
end entity baud_gen;

architecture RTL of baud_gen is 
    -- signals etc
begin
    p1: process(clk) is
        
    end process p1;


end architecture RTL;
