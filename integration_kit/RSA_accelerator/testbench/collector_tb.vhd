library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rsa_types.all;  -- Ensure rsa_types defines core_msg_out_array_type and core_msg_id_out_array_type

entity collector_tb is
end collector_tb;

architecture Behavioral of collector_tb is

    -- Parameters
    constant NUM_CORES       : integer := 6;  -- Updated to match collector
    constant C_BLOCK_SIZE    : integer := 256;
    constant ID_WIDTH        : integer := 3;
    constant TOTAL_MESSAGES  : integer := 18;  -- Ensure TOTAL_MESSAGES is divisible by NUM_CORES

    -- Clock and Reset Signals
    signal clk        : std_logic := '0';
    signal reset_n    : std_logic := '0';

    -- Signals for the collector
    signal core_valid_array        : std_logic_vector(NUM_CORES-1 downto 0) := (others => '0');
    signal collector_ready_array   : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_msg_array          : core_msg_out_array_type;
    signal core_msg_ids            : core_msg_id_out_array_type;

    signal msgout_valid            : std_logic;
    signal msgout_ready            : std_logic := '1';  -- Assume always ready for simplicity
    signal msgout_data             : std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    signal msgout_last             : std_logic;  -- Not used in this testbench

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Clock Generation Process
    clk_gen: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process clk_gen;

    -- Reset Process
    reset_proc: process
    begin
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';
        wait;
    end process reset_proc;

    -- Instantiate the collector
    uut: entity work.collector
        generic map (
            NUM_CORES    => NUM_CORES,
            C_BLOCK_SIZE => C_BLOCK_SIZE,
            ID_WIDTH     => ID_WIDTH
        )
        port map (
            clk                   => clk,
            reset_n               => reset_n,
            core_valid_array      => core_valid_array,
            collector_ready_array => collector_ready_array,
            core_msg_array        => core_msg_array,
            core_msg_ids          => core_msg_ids,
            msgout_valid          => msgout_valid,
            msgout_ready          => msgout_ready,
            msgout_data           => msgout_data,
            msgout_last           => msgout_last
        );

    -- Process to simulate the exponentiation cores
    core_sim_procs: for i in 0 to NUM_CORES-1 generate
        core_proc: process
            variable num_cycles : integer := 0;
            variable seed       : integer := i + 1;
            variable msg_idx    : integer := 0;
            variable total_msgs : integer := TOTAL_MESSAGES / NUM_CORES;
            variable msg_data   : std_logic_vector(C_BLOCK_SIZE-1 downto 0);
            variable msg_id     : std_logic_vector(ID_WIDTH-1 downto 0);
            variable global_msg_index : integer;
        begin
            wait until reset_n = '1';
            while msg_idx < total_msgs loop
                -- Wait until collector is ready to accept data from this core
                wait until collector_ready_array(i) = '1';

                -- Simulate random processing time
                seed := seed + 1;
                num_cycles := 5 + (seed mod 10);  -- Random delay between 5 and 14 cycles
                wait for clk_period * num_cycles;

                -- Compute global message index
                global_msg_index := i * total_msgs + msg_idx;

                -- Generate message data and ID
                msg_data := std_logic_vector(to_unsigned(global_msg_index, C_BLOCK_SIZE));
                msg_id   := std_logic_vector(to_unsigned(global_msg_index mod (2 ** ID_WIDTH), ID_WIDTH));

                -- Assign message data and ID
                core_msg_ids(i)   <= msg_id;
                core_msg_array(i) <= msg_data;

                -- Assert valid signal
                core_valid_array(i) <= '1';
                wait for clk_period;

                -- Deassert valid signal
                core_valid_array(i) <= '0';

                -- Increment message index
                msg_idx := msg_idx + 1;
            end loop;
            wait;
        end process core_proc;
    end generate core_sim_procs;

    -- Verification process
    verification_proc: process
        variable received_count           : integer := 0;
        variable expected_message_id      : unsigned(ID_WIDTH-1 downto 0) := (others => '0');
        variable expected_message_data    : std_logic_vector(C_BLOCK_SIZE-1 downto 0) := (others => '0');
        variable msgout_data_int          : integer;
    begin
        wait until reset_n = '1';
        while received_count < TOTAL_MESSAGES loop
            wait until rising_edge(clk);
            if msgout_valid = '1' then
                -- Determine expected message data and ID
                expected_message_data := std_logic_vector(to_unsigned(received_count, C_BLOCK_SIZE));
                expected_message_id  := to_unsigned(received_count mod (2 ** ID_WIDTH), ID_WIDTH);

                -- Convert msgout_data to integer for easier comparison
                msgout_data_int := to_integer(unsigned(msgout_data));

                -- Check that the msgout_data corresponds to the expected message
                assert msgout_data = expected_message_data
                    report "Data mismatch at message " & integer'image(received_count) &
                           ": Expected data " & integer'image(received_count) &
                           ", got " & integer'image(msgout_data_int)
                    severity error;

                -- Increment received_count
                received_count := received_count + 1;
            end if;
        end loop;
        -- End simulation after all messages are received
        assert false report "Simulation completed successfully" severity note;
        wait;
    end process verification_proc;

end Behavioral;
