-- Sampler

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sampler is 
    generic (
        -- kan stå tom en så lenge
    );
    port (
        clk, ena, rst   : in std_logic;
        rx_in           : in std_lofic;
        baud_clk        : in std_logic;
        sb_flag         : out std_logic
    );
end entity sampler;

architecture RTL of sampler is
    type state_type is (idle, startbit_detected, sampling);
    signal state : state_type := idle;

    -- Oppretter komponenten ti baud_gen i sampler
    component baud_gen 
        port(
            ena, clk, rst   : in std_logic;
            baud_clk        : out std_logic
        );
    end component baud_gen;

begin
    -- Instansierer baud_gen i sampleren
    i_baud_gen: component baud_gen
        port map (
            clk => clk,
            ena => ena, 
            rst => rst,
            baud_clk => baud_clk 
        )


    p1_process: process(rx_in, baud_clk)
    case state is
        when idle => 
            if falling_edge(rx_in) then 
                -- flag
                sb_flag <= '1';
                state <= startbit_detected;
            end if;

        when startbit_detected =>
            if something then
                -- Ignorer startbit på en eller annen måte 
            end if;

        when sampling => 
            if rising_edge(baud_clk) then
                -- sample RX, skifteregister???
            end if; 

        when others =>
                state => idle;
                --default case
    end case;
end architecture RTL; 
