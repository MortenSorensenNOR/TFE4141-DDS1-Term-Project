library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity tb_monpro_sv is
end tb_monpro_sv ; 

architecture testbench of tb_monpro_sv is
    ----------------------------------------------------
    --               TESTBENCH CONSTANTS              --
    ----------------------------------------------------
    constant PERIOD : time := 10 ns;
    constant VALID_TIMEOUT : time := 1024*PERIOD;
    constant DATA_SIZE : integer := 256;
    ------------------- TEST VECTORS -------------------
    constant A_VAL : std_logic_vector (DATA_SIZE-1 downto 0) :=  x"1fc255c23a521b8e5ff3c6476dc0387f9baf2b64f388304f544b019cd3828187";
    constant B_VAL : std_logic_vector (DATA_SIZE-1 downto 0) :=  x"0f6975d1c4f38f2ea20a4daffaf041284b0768660137d9bee923051bf5a1f6df";
    constant N_VAL : std_logic_vector (DATA_SIZE-1 downto 0) :=  x"214113026b14068150e3ea296f64941438a6bd102fa443799b485a2af3cf6177";
    constant U_VAL : std_logic_vector (DATA_SIZE-1 downto 0) :=  x"09a938c1475ff745630bee9b68a8faf12e906b169bb72196f18e225293c2bc20";
    -----------------------------------------------------

    signal clk : std_logic := '0';
    signal srstn : std_logic := '0';

    signal start : std_logic := '0';
    signal ready : std_logic;
    signal o_valid : std_logic;

    signal i_A : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
    signal i_B : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
    signal i_N : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
    signal o_U : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
begin
    ---------------------------------------
    -- DUT : Monpro_sv
    ---------------------------------------
    DUT : entity work.monpro_sv(behavioral)
    generic map (
        DATA_SIZE => DATA_SIZE
    )
    port map (
        clk => clk,
        srstn => srstn,
    
        start => start,
        ready => ready,
        o_valid => o_valid,
    
        i_A => i_A,
        i_B => i_B,
        i_N => i_N,
        o_U => o_U
    );

    -- clock gen
    clk <= not(clk) after PERIOD/2;

    --res_dbg_1 <= std_logic_vector(unsigned(B)+unsigned(N));
    --res_dbg_2 <= '0' & res_dbg_1(DATA_SIZE-1 downto 1);

    STIM : process
    begin
        -- Reset sequence
        srstn <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        srstn<= '1';
        wait until rising_edge(clk);

        i_A <= A_VAL;
        i_B <= B_VAL;
        i_N <= N_VAL;

        -- Starting Computation sequence
        wait until rising_edge(clk);
        wait until (ready='1' and rising_edge(clk));
        report "Ready detected, starting";
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        
        -- Result validation Sequence
        wait until o_valid='1' for VALID_TIMEOUT;
        assert (o_valid = '1') report "Waiting for valid=1 timed out" severity warning;
        assert (o_U=U_VAL) report "Wrong Result" severity warning;

        wait;
    end process ; -- STIM

end architecture ;
