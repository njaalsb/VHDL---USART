-- Sampler

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sampler is 
    generic (
        -- Måtte ha en generic her for at programmet skulle kompilere 
        -- Ikke nødvendig, men tenkte det kunne være greit å ha i tilfelle hehe
        F_CLK : natural := 50_000_000
    );
    port (
        clk, ena, rst   : in std_logic;
        rx_in           : in std_logic;
        baud_clk        : out std_logic;
        sb_flag         : out std_logic;
        rx_ready        : out std_logic;
        rx_out          : out std_logic_vector(7 downto 0)
    );
end entity sampler;

architecture RTL of sampler is
    -- Oppretter en type for FSM
    type state_type is (idle, startbit_detected, sampling, rx_finished);
    signal state : state_type := idle;

    signal counter  : natural range 0 to 15;

    signal bit_count: natural range 0 to 7;
    signal vote     : natural range 0 to 5;
    signal shift_reg: std_logic_vector(7 downto 0);

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
        if rising_edge(clk) then
            
            case state is
                when idle => 
                    if baud_clk = '1' and rx_in = '0' then
                        rx_ready <= '0';
                        counter <= 1;
                        state <= startbit_detected;
                    else 
                        counter <= 0;
                    end if;

                when startbit_detected =>
                -- vente antall ticks gitt av baud_clk 
                    if baud_clk = '1' then
                        counter <= counter + 1;
                    end if;

                    if counter >= 16 then 
                        state <= sampling;
                        counter <= 0;
                    end if;

                when sampling => 
                    if baud_clk = '1' then
                        -- Dette skal i teorien skje 16/bit
                        counter <= counter + 1;
                        if 6 < counter AND counter < 12 then 
                            if rx_in = '1' then 
                                vote <= vote + 1;
                            end if;
                        elsif 16 <= counter then
                            -- nytt bit
                            if vote >= 3 then
                                -- bitshift til venstre 
                                shift_reg <= '1' & shift_reg(7 downto 1); 
                                
                                counter <= 0;
                                bit_count <= bit_count + 1;
                                vote <= 0;
                            else
                                -- bitshift til venstre
                                shift_reg <= '0' &shift_reg(7 downto 1); 
                                
                                counter <= 0;
                                bit_count <= bit_count + 1;
                                vote <= 0;
                            end if;

                            if bit_count = 8 then
                                state <= rx_finished;
                            end if;
                        end if;
                    end if; 

                when rx_finished => 
                    
                    rx_out <= shift_reg;
                    rx_ready <= '1';
                    bit_count <= 0;
                    state <= idle;

                when others =>
                    state <= idle;
                        --default case
            end case; 
        end if;
    end process p1_process;
end architecture RTL; 
