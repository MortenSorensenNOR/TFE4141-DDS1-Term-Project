library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rsa_types.all;

entity collector is
    generic (
        NUM_CORES    : integer := 12;
        C_BLOCK_SIZE : integer := 256;
        ID_WIDTH     : integer := 4  -- Message ID width
    );
    port (
        clk              : in std_logic;
        reset_n          : in std_logic;
        -- Inputs from core wrappers
        core_valid_outs  : in std_logic_vector(NUM_CORES-1 downto 0);
        core_msg_outs    : in core_msg_outs_array;
        core_message_ids : in core_message_ids_array;
        -- Output interface
        msgout_valid     : out std_logic;
        msgout_ready     : in std_logic;
        msgout_data      : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        msgout_last      : out std_logic
    );
end collector;

architecture rtl of collector is

    -- Output buffer to store outputs indexed by message ID
    type output_buffer_type is array (0 to (2**ID_WIDTH)-1) of std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    signal output_buffer : output_buffer_type := (others => (others => '0'));

    -- Valid flags for each message ID
    signal output_valid_flags : std_logic_vector((2**ID_WIDTH)-1 downto 0) := (others => '0');

    -- Next expected output ID
    signal next_output_id : std_logic_vector(ID_WIDTH-1 downto 0) := (others => '0');

begin

    collector_process: process(clk)
        variable message_id_int     : integer;
        variable expected_id_int    : integer;
        variable temp_output_buffer : output_buffer_type;
        variable temp_valid_flags   : std_logic_vector((2**ID_WIDTH)-1 downto 0);
        variable temp_next_output_id: std_logic_vector(ID_WIDTH-1 downto 0);
        variable i                  : integer;
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                -- Reset all buffers and flags
                output_buffer       <= (others => (others => '0'));
                output_valid_flags  <= (others => '0');
                next_output_id      <= (others => '0');
                msgout_valid        <= '0';
                msgout_data         <= (others => '0');
                msgout_last         <= '0';
            else
                -- Initialize temporary variables with the current state
                temp_output_buffer := output_buffer;
                temp_valid_flags := output_valid_flags;
                temp_next_output_id := next_output_id;

                -- Collect outputs from cores
                for i in 0 to NUM_CORES-1 loop
                    if core_valid_outs(i) = '1' then
                        -- Convert message ID to integer for indexing
                        message_id_int := to_integer(unsigned(core_message_ids(i)));

                        -- Update temporary buffer and valid flags
                        temp_output_buffer(message_id_int) := core_msg_outs(i);
                        temp_valid_flags(message_id_int) := '1';
                    end if;
                end loop;

                -- Send outputs in order
                -- Convert next_output_id to integer for indexing
                expected_id_int := to_integer(unsigned(temp_next_output_id));

                -- Check if the next expected output is available
                if temp_valid_flags(expected_id_int) = '1' then
                    if msgout_ready = '1' then
                        -- Send the output data
                        msgout_data  <= temp_output_buffer(expected_id_int);
                        msgout_valid <= '1';
                        msgout_last  <= '1';  -- Assuming each message is a single packet

                        -- Clear the valid flag and buffer entry
                        temp_valid_flags(expected_id_int) := '0';
                        temp_output_buffer(expected_id_int) := (others => '0');

                        -- Increment next_output_id with wrap-around
                        if temp_next_output_id = std_logic_vector(to_unsigned((2**ID_WIDTH)-1, ID_WIDTH)) then
                            temp_next_output_id := (others => '0');
                        else
                            temp_next_output_id := std_logic_vector(unsigned(temp_next_output_id) + 1);
                        end if;
                    else
                        -- Hold the valid signal if downstream is not ready
                        msgout_valid <= '0';
                        msgout_last  <= '0';
                    end if;
                else
                    -- No valid output to send
                    msgout_valid <= '0';
                    msgout_last  <= '0';
                end if;

                -- Commit changes to the signals
                output_buffer <= temp_output_buffer;
                output_valid_flags <= temp_valid_flags;
                next_output_id <= temp_next_output_id;

            end if;
        end if;
    end process collector_process;

end rtl;
