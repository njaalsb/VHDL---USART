library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity uart_ctrl_tb is
end uart_ctrl_tb;   

architecture verifier of uart_ctrl_tb is
    constant clk_per : time := 20 ns;  -- 50 MHz klokke (matches debounce logic)

    component uart_ctrl 
        port (
            mode      : in std_logic;   -- Mode switch
            clk  : in std_logic;                               -- Klokke
            rstn    : in std_logic;                            -- Aktiv lav reset
            rx_data   : in std_logic_vector(7 downto 0);        -- Mottatt data
            rx_valid  : in std_logic;                            -- Indikator for gyldig mottatt data
            tx_busy : in std_logic;
            btn_char : in std_logic;
            btn_string : in std_logic;

            sevenseg_high  : out std_logic_vector(7 downto 0);         -- Øvre 7-segment
            sevenseg_low  : out std_logic_vector(7 downto 0);         -- nedre 7-segment
            led_pulse : out std_logic;                             -- Led på kortet (kort blink ved mottak)
            tx_data : out std_logic_vector(7 downto 0);
            tx_start : out std_logic
        );
    end component uart_ctrl;

    -- DUT signaler
    signal mode       : std_logic := '0';  -- Start in loopback mode
    signal clk     : std_logic := '0';
    signal rstn      : std_logic := '0';
    signal rx_data   : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_valid : std_logic := '0';
    signal tx_busy : std_logic := '0';
    signal btn_char : std_logic := '1';  -- Active-low: '1' = not pressed
    signal btn_string : std_logic := '1';  -- Active-low: '1' = not pressed

    signal sevenseg_high  : std_logic_vector(7 downto 0);
    signal sevenseg_low   : std_logic_vector(7 downto 0);
    signal led_pulse    : std_logic;
    signal tx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_start : std_logic := '0';

begin
    -- Mapper DUT signaler til DUV
    i_uart_ctrl: component uart_ctrl
        port map (
            mode      => mode,
            clk      => clk,
            rstn      => rstn,
            rx_data   => rx_data,
            rx_valid  => rx_valid,
            tx_busy => tx_busy,
            btn_char => btn_char,
            btn_string => btn_string,
            sevenseg_high  => sevenseg_high,
            sevenseg_low   => sevenseg_low,
            led_pulse => led_pulse,
            tx_data => tx_data,
            tx_start => tx_start
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
        wait for 100 ns;

        -- Test 1: Send ASCII 'A' (0x41) in loopback mode
        rx_data <= "01000001"; -- ASCII 'A' = 0x41
        rx_valid <= '1'; 
        wait until rising_edge(clk);
        rx_valid <= '0';
        wait until tx_start = '1';
        tx_busy <= '1';
        wait for 10 * clk_per;
        tx_busy <= '0';
        wait for 5 * clk_per;

        -- Test 2: Send ASCII '1' (0x31) in loopback mode
        rx_data <= "00110001"; -- ASCII '1' = 0x31
        rx_valid <= '1';
        wait until rising_edge(clk);
        rx_valid <= '0';
        wait until tx_start = '1';
        tx_busy <= '1';
        wait for 10 * clk_per;
        tx_busy <= '0';
        wait for 5 * clk_per;

        -- Switch to button mode
        mode <= '1';
        wait for 10 * clk_per;

        -- Test 3: knapp og enkelttegn (active-low button press)
        btn_char <= '0';  -- Press button (active low)
        wait for 60000 * clk_per;  -- Hold long enough for debounce (>1ms)
        btn_char <= '1';  -- Release button
        wait until tx_start = '1';
        tx_busy <= '1';
        wait for 10 * clk_per;
        tx_busy <= '0'; 
        wait for 10 * clk_per;

        -- TEST 4: streng med btn_string (active-low button press)
        btn_string <= '0';  -- Press button (active low)
        wait for 60000 * clk_per;  -- Hold long enough for debounce (>1ms)
        btn_string <= '1';  -- Release button

        -- Nå forventer vi 8 påfølgende tx_start-pulser (1 per tegn)
        for i in 0 to 7 loop 
            -- vent til uart sender neste tegn
            wait until tx_start = '1';
            tx_busy <= '1';

            -- Simuler at uart bruker litt tid på å sende tegnet
            wait for 10 * clk_per;
            tx_busy <= '0';

            wait until rising_edge(clk);
        end loop;

        wait for 20 * clk_per;

        report "Testbenk ferdig" severity note; -- avslutter simuleringen
        wait;
    end process p_main;
end architecture verifier;
        
    