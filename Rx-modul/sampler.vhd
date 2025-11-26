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

    signal counter  : natural range 0 to 16;

    signal bit_count: integer range 0 to 7;
    signal vote     : integer range 0 to 7 := 0;
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


p1_process: process(baud_clk, rst)
    variable next_counter : natural;
begin
    -- ASYNKRON RESET
    if rst = '1' then
        vote      <= 0;
        counter   <= 0;
        bit_count <= 0;
        state     <= idle;
        rx_ready  <= '0';
        shift_reg <= (others => '0');

    -- SYNSKRON LOGIKK
    elsif rising_edge(baud_clk) then
        next_counter := counter;

        case state is

            when idle =>
                if rx_in = '0' then
                    rx_ready <= '0';
                    counter  <= 1;
                    state    <= startbit_detected;
                else
                    counter <= 0;
                end if;

            when startbit_detected =>
                if counter < 16 then
                    counter <= counter + 1;
                    sb_flag <= '1';
                else
                    counter <= 1;
                    state   <= sampling;
                    sb_flag <= '0';
                end if;

            when sampling =>
                if (counter > 6) and (counter < 12) then
                    if rx_in = '1' then
                        vote <= vote + 1;
                    end if;
                    next_counter := counter + 1;

                elsif counter = 16 then
                    next_counter := 0;
         	

                    -- store the received bit
                    if vote >= 3 then
                        shift_reg <= '1' & shift_reg(7 downto 1);
                    else
                        shift_reg <= '0' & shift_reg(7 downto 1);
                    end if;

                    vote <= 0;

                    if bit_count = 7 then
                        state <= rx_finished;
                    else
                        bit_count <= bit_count + 1;
                    end if;

                else
                    next_counter := counter + 1;
                end if;

                counter <= next_counter;

            when rx_finished =>
                rx_out   <= shift_reg;
                rx_ready <= '1';
                bit_count <= 0;
                counter   <= 0;
                state     <= idle;

            when others =>
                state <= idle;
        end case;
    end if;
end process;

end architecture RTL; 