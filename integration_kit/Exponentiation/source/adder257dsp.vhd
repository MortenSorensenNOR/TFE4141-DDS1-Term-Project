------------------------------------------------
-- File : adder257dsp.vhd
-- Author : Corentin M / Morten S
-- Creation : Fri. 22 Nov 2024 17h03m14s 
-- Descritpion : 
-- Comments :
------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
    use UNISIM.vcomponents.all;

Library UNIMACRO;
    use UNIMACRO.vcomponents.all;

entity adder257dsp is 
    generic (
        DATA_SIZE : natural := 256;
        NB_STAGE : natural := 6
    );
    port (
        clk   : in std_logic;
        rst   : in std_logic;
        ready : out std_logic;

        i_A  : in std_logic_vector(256 downto 0);
        i_B  : in std_logic_vector(256 downto 0);
        i_dv : in std_logic;

        o_C  : out std_logic_vector(257 downto 0) := (others => '0');
        o_dv : out std_logic := '0'
    );
end adder257dsp;

architecture structural_dsp of adder257dsp is
    type chunk_array_t is array (natural range <>) of std_logic_vector(47 downto 0);

    -- SIGNALS
    signal iter : integer range 0 to NB_STAGE;

    signal A_blocks     : chunk_array_t(NB_STAGE-1 downto 0) := (others => (others => '0'));
    signal B_blocks     : chunk_array_t(NB_STAGE-1 downto 0) := (others => (others => '0'));
    signal C_blocks     : chunk_array_t(NB_STAGE-1 downto 0) := (others => (others => '0'));

    signal carry_i : std_logic_vector (NB_STAGE downto 0);

    signal ce : std_logic;
begin
    
    ------------------------------------
    -- Forcing Clock Enable DSP to 1
    ------------------------------------
    ce <= '1';


    ------------------------------------
    -- A and B splitting into 48 blocks
    ------------------------------------
    process (i_A, i_B) begin
        A_blocks(0) <= i_A(47  downto   0);
        A_blocks(1) <= i_A(95  downto  48);
        A_blocks(2) <= i_A(143 downto  96);
        A_blocks(3) <= i_A(191 downto 144);
        A_blocks(4) <= i_A(239 downto 192);
        A_blocks(5)(17 downto 0) <= i_A(256 downto 239);
        A_blocks(5)(47 downto 18) <= (others => '0');

        B_blocks(0) <= i_B(47  downto   0);
        B_blocks(1) <= i_B(95  downto  48);
        B_blocks(2) <= i_B(143 downto  96);
        B_blocks(3) <= i_B(191 downto 144);
        B_blocks(4) <= i_B(239 downto 192);
        B_blocks(5)(17 downto 0) <= i_B(256 downto 239);
        B_blocks(5)(47 downto 18) <= (others => '0');
    end process;


    ------------------------------------
    -- Iteration and Valid logic
    ------------------------------------
    process (clk) begin
        if rising_edge(clk) then
            -- Waiting for all stages completed
            if (i_dv = '1') then
                iter <= 1;
                o_dv <= '0';
            elsif (iter = 6) then
                iter <= 0;
            elsif (iter /= 0) then
                iter <= iter + 1;
            end if;

            -- Output valid
            if (iter = 6) then
                o_dv <= '1';
            else 
                o_dv <= '0';
            end if;
        end if;
    end process;


    ---------------------------------------------------------
    -- Forcing first carry_in to '0' for first stage dsp
    ---------------------------------------------------------
    carry_i(0) <= '0'; 


    --------------------------------------------------
    -- ADDER Structure of N-Stage (DSP infering)
    --------------------------------------------------
    DSP_INFER : for i in 0 to NB_STAGE-1 generate

        --------------------------------------------------
        -- XILINX DSP48 EXPLICIT INFERING (Vivado macro)
        --------------------------------------------------
        ADDSUB_MACRO_inst : ADDSUB_MACRO
        generic map (
           DEVICE => "7SERIES", -- Target Device: "VIRTEX5", "7SERIES", "SPARTAN6" 
           LATENCY => 0,        -- Desired clock cycle latency, 0-2
           WIDTH => 48          -- Input / Output bus width, 1-48
        )         
        port map (
           CARRYOUT => carry_i(i+1), -- 1-bit carry-out output signal
           RESULT => C_blocks(i),     -- Add/sub result output, width defined by WIDTH generic
           A => A_blocks(i),               -- Input A bus, width defined by WIDTH generic
           ADD_SUB => '1',   -- 1-bit add/sub input, high selects add, low selects subtract
           B => B_blocks(i),               -- Input B bus, width defined by WIDTH generic
           CARRYIN => carry_i(i),   -- 1-bit carry-in input
           CE => ce,             -- 1-bit clock enable input
           CLK => clk,           -- 1-bit clock input
           RST => rst            -- 1-bit active high synchronous reset
        );

    end generate;


    -----------------------------------
    -- Final result and Ready assignment
    -----------------------------------
    o_C <= C_blocks(5)(17 downto 0) & C_blocks(4)(47 downto 0) & 
           C_blocks(3)(47 downto 0) & C_blocks(2)(47 downto 0) & 
           C_blocks(1)(47 downto 0) & C_blocks(0)(47 downto 0);
    
    ready <= '1' when iter = 0 else '0';

end architecture;