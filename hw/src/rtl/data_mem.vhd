library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std;

entity data_mem is
    generic (
        filename    :   string := "program.dat"
    );
    port (
        clk         : in    std_logic;

        cyc         : in    std_logic;
        stb         : in    std_logic;
        we          : in    std_logic;
        ack         : out   std_logic;
        addr        : in    std_logic_vector(7 downto 0);
        wr_data     : in    std_logic_vector(7 downto 0);
        rd_data     : out   std_logic_vector(7 downto 0)
    );
end entity data_mem;

