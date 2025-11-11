-- Kompilert og testet i modelsim

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Tom entitet
entity baud_gen_tb is
end baud_gen_tb;

architecture verifier of baud_gen_tb is 
    constant clk_per : time := 1 ns;

    component baud_gen 
        port (
            ena : in std_logic;
            clk : in std_logic;
            rst : in std_logic;
            baud_clk : out std_logic 
        );
    end component baud_gen;

    -- DUT signal
    signal clk     : std_logic;
    signal rst    : std_logic;
    signal baud_clk : std_logic;

    begin
        -- mapper DUT signal til DUV
        i_baud_gen: component baud_gen
            port map (
                ena => ena,
                clk => clk,
                rst => rst,
                baud_clk => baud_clk
            );
        

        -- Klokke-prosess
        p_clk: process
        begin
            clk <= '0';
            wait for clk_per;
            clk <= '1';
            wait for clk_per;
        end process p_clk;

        p_rst: process
        begin
            rst <= '1';
            wait for 15 ns;
            rst <= '0';
            wait;
        end process p_rst;

        p_ena: process 
        begin
            ena <= '0'
            wait for 20 ns;
            ena <= '1';
            wait;
        end process p_ena;

        p_main: process 
            begin
                -- Hva bør testes her?
                wait for 10000 ns;

                -- avslutter simuleringen
                assert false report "Testbench finished" severity failure; 
            end process p_main;
end architecture verifier;