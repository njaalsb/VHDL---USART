library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d5_safe is 
 port (
	-- Klokke og reset
	clk      : in std_logic;                     -- klokkesignal
	rst_n    : in std_logic;                     -- Reset-signal (aktivt lavt)
    incr_key : in std_logic;                     -- Trykknapp for å øke verdi (KEY1), aktivt lavt
	sw0      : in std_logic;                     -- Bryter for å åpne/lukke safen, 
	seg_sel  : in std_logic_vector(1 downto 0);  -- Brytere for å velge hvilket siffer som skal økes (SW1 og SW2)
	sw9      : in std_logic;                     -- Bryter for å vise hemmelig kode, 1 = vis kode, 0 = vis tall
	
	-- Utganger
	open_led : out std_logic;                    --  Kontroll av lysdiode LEDR0, ‘1’ = LED på, etter reset: ‘1’
	hex0     : out std_logic_vector(7 downto 0); --  Signaler til siffer 1 på 7-segment display, etter reset: 0
	hex1     : out std_logic_vector(7 downto 0); --  Signaler til siffer 2 på 7-segment display, etter reset: 0
	hex2     : out std_logic_vector(7 downto 0); --  Signaler til siffer 3 på 7-segment display, etter reset: 0
	hex3     : out std_logic_vector(7 downto 0)  --  Signaler til siffer 4 på 7-segment display, etter reset: 0

       );
end entity d5_safe;

-- =========================================================== --
------------------------ Arkitektur -----------------------------
-- =========================================================== --

architecture rtl of d5_safe is

 -- Oversetter et 4-bits tall (0–9) til riktig bitmønster
 function sevenseg_encode(d : unsigned(3 downto 0))
 return std_logic_vector is
 variable y : std_logic_vector(7 downto 0);

 begin 
   case d is
	when "0000" => y := "11000000"; -- 0
	when "0001" => y := "11111001"; -- 1
	when "0010" => y := "10100100"; -- 2
	when "0011" => y := "10110000"; -- 3
	when "0100" => y := "10011001"; -- 4
	when "0101" => y := "10010010"; -- 5
	when "0110" => y := "10000010"; -- 6
	when "0111" => y := "11111000"; -- 7
	when "1000" => y := "10000000"; -- 8
	when "1001" => y := "10010000"; -- 9
	when others => y := (others => '1');
   end case;
   return y;
  end function;


-- =========================================================== --
--------------------- Signaler og konstanter --------------------
-- =========================================================== --

-- Fire sifre som 0..9 (Brukerens kode)
signal d0, d1, d2, d3 : unsigned(3 downto 0) := (others => '0');

-- Hemmelig kode (4321)
constant SC3 : unsigned(3 downto 0) := to_unsigned(4, 4);
constant SC2 : unsigned(3 downto 0) := to_unsigned(3, 4);
constant SC1 : unsigned(3 downto 0) := to_unsigned(2, 4);
constant SC0 : unsigned(3 downto 0) := to_unsigned(1, 4);
	
-- Synkronisering/edge-deteksjon av KEY1 (aktiv lav)
signal key_ff1, key_ff2 : std_logic := '1';

-- Registrert LED (apen/låst)
signal LEDR0 : std_logic := '1';

-- Praktisk match-signal
signal code_match : std_logic;

begin

-- =========================================================== --
--------------------- Synkron logikk ----------------------------
-- =========================================================== --

   -- Reset + hold sifre
   process(clk)
   begin
	if rising_edge(clk) then
	   if rst_n = '0' then
	     -- RESET: start på 0000
		d0 <= (others => '0');
		d1 <= (others => '0');
		d2 <= (others => '0');
		d3 <= (others => '0');
		key_ff1 <= '1';
		key_ff2 <= '1';
		LEDR0 <= '1';
		
	   else
		-- 2-trinns synk av aktiv lav knapp
		key_ff1 <= incr_key;
		key_ff2 <= key_ff1;

	-- Fallende flanke
if (key_ff2 = '1' and key_ff1 = '0') then
    case seg_sel is
   	when "00" =>  -- HEX0
     		 if d0 = to_unsigned(9,4) then d0 <= (others => '0'); else d0 <= d0 + 1; end if;
   	when "01" =>  -- HEX1
      		if d1 = to_unsigned(9,4) then d1 <= (others => '0'); else d1 <= d1 + 1; end if;
   	when "10" =>  -- HEX2
      		if d2 = to_unsigned(9,4) then d2 <= (others => '0'); else d2 <= d2 + 1; end if;
    	when "11" =>  -- HEX3
     		if d3 = to_unsigned(9,4) then d3 <= (others => '0'); else d3 <= d3 + 1; end if;
    	when others =>
      		null; -- gjør ingenting for “rare” std_logic-verdier
   end case;
end if;

		-- Åpen/låst
		if sw0 = '1' then            -- Alltid låst når bryter er oppe
		     LEDR0 <= '0';
		  if code_match = '1' then
		     LEDR0 <= '1';           -- Åpen hvis kode er riktig 
		  else
		     LEDR0 <= '0';           -- Ellers forblir låst
		  end if;
		end if;

	     end if;
         end if;
   end process;


-- =========================================================== --
---------------- Hemmelig kode eller brukerens tall -------------
-- =========================================================== --

-- Sammenlign brukerens kode med 4321
code_match <= '1' when (d3 = SC3 and d2 = SC2 and d1 = SC1 and d0 = SC0) else '0';

-- Vis hemmelig kode eller brukerens tall
hex3 <= sevenseg_encode(SC3) when sw9 = '1' else sevenseg_encode(d3);
hex2 <= sevenseg_encode(SC2) when sw9 = '1' else sevenseg_encode(d2);
hex1 <= sevenseg_encode(SC1) when sw9 = '1' else sevenseg_encode(d1);
hex0 <= sevenseg_encode(SC0) when sw9 = '1' else sevenseg_encode(d0);

-- Koble registrert LED til port
open_led <= LEDR0;

end architecture rtl;