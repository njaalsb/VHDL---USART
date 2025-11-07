-- Kompilerer i Modelsim

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
            clk : in std_logic;
            rst : in std_logic;
            baud_clk : out std_logic 
        );
    end component baud_gen;

    -- DUT signal
    signal clk_in      : std_logic;
    signal rst_in      : std_logic;
    signal baud_clk_out : std_logic;

    begin
        -- mapper DUT signal til DUV
        i_baud_gen: component baud_gen
            port map (
                clk => clk_in,
                rst => rst_in,
                baud_clk => baud_clk_out
            );
        

        -- Klokke-prosess
        p_clk: process
        begin
            clk_in <= '0';
            wait for clk_per;
            clk_in <= '1';
            wait for clk_per;
        end process p_clk;

        p_rst: process
        begin
            rst_in <= '1';
            wait for 25 ns;
            rst_in <= '0';
            wait;
        end process p_rst;

        p_main: process 
            begin
                -- Hva bør testes her?

                -- avslutter simuleringen
                assert false report "Testbench finished" severity failure; 
            end process p_main;
end architecture verifier;