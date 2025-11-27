library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- instansierer top layer entitet
entity top_layer_entity is 
    -- Alle portene korresponderer til fysiske pinner på FPGA'en
    port (
        -- Felles
        clk         : in std_logic;
        rst         : in std_logic;
        ena         : in std_logic;

        -- RX
        rx          : in std_logic;

        -- CTRL
        sev_seg_high: out std_logic_vector(7 downto 0);
        sev_seg_low : out std_logic_vector(7 downto 0);
        btn_pin    : in std_logic;
        led_pin   : out std_logic;

        -- TX
        tx  : out std_logic
    );
end entity top_layer_entity;

architecture RTL of top_layer_entity is
    -- signal, disse skal koble alle komponentene sammen 
    -- VIKTIG med deskriptive navn og kommentarer(!) 
    signal baud         : std_logic;
    signal rx_flag      : std_logic;
    signal rx_to_ctrl   : std_logic_vector(7 downto 0);
    signal tx_flag      : std_logic; -- flag fra tx om at den er ferdig å sende
    signal ctrl_to_tx   : std_logic_vector(7 downto 0); -- output byte
    signal ctrl_flag    : std_logic;
    -- Component deklarasjoner
    -- Sampler:
    component sampler is
        generic (
            F_CLK : natural := 50_000_000
        );
        port (
            clk, ena, rst   : in std_logic;
            rx_in           : in std_logic;
            baud_clk        : in std_logic;
            rx_ready        : out std_logic; 
            rx_out          : out std_logic_vector(7 downto 0) 
        );
    end component sampler;

    -- Baud gen:
    component baud_gen 
        port (
            ena : in std_logic;
            clk : in std_logic;
            rst : in std_logic;
            baud_clk : out std_logic 
        );
    end component baud_gen;
        
    -- UART CTRL:
    component uart_ctrl is
        port (
            clk, rstn, rx_valid, tx_busy, btn_char  : in std_logic;                            
            rx_data                                 : in std_logic_vector(7 downto 0);        
            sevenseg_high, sevenseg_low, tx_data    : out std_logic_vector(7 downto 0);       
            led_pulse, tx_start                     : out std_logic                           
        );
    end component uart_ctrl;

    -- Transmitter: 
    component transmitter is
        generic (
            tick_time :   natural := 15 --16 baud ticks 
        );
        port (
            baud_clk    : in std_logic;
            tx_ready    : in std_logic;
            tx_reg      : in std_logic_vector(7 downto 0);
            tx_out      : out std_logic := '0';
            tx_fin      : out std_logic := '1'
        );
    end component transmitter;

    begin
        
        -- instansiering
        -- syntax: komponent_signalnavn => lokalt_signalnavn
        i_baud_gen : component baud_gen
            port map (
                clk     => clk, --Global systemklokke
                ena     => ena, --Global enable
                rst     => rst, --Global reset
                baud_clk=> baud --kobler baud_clk output til baud signal
            );

        i_sampler : component sampler
            port map (
                baud_clk => baud,   --baud fra baud_gen 
                rx_in => rx,        -- sampler inngang til rx_pin
                clk => clk,
                ena => ena,
                rst => rst,
                rx_ready => rx_flag, -- flag til ctrl
                rx_out => rx_to_ctrl -- motatt byte til ctrl 
                -- MÅ fjerne sb_flag fra sampler
            );

        -- transmitter instans, burde kanskje ena og rst?
        i_transmitter : component transmitter
            port map (
                baud_clk => baud,
                tx_ready => ctrl_flag,  -- ctrl tells tx to start
                tx_reg => ctrl_to_tx,
                tx_out => tx,
                tx_fin => tx_flag       -- tx tells ctrl it's done
            );

        i_uart_ctrl : component uart_ctrl
            port map(
                clk => clk,
                rstn => not rst,        -- Invert: uart_ctrl uses active-low reset
                rx_data => rx_to_ctrl,
                rx_valid => rx_flag,
                tx_busy => tx_flag,
                btn_char => btn_pin,
                sevenseg_high => sev_seg_high,
                sevenseg_low => sev_seg_low,
                led_pulse => led_pin,
                tx_data => ctrl_to_tx,
                tx_start => ctrl_flag
            );            
end architecture RTL;