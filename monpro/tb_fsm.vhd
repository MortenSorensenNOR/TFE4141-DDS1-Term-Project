library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity tb_fsm is
end tb_fsm ; 

architecture testbench of tb_fsm is
    constant DATA_SIZE : natural := 256;
    signal clk : std_logic := '0';
    signal rst : std_logic;
    signal start : std_logic;   -- launch the monpro algorithm (sample the A, B, N)
    signal ready : std_logic;  -- indicates that we are in the IDLE state (able to start)
    signal valid : std_logic;  -- shows that the result is valid (1 clock cycle)
    signal A_in : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0'); -- wired to the higher lvl
    signal B_in : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0'); -- wired to the higher lvl
    signal N_in : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0'); -- wired to the higher lvl
    signal Unp1_in : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0'); -- wired to Unp1 (result output of monpro_comb)
    signal A_out : std_logic_vector (DATA_SIZE-1 downto 0); -- wired to monpro_comb's input
    signal B_out : std_logic_vector (DATA_SIZE-1 downto 0); -- wired to monpro_comb's input "B"
    signal N_out : std_logic_vector (DATA_SIZE-1 downto 0); -- wired to monpro_comb's input "N"
    signal U_out : std_logic_vector (DATA_SIZE-1 downto 0); -- wired to monpro_comb's input "Un"
    signal x,y,z : std_logic; -- wired to monpro_comb muxes'selection (in order: nb_mux, bypass_mux, srl_mux)
    signal result: std_logic_vector (DATA_SIZE-1 downto 0); -- registerde result
begin

    clk <= not(clk) after 5 ns;

    STIM : process
    begin
        -- Reset Sequence
        rst <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        rst <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        A_in <= std_logic_vector(to_unsigned(181, A_in'length));
        B_in <= std_logic_vector(to_unsigned(8453, B_in'length));
        N_in <= std_logic_vector(to_unsigned(45, N_in'length));
        Unp1_in <= (OTHERS => '0');
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';

        wait;
    end process ; -- STIM

    DUT : entity work.monpro_fsm_v2(behavioral)
    generic map (
        DATA_SIZE => DATA_SIZE
    )
    port map (
        clk => clk,
        rst => rst,
  
        start => start,
        ready => ready,
        valid => valid,
  
        A_in => A_in,
        B_in => B_in,
        N_in => N_in,
        Unp1_in => Unp1_in,
        A_out => A_out,
        B_out => B_out,
        N_out => N_out,
        U_out => U_out,
        x => x,
        y => y,
        z => z,
        result => result
    );

end architecture ;  