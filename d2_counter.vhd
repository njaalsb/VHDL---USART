library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d2_counter is
   generic (
     F_CNT : integer := 50_000_000/10;    -- Clock frequency
     NUM_BITS : integer := 10);           -- Number of bits in output
   port (
      clk, rst, ena, cnt_sel: in  std_logic;
      count: out std_logic_vector(NUM_BITS-1 downto 0)
   );
end entity d2_counter;

architecture RTL of d2_counter is
   signal count0   : natural range 0 to F_CNT-1;
   signal count1   : natural range 0 to 1023;
   signal lfsr     : std_logic_vector(NUM_BITS-1 downto 0);
	
begin
   p0: count <= std_logic_vector(to_unsigned(count1,NUM_BITS)) when 
                                              cnt_sel = '0' else lfsr;

   p1: process(clk,rst) is
      variable feedback : std_logic;		
   begin
      if rst = '0' then
         count0   <= 0;
         count1   <= 0;
         lfsr     <= (0 => '1', others => '0');
         feedback := '0';
	
      elsif rising_edge(clk) then
         if ena = '1' then
            if count0 /= F_CNT - 1 then
               count0 <= count0 + 1;
            else
               -- 0,1 s tick
               count0 <= 0;
               if cnt_sel = '0' then
                  -- Binary counting
                  if count1 /= 2**NUM_BITS - 1 then
                     count1 <= count1 + 1;
                  else
                     count1 <= 0;
                  end if;
               else
                  -- LFSR
                  feedback := lfsr(3) xor lfsr(0);
                  lfsr <= feedback & lfsr(NUM_BITS-1 downto 1);
               end if;
            end if;
         end if;
      end if;		
   end process;

end architecture RTL;
