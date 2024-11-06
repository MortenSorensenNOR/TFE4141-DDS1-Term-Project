library ieee;
use ieee.std_logic_1164.all;


entity exponentiation_tb is
	generic (
		C_block_size : integer := 256
	);
end exponentiation_tb;


architecture expBehave of exponentiation_tb is
    ----------------------------------------------------
    --               TESTBENCH CONSTANTS              --
    ----------------------------------------------------
    constant PERIOD : time := 10 ns;
    constant VALID_TIMEOUT : time := 1024*PERIOD;
    ------------------- TEST VECTORS -------------------
    constant R  : std_logic_vector (C_block_size-1 downto 0) :=  x"666dae8c529a9798eac7a157ff32d7edfd77038f56436722b36f298907008973";
    constant R2 : std_logic_vector (C_block_size-1 downto 0) :=  x"56ddf8b43061ad3dbcd1757244d1a19e2e8c849dde4817e55bb29d1c20c06364";

    constant M : std_logic_vector (C_block_size-1 downto 0) := x"0a23232323232323232323232323232323232323232323232323232323232323";
    constant E : std_logic_vector (C_block_size-1 downto 0) := x"0000000000000000000000000000000000000000000000000000000000010001";
    constant N : std_logic_vector (C_block_size-1 downto 0) := x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
    constant X : std_logic_vector (C_block_size-1 downto 0) := x"85EE722363960779206A2B37CC8B64B5FC12A934473FA0204BBAAF714BC90C01";

	signal message 		: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal key_e_d 		: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal valid_in 	: STD_LOGIC := '0';
	signal ready_in 	: STD_LOGIC := '0';
	signal ready_out 	: STD_LOGIC := '0';
	signal valid_out 	: STD_LOGIC := '0';
	signal msg_out 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal key_n 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);

	signal clk 			: STD_LOGIC := '0';
	signal reset_n 		: STD_LOGIC := '0';

begin
    -- clock gen
    clk <= not(clk) after PERIOD/2;

	i_exponentiation : entity work.exponentiation
		port map (
            valid_in  => valid_in ,
            ready_in  => ready_in ,

			message   => message  ,
			key_e_d   => key_e_d  ,
            key_n     => key_n    ,

            r         => R,
            r_square  => R2,

			ready_out => ready_out,
			valid_out => valid_out,

			msg_out   => msg_out  ,

			clk       => clk      ,
			reset_n   => reset_n
		);

    STIM : process
    begin
        -- Reset sequence
        reset_n <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        reset_n <= '1';
        wait until rising_edge(clk);

        message <= M;
        key_e_d <= E;
        key_n   <= N;

        -- Starting Computation sequence
        wait until rising_edge(clk);
        wait until (ready_in='1' and rising_edge(clk));
        report "Ready detected, starting";
        valid_in <= '1';
        wait until rising_edge(clk);
        valid_in <= '0';
        
        -- Result validation Sequence
        wait until valid_out='1' for VALID_TIMEOUT;
        assert (valid_out = '1') report "Waiting for valid=1 timed out" severity warning;
        assert (msg_out=X) report "Wrong Result" severity warning;

        wait;
    end process ; -- STIM
end expBehave;
