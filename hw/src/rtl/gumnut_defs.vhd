library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package gumnut_defs is

    constant IMEM_ADDR_WIDTH        : positive      := 12;
    constant IMEM_SIZE              : positive      := 2 ** IMEM_ADDR_WIDTH;

    subtype imem_addr_t is unsigned(IMEM_ADDR_WIDTH - 1 downto 0)

    subtype instr_t is unsigned(17 downto 0);
    type instr_a is array (natural range <>) of instr_t;
    -- I think the intent is to define a data structure that can be used to store the maximum number
    -- of addressable instructions
    subtype imem_a is instr_a(0 to IMEM_SIZE - 1);

    constant DMEM_ADDR_WIDTH        : positive      : 8;
    constant DMEM_SIZE              : positive      : 2 ** DMEM_ADDR_WIDTH;

    subtype uint8b_t is unsigned(7 downto 0);
    type uint8b_a is array (natural range <>) of uint8b_t;
    -- Here again, the intent is define a structure for storing the largest array of accessible
    -- data values (e.g., bytes).
    subtype dmem_a is uint8b_a(0 to DMEM_SIZE - 1);

    subtype int8b_t is signed(7 downto 0);
    type int8b_a is array (natural range <>) of int8b_t;

    subtype reg_addr_t is unsigned(2 downto 0);
    subtype immed_t is unsigned(7 downto 0);
    subtype offset_t is unsigned(7 downto 0);
    subtype disp_t is unsigned(7 downto 0);
    subtype shift_cnt_t is unsigned(2 downto 0);

    -- Describe the entire ISA as subtypes and then group subtypes and create mneumonics
    subtype alu_fn_code_t is unsigned(2 downto 0);
    subtype shift_fn_code_t is unsigned(1 downto 0);
    subtype mem_fn_code_t is unsigned(1 downto 0);
    subtype branch_fn_code_t is unsigned(1 downto 0);
    subtype jump_fn_code_t is unsigned(0 downto 0);
    subtype misc_fn_code_t is unsigned(2 downto 0);

    constant ALU_FN_ADD             : alu_fn_code_t     := "000";
    constant ALU_FN_ADDC            : alu_fn_code_t     := "001";
    constant ALU_FN_SUB             : alu_fn_code_t     := "010";
    constant ALU_FN_SUBC            : alu_fn_code_t     := "011";
    constant ALU_FN_AND             : alu_fn_code_t     := "100";
    constant ALU_FN_OR              : alu_fn_code_t     := "101";
    constant ALU_FN_XOR             : alu_fn_code_t     := "110";
    constant ALU_FN_MASK            : alu_fn_code_t     := "111";

    constant SHIFT_FN_SHL           : shift_fn_code_t   := "00";
    constant SHIFT_FN_SHR           : shift_fn_code_t   := "01";
    constant SHIFT_FN_ROL           : shift_fn_code_t   := "10";
    constant SHIFT_FN_ROR           : shift_fn_code_t   := "11";

    constant MEM_FN_LDM             : mem_fn_code_t     := "00";
    constant MEM_FN_STM             : mem_fn_code_t     := "01";
    constant MEM_FN_INP             : mem_fn_code_t     := "10";
    constant MEM_FN_OUT             : mem_fn_code_t     := "11";
    
    constant BRANCH_FN_BZ           : branch_fn_code_t  := "00";
    constant BRANCH_FN_BNZ          : branch_fn_code_t  := "01";
    constant BRANCH_FN_BC           : branch_fn_code_t  := "10";
    constant BRANCH_FN_BNC          : branch_fn_code_t  := "11";

    constant JUMP_FN_JMP            : jump_fn_code_t    := "0";
    constant JUMP_FN_JSB            : jump_fn_code_t    := "1";

    constant MISC_FN_RET            : misc_fn_code_t    := "000";
    constant MISC_FN_RETI           : misc_fn_code_t    := "001";
    constant MISC_FN_ENAI           : misc_fn_code_t    := "010";
    constant MISC_FN_DISI           : misc_fn_code_t    := "011";
    constant MISC_FN_WAIT           : misc_fn_code_t    := "100";
    constant MISC_FN_STBY           : misc_fn_code_t    := "101";
    constant MISC_FN_UNDEF_6        : misc_fn_code_t    := "110";
    constant MISC_FN_UNDEF_7        : misc_fn_code_t    := "111";

    -- Probably for a simulation?
    subtype disassembled_instr is string(1 to 30);
    procedure disassemble( instruction : instr_t; result : out disassembled_instr )

end package gumnut_defs;

