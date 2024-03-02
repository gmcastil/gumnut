library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std;

entity inst_mem is
    generic (
        filename    :   string := "program.dat"
    );
    port (
        clk         : in    std_logic;

        cyc         : in    std_logic;
        stb         : in    std_logic;
        ack         : out   std_logic;
        addr        : in    std_logic_vector(11 downto 0);
        rd_data     : out   std_logic_vector(17 downto 0)
    );
end entity inst_mem;

