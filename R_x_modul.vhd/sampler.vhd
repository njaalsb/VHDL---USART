-- Sampler

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sampler is 
    generic (
        -- kan stå tom en så lenge
        F_CLK : natural := 50_000_000
    );
    port (
        clk, ena, rst   : in std_logic;
        rx_in           : in std_logic;
        baud_clk        : in std_logic;
        sb_flag         : out std_logic;
        rx_out          : out std_logic_vector(7 downto 0)
    );
end entity sampler;

architecture RTL of sampler is
    -- Oppretter en type for FSM
    type state_type is (idle, startbit_detected, sampling, rx_ready);
    signal state : state_type := idle;

    signal counter  : natural range 0 to 15;
    signal bit_count: natural range 0 to 7;
    signal vote     : natural range 0 to 5;
    signal shift_reg: std_logic_vector(7 downto 0);
    signal clk_sw   : boolean;

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
        );


    p1_process: process(baud_clk)
    begin
        if clk_sw = false then        
            case state is
                when idle => 
                    -- do nuthin
                    clk_sw <= true;
                    counter <= 0;

                when startbit_detected =>
                -- vente antall ticks gitt av baud_clk 
                    if rising_edge(baud_clk) then
                        counter <= counter + 1;
                    end if;

                    if counter >= 16 then 
                        state <= sampling;
                        counter <= 0;
                    end if;

                when sampling => 
                    if rising_edge(baud_clk) then
                        -- Dette skal i teorien skje 16/bit
                        counter <= counter + 1;
                        if 6 < counter AND counter < 12 then 
                            vote <= vote + to_integer(unsigned(rx_in));
                        elsif 16 <= counter then
                            -- nytt bit
                            if vote >= 3 then
                                shift_reg(0) <= '1';
                                counter <= 0;
                                -- bitshift til venstre somehow
                                bit_count <= bit_count + 1;
                            else
                                shift_reg(0) <= '0';
                                counter <= 0;
                                -- bitshift til venstre somehow
                                bit_count <= bit_count + 1;
                            end if;

                            if bit_count = 8 then
                                state <= rx_ready;
                            end if;
                        end if;
                    end if; 

                when rx_ready => 
                    
                     
                        


                when others =>
                    state <= idle;
                        --default case
            end case;
        end if;
    end process p1_process;

    p2_process: process(rx_in)
    begin
        if clk_sw = true AND falling_edge(rx_in) then
            -- flag
            counter <= 0;
            sb_flag <= '1';
            clk_sw <= false;
        end if;
    end process p2_process;

end architecture RTL; 