package body gumnut_defs is

    procedure disassemble( instruction : instr_t; result : out disassembled_instr ) is

        subtype name_t is string(1 to 4);
        type name_a is array (natural range <>) of name_t;

        constant ALU_NAME_TABLE     : name_a(0 to 7)    :=
        (
            0 => "ADD",
            1 => "ADDC",
            2 => "SUB",
            3 => "SUBC",
            4 => "AND",
            5 => "OR",
            6 => "XOR",
            7 => "MASK"
        );

        constant SHIFT_NAME_TABLE   : name_a(0 to 3)    :=
        (
            0 => "SHL",
            1 => "SHR",
            2 => "ROL",
            3 => "ROR"
        );

        constant MEM_NAME_TABLE     : name_a(0 to 3)    :=
        (
            0 => "LDM",
            1 => "STM",
            2 => "INP",
            3 => "OUT"
        );
            
        constant BRANCH_NAME_TABLE  : name_a(0 to 3)    :=
        (
            0 => "BZ",
            1 => "BNC",
            2 => "BC",
            3 => "BNC"
        );

        constant JUMP_NAME_TABLE    : name_a(0 to 1)    :=
        (
            0 => "JMP",
            1 => "JSB"
        );

        constant MISC_NAME_TABLE    : name_a(0 to 7)    :=
        (
            0 => "RET",
            1 => "RETI",
            2 => "ENAI",
            3 => "DISI",
            4 => "WAIT",
            5 => "STBY",
            6 => "UM_6",
            7 => "UM_7"
        );

        -- Strip the strength from the instruction to make disassembling easier
        variable instr_01           : instr_t       := to_01(instruction);
        -- Alias the `fn` field from an instruction
        alias instr_alu_reg_fn      : alu_fn_code_t is instr_01(2 downto 0);
        alias instr_alu_immed_fn    : alu_fn_code_t is instr_01(16 downto 14);
        alias instr_shift_fn        : shift_fn_code_t is instr_01(1 downto 0);
        alias instr_mem_fn          : mem_fn_code_t is instr_01(15 downto 14);
        alias instr_branch_fn       : branch_fn_code_t is instr_01(11 downto 10);
        alias instr_jump_fn         : jump_fn_code_t is instr_01(12 downto 12);
        alias instr_misc_fn         : misc_fn_code_t is instr_01(10 downto 8);

        alias instr_rd              : reg_addr_t is instr_01(13 downto 11);
        alias instr_rs              : reg_addr_t is instr_01(10 downto 8);
        alias instr_r2              : reg_addr_t is instr_01(7 downto 5);
        alias instr_immed           : immed_t is instr_01(7 downto 0);
        alias instr_count           : shift_cnt_t is instr_01(7 downto 5);
        alias instr_offset          : offset_t is instr_01(7 downto 0);
        alias instr_disp            : disp_t is instr_01(7 downto 0);
        alias instr_addr            : imem_addr_t is instr_01(11 downto 0);

        -- Recall that for all of the sub-procedures described here, the result is being
        -- stored within a 30 character long result string that the main procedure uses as
        -- an output value
        
        -- Sub-procedure to disassemble a register number and store the result
        -- as a single character at a position
        procedure disassemble_reg( reg : reg_addr_t; index : positive ) is
            variable str            : string := to_string(to_integer(reg));
        begin
            result(index) := str(str'left);
        end procedure disassemble_reg;

        -- Sub-procedure to disassemble an unsigned value and store the result
        -- as an embedded string
        procedure disassemble_unsigned( n : unsigned; index : positive ) is
            variable str            : string := to_string(to_integer(n));
        begin
            result(index to (index + str'length - 1)) := str;
        end procedure disassemble_unsigned;

        -- Sub-procedure to disassemble a signed value and store the result
        -- as an embedded string (this is a degenerate case and could have just duplicated
        -- the other procedure and used a cast, but that would be silly.
        procedure disassemble_signed( n : signed; index : positive ) is
            variable str            : string := to_string(to_integer(n));
        begin
            result(index to (index + str'length - 1)) := str;
        end procedure disassemble_signed;

        -- Sub-procedure to disessemble the effective address
        procedure disassemble_effective_addr(
                    r : reg_addr_t; d : offset_t; index : positive ) is
            -- I supposed this is necessary since offsets are unsigned
            variable signed_str     : string    := to_string(to_integer(signed(d)));
            variable unsigned_str   : string    := to_string(to_integer(d));
        begin
            if r = 0 then
                result(index to index + unsigned_str'length - 1) := unsigned_str;
            else
                -- These do some string operations that make me rather uncomfortable
                result(index to index + 3) := "(r )";
                disassemble_reg(r, index + 2);
                result(index + 4 to (index + 4 + signed_str'length - 1) := signed_str;
            end if;
        end procedure disassemble_effective_addr;



        
