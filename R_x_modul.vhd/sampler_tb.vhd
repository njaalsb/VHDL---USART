-- Sampler testbenk 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sampler_tb is
    generic (
        constant test_byte : std_logic_vector(9 downto 0) := "1" & "01011101" & "0";  -- stop, data (LSB first), start
        bit_time  : time := 65.2 ns
    );
end entity sampler_tb;

architecture RTL of sampler_tb is

    component sampler is
        generic(
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
    end component sampler;
      
    -- Doot signals
    signal clk      : std_logic;
    signal rx_in    : std_logic := '1';
    signal ena      : std_logic;
    signal rst      : std_logic;
    signal baud_clk : std_logic;
    signal sb_flag  : std_logic := '0';
    signal rx_ready : std_logic := '0';
    signal rx_out   : std_logic_vector(7 downto 0) := "00000000";

    -- Signal for testbenk
    signal tb_count : natural range 0 to 16;
    signal bit_count: natural range 0 to 10;

begin 
    i_sampler : component sampler 
        port map (
            clk => clk,
            rx_in => rx_in,
            ena => ena,
            rst => rst,
            baud_clk => baud_clk,
            sb_flag => sb_flag,
            rx_ready => rx_ready,
            rx_out => rx_out
        );

    -- Klokkeprosess
    p_clk : process
    begin
        clk <= '1';
        wait for 10 ps;
        clk <= '0';
        wait for 10 ps;
    end process p_clk;
           
    -- Reset prosess, usikker på om denne er nødvendig, men lagt til PGA baud_gen modul
    p_rst : process 
    begin
        rst <= '1';
        wait for 5 ns;
        rst <= '0';
        wait;
    end process p_rst;  
        
p_rx : process
begin
    rx_in <= '1'; wait for 100 ns;

    -- start bit
    rx_in <= '0'; wait for bit_time;

    -- data bits, LSB first
    for i in 0 to 7 loop
        rx_in <= test_byte(i);
        wait for bit_time;
    end loop;

    -- stop bit
    rx_in <= '1'; wait for bit_time;

    wait;
end process;



end architecture RTL;