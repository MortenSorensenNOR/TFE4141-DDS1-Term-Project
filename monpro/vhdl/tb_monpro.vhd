library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity tb_monpro is
end tb_monpro ; 

architecture testbench of tb_monpro is
    constant DATA_SIZE : natural := 256;

    constant B_val : natural  :=  15; --985473240;
    constant N_val : natural  :=  20; --316576507;
    constant Un_val : natural :=  5; --634655669;

    signal B : std_logic_vector (DATA_SIZE-1 downto 0);
    signal N : std_logic_vector (DATA_SIZE-1 downto 0);
    signal Un : std_logic_vector (DATA_SIZE-1 downto 0);

    signal Unp1 : std_logic_vector (DATA_SIZE-1 downto 0);

    signal x : std_logic;
    signal y : std_logic;
    signal z : std_logic;
begin

    DUT : entity work.monpro_comb(behavioral)
    generic map (
        DATA_SIZE => DATA_SIZE
    )
    port map (
        B => B, 
        N => N, 
        Un => Un, 

        Unp1 => Unp1,

        n_b_mux => x,
        bypass_mux => y,
        srl_mux => z
    );

    STIM : process
    begin
        B <=  std_logic_vector(to_unsigned(B_val, B'length));
        N <=  std_logic_vector(to_unsigned(N_val, N'length));
        Un <= std_logic_vector(to_unsigned(Un_val, Un'length));
        wait for 5 ns;

        -------------------------------
        x<='0';
        y<='0';
        z<='0';
        wait for 5 ns;
        assert(unsigned(Unp1) = (B_val+Un_val)) report "Wrong add result" severity warning; -- B+Un
        -------------------------------
        x<='1';
        y<='0';
        z<='0';
        wait for 5 ns;
        assert(unsigned(Unp1) = (N_val+Un_val)) report "Wrong add result" severity warning; -- N+Un
        -------------------------------
        x<='0';
        y<='0';
        z<='1';
        wait for 5 ns;
        assert(unsigned(Unp1) = (B_val+Un_val)/2) report "Wrong add result" severity warning; -- (B+Un)/2
        -------------------------------
        x<='1';
        y<='0';
        z<='1';
        wait for 5 ns;
        assert(unsigned(Unp1) = (N_val+Un_val)/2) report "Wrong add result" severity warning; -- (N+Un)/2
        -------------------------------
        x<='0';
        y<='1';
        z<='0';
        wait for 5 ns;
        assert(unsigned(Unp1) = Un_val) report "Wrong add result" severity warning; -- Un
        -------------------------------
        x<='0';
        y<='1';
        z<='1';
        wait for 5 ns;
        assert(unsigned(Unp1) = Un_val/2)  report "Wrong add result" severity warning; -- Un/2
        -------------------------------
        wait;
    end process ; -- STIM

end architecture ;