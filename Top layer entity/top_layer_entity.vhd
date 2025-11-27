library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- instansierer top layer entitet
entity top_layer_entity is 
    -- Alle portene korresponderer til fysiske pinner på FPGA'en
    port (
        clk : in std_logic;
        rx  : in std_logic;
        sev_seg_1 : std_logic_vector
        tx  : out std_logic
    );
end entity top_layer_entity;