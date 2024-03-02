library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gumnut_top is
    generic (
        inst_filename   : string    := "gumnut_inst.dat";
        mem_filename    : string    := "gumnut_mem.dat";
        debug           : boolean   := false
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

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
end entity gumnut_top;

architecture struct of gumnut_top is

    -- Instruction bus
    signal  inst_cyc            : std_logic;
    signal  inst_stb            : std_logic;
    signal  inst_ack            : std_logic;
    signal  inst_addr           : std_logic_vector(11 downto 0);
    signal  inst_rd_data        : std_logic_vector(17 downto 0);

    -- Memory bus
    signal  mem_cyc             : std_logic;
    signal  mem_stb             : std_logic;
    signal  mem_we              : std_logic;
    signal  mem_ack             : std_logic;
    signal  mem_addr            : std_logic_vector(7 downto 0);
    signal  mem_wr_data         : std_logic_vector(7 downto 0);
    signal  mem_rd_data         : std_logic_vector(7 downto 0);

begin

    core: entity work.gumnut
    generic map (
        debug           => debug
    )
    port map (
		clk			        => clk,
		rst			        => rst,

		inst_cyc			=> inst_cyc,
		inst_stb			=> inst_stb,
		inst_ack			=> inst_ack,
		inst_addr			=> inst_addr,
		inst_rd_data		=> inst_rd_data,

		mem_cyc			    => mem_cyc,
		mem_stb			    => mem_stb,
		mem_we			    => mem_we,
		mem_ack			    => mem_ack,
		mem_addr			=> mem_addr,
		mem_wr_data			=> mem_wr_data,
		mem_rd_data			=> mem_rd_data,

		port_cyc			=> port_cyc,
		port_stb			=> port_stb,
		port_we			    => port_we,
		port_ack			=> port_ack,
		port_addr			=> port_addr,
		port_wr_data		=> port_wr_data,
		port_rd_data		=> port_rd_data,

		int_irq			    => int_irq,
		int_ack			    => int_ack
    );

    core_inst_mem: entity work.inst_mem
    generic map (
        filename            => inst_filename
    )
    port map (
        clk                 => clk,
        cyc                 => inst_cyc,
        stb                 => inst_stb,
        ack                 => inst_ack,
        addr                => inst_addr,
        rd_data             => inst_rd_data
    );

    core_data_mem: entity work.data_mem
    generic map (
        filename            => mem_filename
    )
    port map (
        clk                 => clk,
        cyc                 => mem_cyc,
        stb                 => mem_stb,
        we                  => mem_we,
        ack                 => mem_ack,
        addr                => mem_addr,
        wr_data             => mem_wr_data,
        rd_data             => mem_rd_data
    );

end architecture struct;

