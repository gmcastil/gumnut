library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gumnut is
    generic (
        debug           : boolean   := false
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

        -- Instruction interface
        inst_cyc        : out   std_logic;
        inst_stb        : out   std_logic;
        inst_ack        : in    std_logic;
        inst_addr       : out   std_logic_vector(11 downto 0);
        inst_rd_data    : in    std_logic_vector(17 downto 0);

        -- Memory interface
        mem_cyc         : out   std_logic;
        mem_stb         : out   std_logic;
        mem_we          : out   std_logic;
        mem_ack         : in    std_logic;
        mem_addr        : out   std_logic_vector(7 downto 0);
        mem_wr_data     : out   std_logic_vector(7 downto 0);
        mem_rd_data     : in    std_logic_vector(7 downto 0);

        -- I/O port interface
        port_cyc        : out   std_logic;
        port_stb        : out   std_logic;
        port_we         : out   std_logic;
        port_ack        : in    std_logic;
        port_addr       : out   std_logic_vector(7 downto 0);
        port_wr_data    : out   std_logic_vector(7 downto 0);
        port_rd_data    : in    std_logic_vector(7 downto 0);

        -- Interrupts
        int_irq         : in    std_logic;
        int_ack         : out   std_logic
    );
end entity gumnut;

