-- Ctrl for UART kommunikasjon
-- Mottar data via UART, viser mottatt ASCII-kode på 7-segment display
-- Sender også et forhåndsdefinert tegn ved mottak eller knappetrykk



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart_ctrl is
    port (
        clk       : in std_logic;                            -- Klokke
        rstn      : in std_logic;                            -- Aktiv lav reset
        rx_data   : in std_logic_vector(7 downto 0);         -- Mottatt data
        rx_valid  : in std_logic;                            -- Indikator for gyldig mottatt data
        tx_busy   : in std_logic;                            -- Indikator for at sender er opptatt
        btn_char : in std_logic;                              -- Knapp for å sende forhåndsdefinert tegn
        btn_string : in std_logic;                              -- Knapp for å sendte en forhåndsdefinert streng 
        sevenseg_high  : out std_logic_vector(7 downto 0);         -- Øvre 7-segment
        sevenseg_low  : out std_logic_vector(7 downto 0);         -- nedre 7-segment
        led_pulse : out std_logic;                         -- Led på kortet (kort blink ved mottak)
        tx_data   : out std_logic_vector(7 downto 0);        -- Sendt data
        tx_start  : out std_logic                           -- Start sending av data
    );
end entity uart_ctrl;

--=============================================================================
----------------------- Arkitektur ----------------------------------------------
--=============================================================================     


architecture rtl of uart_ctrl is

    
    type state_type is (IDLE, BUSY);                                             -- Tilstander, vent og opptatt
    signal state: state_type;                                    -- Nåværende tilstand

   
    constant CHAR_TO_TX : std_logic_vector(7 downto 0) := x"55";  -- ASCII for 'U'

    signal led_cnt: integer range 0 to 2_000_000 := 0;                        -- Teller for LED puls varighet
    signal received_ascii: std_logic_vector(7 downto 0) := (others => '0');     -- Lagrer siste mottatte ASCII verdi
    
    
    signal btn_char_last: std_logic := '0';                                        -- Lagrer forrige knappestatus
    signal btn_string_last : std_logic := '0';

    type string_array is array (0 to 7) of std_logic_vector(7 downto 0);
    constant STRING_TO_TX   : string_array := (
        0 => x"48", -- 'H'
        1 => x"45", -- 'E
        2 => x"4C", --  L
        3 => x"4F", --  L
        4 => x"31", --  O
        5 => x"32", --  1
        6 => x"31", --  2
        7 => x"33"  --  3

    );

    -- indeks og flagg for streng-sending
    signal string_idx  : integer range 0 to 7 := 0;
    signal sending_string : std_logic := '0';

     -- Funksjon som oversetter 4-bits heksadesimalt tall til 7-segmentmønster
    function hex_to_sevenseg(d : unsigned(3 downto 0)) return std_logic_vector is
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
        when "1010" => y := "10001000"; -- A
        when "1011" => y := "10000011"; -- b
        when "1100" => y := "11000110"; -- C
        when "1101" => y := "10100001"; -- d
        when "1110" => y := "10000110"; -- E
        when "1111" => y := "10001110"; -- F
        when others => y := (others => '1'); -- slukket
    end case;
    return y;
  end function;

begin
-- Hovedprosess som styrer visning og LED blink
 process(clk, rstn)
    begin   
    if rstn = '0' then -- reset, nullstiller alt
        state <= IDLE;
        led_pulse <= '0';
        led_cnt <= 0;

        btn_char_last <= '0';
        btn_string_last <= '0';
        
        sending_string <= '0';
        string_idx <= 0;

        received_ascii <= (others => '0');
        sevenseg_high <= (others => '1'); --slukker display
        sevenseg_low <= (others => '1');

        tx_start <= '0';
        tx_data <= (others => '0');

    elsif rising_edge(clk) then
        tx_start <= '0';
        case state is
            when IDLE =>
                if (rx_valid = '1' and tx_busy = '0') then
                    received_ascii <= rx_data; --lagrer mottatt data (buffer)
                    led_cnt <= 2_000_000;  -- Justerer etter klokkehastighet for ønsket LED puls lengde (20 ms)
                    tx_data <= rx_data;   -- Loopback hvis TX er ledig
                    tx_start <= '1';     -- Opptatt
                    sending_string <= '0';
                    state <= BUSY;

                -- Enkelttegn: knapp med rising edge    
                elsif (btn_char = '1' and btn_char_last = '0') and (tx_busy = '0') then
                    -- knappetrykk oppdaget, send forhåndsdefinert tegn hvis sender ikke er opptatt
                    received_ascii <= CHAR_TO_TX;
                    led_cnt <= 2_000_000;
                    tx_data <= CHAR_TO_TX;
                    tx_start <= '1';
                    sending_string <= '0';
                    state <= BUSY;

                -- Streng: knapp med rising edge
                elsif (btn_string = '1' and btn_string_last = '0') and (tx_busy = '0') then
                    sending_string <= '1';
                    string_idx <= 0;
                    tx_data <= STRING_TO_TX(0);
                    tx_start <= '1';
                    state <= BUSY;
               end if;       
               
            when BUSY => 
                if tx_busy = '0' then

                    if sending_string = '0' then    -- Det var bare ett tegn
                       state <= IDLE;
                       
                    else
                        -- vi er i streng modus
                        if string_idx = 7 then
                        -- siste tegn i STRING_TO_TX er sendt
                            sending_string <= '0';
                            state <= IDLE;
                        else
                        -- Send neste tegn i strengen
                            string_idx <= string_idx + 1;
                            led_cnt <= 2_000_000;
                            tx_data <= STRING_TO_TX(string_idx + 1); 
                            tx_start <= '1';
                        end if;

                    end if;

                end if;


            when others =>
                state <= IDLE;
        end case;

                if led_cnt > 0 then
                    led_cnt <= led_cnt - 1; -- teller ned LED pulsen
                    led_pulse <= '1';
                else
                    led_pulse <= '0';       -- led av når nedtelling er ferdig
                end if;
                -- Viser ASCII-koden (hex): øvre og nedre del
                sevenseg_high <= hex_to_sevenseg(unsigned(received_ascii(7 downto 4)));
                sevenseg_low  <= hex_to_sevenseg(unsigned(received_ascii(3 downto 0)));
                btn_char_last <= btn_char;
                btn_string_last <= btn_string;
            end if;
    end process;
end architecture rtl;



