---------------------------------------------------------------------------------
-- Testbench of safe
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Entity of testbench (empty)
entity d5_safe_tb is
end d5_safe_tb;


architecture SimulationModel of d5_safe_tb is

  -----------------------------------------------------------------------------
  -- Constant declaration
  -----------------------------------------------------------------------------
  constant CLK_PER : time := 20 ns;    -- 50 MHz

  -- Coding of 7-segments
  constant SEG7_0 : std_logic_vector(7 downto 0) := "11000000";
  constant SEG7_1 : std_logic_vector(7 downto 0) := "11111001";
  constant SEG7_2 : std_logic_vector(7 downto 0) := "10100100";
  constant SEG7_3 : std_logic_vector(7 downto 0) := "10110000";
  constant SEG7_4 : std_logic_vector(7 downto 0) := "10011001";
  constant SEG7_5 : std_logic_vector(7 downto 0) := "10010010";
  constant SEG7_6 : std_logic_vector(7 downto 0) := "10000010";
  constant SEG7_7 : std_logic_vector(7 downto 0) := "11111000";
  constant SEG7_8 : std_logic_vector(7 downto 0) := "10000000";
  constant SEG7_9 : std_logic_vector(7 downto 0) := "10010000";

  -- Secret code (MUST be the same as in VHDL-code)
  constant CODE0 : integer := 1;
  constant CODE1 : integer := 2;
  constant CODE2 : integer := 3;
  constant CODE3 : integer := 4;


  -----------------------------------------------------------------------------
  -- Component declarasion
  -----------------------------------------------------------------------------
  component d5_safe
    port (
      clk      : in  std_logic;
      rst_n    : in  std_logic;            -- Key0
      incr_key : in  std_logic;            -- Key1
      sw0      : in  std_logic;            -- Open/close safe, SW0
      seg_sel  : in  std_logic_vector(1 downto 0);  -- Select 7-segment, SW1-SW2
      sw9      : in  std_logic;            -- Show secret key, SW9
      open_led : out std_logic;            -- LEDR0
      hex0     : out std_logic_vector(7 downto 0);  -- HEX0 7-segment
      hex1     : out std_logic_vector(7 downto 0);  -- HEX1 7-segment
      hex2     : out std_logic_vector(7 downto 0);  -- HEX2 7-segment
      hex3     : out std_logic_vector(7 downto 0)   -- HEX3 7-segment
      );
  end component d5_safe;

  -----------------------------------------------------------------------------
  -- Signal declaration
  -----------------------------------------------------------------------------
  -- DUT signals
  signal clk      : std_logic;
  signal rst_n    : std_logic;
  signal incr_key : std_logic;
  signal sw0      : std_logic;
  signal seg_sel  : std_logic_vector(1 downto 0);
  signal sw9      : std_logic;
  signal open_led : std_logic;
  signal hex0     : std_logic_vector(7 downto 0);
  signal hex1     : std_logic_vector(7 downto 0);
  signal hex2     : std_logic_vector(7 downto 0);
  signal hex3     : std_logic_vector(7 downto 0);

  -- Testbench signals
  

