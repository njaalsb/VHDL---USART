-- Start_bit_detektor 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity start_bit_det is 
    generic (
        -- kan stå tom en så lenge
    );
    port (
        clk, ena, rst   : in std_logic;
        rx_in           : in std_lofic;
        sb_flag         : out std_logic
    );
end entity start_bit_det;

architecture RTL of start_bit_det is
begin
    process (rx_in)
    begin
        if falling_edge(rx_in) then 
            -- send ut flag 
            sb_flag <= '1';
        end if;
    end process;
end architecture RTL; 
