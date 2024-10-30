library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity tb_monpro_full is

end tb_monpro_full ; 

architecture testbench of tb_monpro_full is
    --constant HALF_PERIOD : integer := 5;
    constant DATA_SIZE : natural := 257;

    constant A_VAL : std_logic_vector (DATA_SIZE-1 downto 0) := '0'& x"1fc255c23a521b8e5ff3c6476dc0387f9baf2b64f388304f544b019cd3828187";
    constant B_VAL : std_logic_vector (DATA_SIZE-1 downto 0) := '0'& x"0f6975d1c4f38f2ea20a4daffaf041284b0768660137d9bee923051bf5a1f6df";
    constant N_VAL : std_logic_vector (DATA_SIZE-1 downto 0) := '0'& x"214113026b14068150e3ea296f64941438a6bd102fa443799b485a2af3cf6177";
    constant U_VAL : std_logic_vector (DATA_SIZE-1 downto 0) := '0'& x"09a938c1475ff745630bee9b68a8faf12e906b169bb72196f18e225293c2bc20";
    
    signal res_dbg_1, res_dbg_2 : std_logic_vector (DATA_SIZE-1 downto 0); 

    signal clk : std_logic := '0';
    signal rst : std_logic;

    -- TESTING SINGALS
    signal A,B,N : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
    signal start : std_logic;

    signal ready, valid : std_logic;
    signal A_out,B_out,N_out,U_out : std_logic_vector (DATA_SIZE-1 downto 0);
    signal Unp1 : std_logic_vector (DATA_SIZE-1 downto 0);
    signal result : std_logic_vector (DATA_SIZE-1 downto 0);

    signal x,y,z : std_logic;

begin

    FSM : entity work.monpro_fsm_v2(behavioral_v2)
    generic map (
        DATA_SIZE => DATA_SIZE
    )
    port map (
        clk => clk,
        rst => rst,
  
        start => start,
        ready => ready,
        valid => valid,
  
        A_in => A,
        B_in => B,
        N_in => N,
        result => result

        -- Comb
        Unp1_in => Unp1,
        A_out => A_out, -- unused
        B_out => B_out,
        N_out => N_out,
        U_out => U_out,
        x => x,
        y => y,
        z => z,
    );

    COMB : entity work.monpro_comb(behavioral)
    generic map (
        DATA_SIZE => DATA_SIZE
    )
    port map (
        B => B_out, 
        N => N_out, 
        Un => U_out, 

        Unp1 => Unp1,

        n_b_mux => x,
        bypass_mux => y,
        srl_mux => z
    );

    -- clock gen
    clk <= not(clk) after 5 ns;

    res_dbg_1 <= std_logic_vector(unsigned(B)+unsigned(N));
    res_dbg_2 <= '0' & res_dbg_1(DATA_SIZE-1 downto 1);

    STIM : process
    begin
        -- Reset sequence
        rst <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        rst<= '0';
        wait until rising_edge(clk);

        A <= A_VAL;
        B <= B_VAL;
        N <= N_VAL;
        wait until rising_edge(clk);

        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        
        wait until valid='1' for 255*5*2 ns;
        assert (valid = '1') report "Waiting for valid=1 timed out" severity warning;
        assert (result=U_VAL) report "Wrong Result" severity warning;
        wait;
    end process ; -- STIM

end architecture ;