begin

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  i_d5_safe: component d5_safe
    port map (
      clk      => clk,
      rst_n    => rst_n,
      incr_key => incr_key,
      sw0      => sw0,
      seg_sel  => seg_sel,
      sw9      => sw9,
      open_led => open_led,
      hex0     => hex0,
      hex1     => hex1,
      hex2     => hex2,
      hex3     => hex3
      );


  -----------------------------------------------------------------------------
  -- purpose: Generation of clock
  -- type   : sequential
  -- inputs : none
  -- outputs: clk
  -----------------------------------------------------------------------------
  p_clk: process is
  begin          -- Process p_clk
    clk <= '0';
    wait for CLK_PER/2;
    clk <= '1';
    wait for CLK_PER/2;
  end process p_clk;


  -----------------------------------------------------------------------------
  -- purpose: Generation of resetN (active low)
  -- type   : sequential
  -- inputs : none
  -- outputs: resetN
  -----------------------------------------------------------------------------
  p_rst_n: process is
  begin           -- Process p_rst_n
    rst_n <= '0';
    wait for 2.2*CLK_PER;
    rst_n <= '1';
    wait;
  end process p_rst_n;


  -----------------------------------------------------------------------------
  -- purpose: Main process
  -- type   : sequential
  -- inputs : 
  -----------------------------------------------------------------------------
  p_main: process

    -- purpose: Initialisation of testbench
    procedure tb_init is
    begin
      incr_key <= '1';
      sw0      <= '0';
      seg_sel  <= (others => '0');
      sw9      <= '0';
      wait until rst_n = '1';
      wait for 100 ns;
      wait until rising_edge(clk);
      wait for 1 ns;
    end tb_init;


    -- purpose: Increment 7-segment
    procedure inc_seg is
    begin
      incr_key <= '0';
      wait for CLK_PER;
      incr_key <= '1';
      wait for 4*CLK_PER;
    end inc_seg;


    -- Purpose: Check 7-segment, first number only
    procedure chk_7seg is
    begin
      seg_sel  <= "00";
      assert hex0 = SEG7_0 report "Wrong setting of 7-segment (0)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_1 report "Wrong setting of 7-segment (1)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_2 report "Wrong setting of 7-segment (2)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_3 report "Wrong setting of 7-segment (3)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_4 report "Wrong setting of 7-segment (4)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_5 report "Wrong setting of 7-segment (5)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_6 report "Wrong setting of 7-segment (6)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_7 report "Wrong setting of 7-segment (7)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_8 report "Wrong setting of 7-segment (8)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_9 report "Wrong setting of 7-segment (9)!!!" severity error;
      inc_seg;
      assert hex0 = SEG7_0 report "Wrong setting of 7-segment (0)!!!" severity error;
    end chk_7seg;


    -- Purpose: Check that the secret code is showing with SW17 (code must be 4321)
    procedure chk_sw9 is
    begin
      sw9 <= '1';
      wait for 4*CLK_PER;
      assert hex0 = SEG7_1 report "Wrong setting of 7-segment of CODE0 (1)!!!" severity error;
      assert hex1 = SEG7_2 report "Wrong setting of 7-segment of CODE1 (2)!!!" severity error;
      assert hex2 = SEG7_3 report "Wrong setting of 7-segment of CODE2 (3)!!!" severity error;
      assert hex3 = SEG7_4 report "Wrong setting of 7-segment of CODE3 (4)!!!" severity error;
      sw9 <= '0';
      wait for 4*CLK_PER;
    end chk_sw9;


    -- Purpose: Check safe functionallity (LEDs, keys, switches)
    procedure chk_safe is
    begin
      -- Check correct setting of LEDs at start
      assert open_led = '1' report "Safe not open after reset (LEDR0 not on)!!!" severity error;

      -- Check correct setting of LEDs after pressing lock-key
      sw0 <= '1';
      wait for CLK_PER;
      assert open_led = '0' report "Safe not locked after lock (LEDR0 not off)!!!" severity error;

      -- Check correct setting of LEDs after pressing open-key
      -- (no change, code wrong)
      sw0 <= '0';
      wait for CLK_PER;
      assert open_led = '0' report "Safe not locked after open with code wrong (LEDR0 not off)!!!" severity error;

      -- Change to secret code
      seg_sel <= "00";
      for i in 1 to CODE0 loop
        inc_seg;
      end loop;
      seg_sel <= "01";
      for i in 1 to CODE1 loop
          inc_seg;
      end loop;
      seg_sel <= "10";
      for i in 1 to CODE2 loop
        inc_seg;
      end loop;
      seg_sel <= "11";
      for i in 1 to CODE3 loop
        inc_seg;
      end loop;
      
      -- Check correct setting of LEDs with correct code (SW = '0')
      assert open_led = '1' report "Safe not open after open with correct code (LEDR0 not on)!!!" severity error;
      seg_sel <= "00";
    end chk_safe;



  begin  -- process p_main
    tb_init;

    chk_7seg;
    chk_sw9;
    chk_safe;

    wait for 100 ns;
    assert false report "Testbench finished" severity failure;

  end process p_main;

end architecture SimulationModel;

