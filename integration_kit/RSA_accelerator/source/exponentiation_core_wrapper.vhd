library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation_core_wrapper is
    generic (
        C_BLOCK_SIZE : integer := 256;
        ID_WIDTH     : integer := 4
    );
    port (
        clk              : in std_logic;
        reset_n          : in std_logic;
        shared_valid_in  : in std_logic;
        shared_message   : in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        shared_message_id: in std_logic_vector(ID_WIDTH-1 downto 0);
        core_select      : in std_logic;  -- Signal indicating this core should latch the data
        key_e_d          : in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        key_n            : in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        r                : in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        r_square         : in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        valid_out        : out std_logic;
        msg_out          : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        core_busy        : out std_logic;
        core_message_id  : out std_logic_vector(ID_WIDTH-1 downto 0)
    );
end exponentiation_core_wrapper;

architecture rtl of exponentiation_core_wrapper is

    -- Internal registers to store input data
    signal message_reg      : std_logic_vector(C_BLOCK_SIZE-1 downto 0) := (others => '0');
    signal message_id_reg   : std_logic_vector(ID_WIDTH-1 downto 0) := (others => '0');
    signal core_busy_internal : std_logic := '0';

    -- Signals for exponentiation core
    signal exp_valid_in     : std_logic := '0';
    signal exp_ready_in     : std_logic;
    signal exp_valid_out    : std_logic;
    signal exp_msg_out      : std_logic_vector(C_BLOCK_SIZE-1 downto 0);

    -- Ready to accept new data when not busy and core is selected
    signal ready_to_accept  : std_logic;

begin

    -- Core busy output assignment
    core_busy <= core_busy_internal;

    -- Ready to accept new data when not busy and core is selected
    ready_to_accept <= not core_busy_internal and core_select;

    -- Process to handle input data latching and core busy signal
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                core_busy_internal <= '0';
                message_reg        <= (others => '0');
                message_id_reg     <= (others => '0');
                exp_valid_in       <= '0';
            else
                if ready_to_accept = '1' and shared_valid_in = '1' then
                    -- Latch input data and message ID
                    message_reg      <= shared_message;
                    message_id_reg   <= shared_message_id;
                    core_busy_internal <= '1';
                    exp_valid_in     <= '1';  -- Start the exponentiation core
                elsif exp_valid_in = '1' and exp_ready_in = '1' then
                    -- Exponentiation core has accepted the input
                    exp_valid_in <= '0';
                end if;

                -- Clear busy flag when processing is complete
                if exp_valid_out = '1' then
                    core_busy_internal <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Instantiate the exponentiation core
    exponentiation_inst : entity work.exponentiation
        generic map (
            C_block_size => C_BLOCK_SIZE
        )
        port map (
            clk        => clk,
            reset_n    => reset_n,
            valid_in   => exp_valid_in,
            ready_in   => exp_ready_in,
            message    => message_reg,
            key_e_d    => key_e_d,
            key_n      => key_n,
            r          => r,
            r_square   => r_square,
            valid_out  => exp_valid_out,
            ready_out  => '1',         -- Always ready to accept the output
            msg_out    => exp_msg_out
        );

    -- Output assignments
    valid_out       <= exp_valid_out;
    msg_out         <= exp_msg_out;
    core_message_id <= message_id_reg;

end rtl;
