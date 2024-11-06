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
    constant R  : std_logic_vector (C_block_size-1 downto 0) :=  x"2e6da17125d70c3934d664fa6ba06ea66ef2cfb6231a309c6b3fc8e0d2cef7c4";
    constant R2 : std_logic_vector (C_block_size-1 downto 0) :=  x"2467a971d8bf24adb159e7853cff8763d234683622d953b04908760f68f04045";

    constant M : std_logic_vector (C_block_size-1 downto 0) := x"159e2d74f573b683df9ec95705d272ec39c4b3ef169905d8e6021e49672202f2";
    constant E : std_logic_vector (C_block_size-1 downto 0) := x"0000000000000000000000000000000000000000000000000000000000010001";
    constant N : std_logic_vector (C_block_size-1 downto 0) := x"346497a3b68a3cf1b2ca66c16517e45664434c12773973d8e5300dc7cb4c420f";
    constant X : std_logic_vector (C_block_size-1 downto 0) := x"1e8f6717b6aa034f553006cae30a601070e069996a2c387d75e6be430b6b4c63";

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
