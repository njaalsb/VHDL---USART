library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity uart_ctrl_tb is
end uart_ctrl_tb;   

architecture verifier of uart_ctrl_tb is
    constant clk_per : time := 10 ns;  -- 100 Mhz klokke

    component uart_ctrl 
        port (
            clk  : in std_logic;                               -- Klokke
            rstn    : in std_logic;                            -- Aktiv lav reset
            rx_data   : in std_logic_vector(7 downto 0);        -- Mottatt data
            rx_valid  : in std_logic;                            -- Indikator for gyldig mottatt data

            sevenseg_high  : out std_logic_vector(7 downto 0);         -- Øvre 7-segment
            sevenseg_low  : out std_logic_vector(7 downto 0);         -- nedre 7-segment
            led_pulse : out std_logic                             -- Led på kortet (kort blink ved mottak)
        );
    end component uart_ctrl;

    -- DUT signaler
    signal clk     : std_logic := '0';
    signal rstn      : std_logic := '1';
    signal rx_data   : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_valid : std_logic := '0';

    signal sevenseg_high  : std_logic_vector(7 downto 0);
    signal sevenseg_low   : std_logic_vector(7 downto 0);
    signal led_pulse    : std_logic;

begin
    -- Mapper DUT signaler til DUV
    i_uart_ctrl: component uart_ctrl
        port map (
            clk      => clk,
            rstn      => rstn,
            rx_data   => rx_data,
            rx_valid  => rx_valid,
            sevenseg_high  => sevenseg_high,
            sevenseg_low   => sevenseg_low,
            led_pulse => led_pulse
        );

    -- Klokke prosess
    p_clk: process
    begin
        clk <= '0';
        wait for clk_per;
        clk <= '1';
        wait for clk_per;
    end process p_clk;

    p_rst: process
    begin
        rstn <= '0';
        wait for 15 ns;
        rstn <= '1';
        wait;
    end process p_rst;

    p_main: process 
    begin
        -- vent til reset er ferdig
        wait until rstn = '1';
        wait until rising_edge(clk);

        -- test 1: Send ASCII 'A' (0x41)
        rx_data <= "01000001"; -- ASCII 'A' = 0x41
        rx_valid <= '1';    
        wait until rising_edge(clk);
        rx_valid <= '0';
        wait until rising_edge(clk);

        wait until led_pulse = '1';
        wait for 200 us;
        -- Test 2: Send ASCII '1' (0x31)
        rx_data <= "00110001"; -- ASCII '1' = 0x31
        rx_valid <= '1';
        wait until rising_edge(clk);
        rx_valid <= '0';
        wait until rising_edge(clk);

        wait until led_pulse = '1';
        report "Testbench ferdig" severity failure; -- avslutter simuleringen
        wait;
    end process p_main;
end architecture verifier;
        
    