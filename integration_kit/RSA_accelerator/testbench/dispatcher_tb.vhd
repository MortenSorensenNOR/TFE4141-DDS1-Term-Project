library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dispatcher_tb is
end dispatcher_tb;

architecture behavioral of dispatcher_tb is
    -- Parameters
    constant NUM_CORES : integer := 5;
    constant C_BLOCK_SIZE : integer := 256;
    constant ID_WIDTH : integer := 3;

    -- Clock and Reset Signals
    signal clk : std_logic := '0';
    signal reset_n : std_logic := '0';

    -- Dispatcher Signals
    signal msgin_valid : std_logic := '0';
    signal msgin_ready : std_logic;
    signal msgin_data : std_logic_vector(C_BLOCK_SIZE-1 downto 0) := (others => '0');
    signal msgin_last : std_logic := '0';  -- Added missing msgin_last signal
    signal core_ready_array : std_logic_vector(NUM_CORES-1 downto 0) := (others => '0');
    signal core_message : std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    signal core_message_id : std_logic_vector(ID_WIDTH-1 downto 0);
    signal core_select_array : std_logic_vector(NUM_CORES-1 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;

    

    function random_wait_time(lower_bound : integer; upper_bound : integer; seed : integer) return time is
        variable rand_cycle : integer;
    begin
        rand_cycle := lower_bound + (seed mod (upper_bound - lower_bound + 1));
        return clk_period * rand_cycle;
    end function;

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
    end process;

    -- DUT Instantiation
    uut: entity work.dispatcher
        generic map (
            NUM_CORES => NUM_CORES,
            C_BLOCK_SIZE => C_BLOCK_SIZE,
            ID_WIDTH => ID_WIDTH
        )
        port map (
            clk => clk,
            reset_n => reset_n,
            msgin_valid => msgin_valid,
            msgin_ready => msgin_ready,
            msgin_data => msgin_data,
            msgin_last => msgin_last,  -- Connect msgin_last signal
            core_ready_array => core_ready_array,
            core_message => core_message,
            core_message_id => core_message_id,
            core_select_array => core_select_array
        );

    -- Reset Process
    reset_proc: process
    begin
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';
        wait;
    end process;

    -- Testbench Process
    tb_proc: process
        variable msg_data : std_logic_vector(C_BLOCK_SIZE-1 downto 0) := (others => '0');
        variable msg_count : integer := 0;
    begin
        msgin_valid <= '0';
        msgin_data <= (others => '0');
        wait until reset_n = '1';

        -- Generate Messages from rsa_msgin
        while msg_count < 20 loop  -- Enough iterations to ensure ID wraps around


            -- Generate the next message
            wait for clk_period;
            --wait for clk_period;
            --wait for random_wait_time(1, 4, msg_count);
            msg_count := msg_count + 1;
            msg_data := std_logic_vector(to_unsigned(msg_count, C_BLOCK_SIZE));
            msgin_data <= msg_data;
            msgin_valid <= '1';
            
            -- Wait for msgin_ready to go high, indicating the previous message was read
            wait until msgin_ready = '1';
            wait for clk_period;
            -- Set msgin_valid low and data to zero for 1 clock cycle after message is read
            msgin_valid <= '0';
            msgin_data <= (others => '0');

        end loop;
    end process;

    -- Core Ready Array Process
    -- Core Ready Processes for All Cores
    core_ready_procs: for core_index in 0 to NUM_CORES-1 generate
        core_ready_proc: process
        variable num_cycles : integer := 0;
        begin
            wait until reset_n = '1';
            while true loop
                -- Wait for a random interval between 6x to 12x the clock period
                wait for random_wait_time(8, 16, core_index + num_cycles);

                -- Set core_ready_array for this core to be available
                core_ready_array(core_index) <= '1';
                wait for clk_period;

                -- Wait until this core gets selected by the dispatcher
                wait until core_select_array(core_index) = '1';
                
                -- Core is now busy, deassert ready
                core_ready_array(core_index) <= '0';
            end loop;
        end process;
    end generate;

    -- Verification Process
    verification_proc: process
        variable expected_id : integer := 0;
    begin
        wait until reset_n = '1';
        while true loop
            wait until core_select_array(1) = '1';  -- Wait until the dispatcher selects the second core
            -- Verify that the correct message is sent
            assert core_message = std_logic_vector(to_unsigned(expected_id, C_BLOCK_SIZE))
                report "Incorrect core message data: Expected " & integer'image(expected_id) severity error;
            assert core_message_id = std_logic_vector(to_unsigned(expected_id mod 2**ID_WIDTH, ID_WIDTH))
                report "Incorrect core message ID: Expected " & integer'image(expected_id mod 2**ID_WIDTH) severity error;
            expected_id := expected_id + 1;
            wait for clk_period;
        end loop;
    end process;

end behavioral;