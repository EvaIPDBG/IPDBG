library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ecp5;
use ecp5.components.all;

entity dffpc is
    port(
        clk : in  std_logic;
        ce  : in  std_logic;
        d   : in  std_logic;
        q   : out std_logic
    );
end entity dffpc;

architecture lfe5 of dffpc is
begin
    FF : FD1P3AX
        port map
        (
            Q  => q,
            CK => clk,
            SP => ce,
            D  => d
        );
end architecture lfe5;
