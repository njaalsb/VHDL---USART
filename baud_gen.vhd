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
    );
end entity baud_gen;
