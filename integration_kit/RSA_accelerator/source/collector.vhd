library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rsa_types.all;

entity collector is
    generic (
        NUM_CORES    : integer := NUM_CORES;
        C_BLOCK_SIZE : integer := C_BLOCK_SIZE;
        ID_WIDTH     : integer := ID_WIDTH
    );

    port (
        clk                     : in std_logic;
        reset_n                 : in std_logic;

        -- Inputs from exponentiation cores
        core_valid_array        : in std_logic_vector(NUM_CORES-1 downto 0);
        collector_ready_array   : out std_logic_vector(NUM_CORES-1 downto 0);
        core_msg_array          : in core_message_array_type;
        core_msg_ids            : in core_message_id_array_type;
        core_msg_last           : in std_logic_vector(NUM_CORES-1 downto 0);

        -- Outputs to rsa_msgout
        msgout_valid            : out std_logic;
        msgout_ready            : in std_logic;
        msgout_data             : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        msgout_last             : out std_logic
    );
end collector;

architecture Behavioral of collector is

    -- Type for buffer entries
    type buffer_entry_t is record
        data       : std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        message_id : std_logic_vector(ID_WIDTH-1 downto 0);
        full       : std_logic;
        last       : std_logic;
    end record;

    -- Buffer to hold messages from cores
    type buffer_array_t is array (0 to NUM_CORES-1) of buffer_entry_t;

    signal buf : buffer_array_t;

    signal expected_message_id : std_logic_vector(ID_WIDTH-1 downto 0) := (others => '0');

    -- Internal signals for outputs
    signal msgout_valid_int    : std_logic := '0';
    signal msgout_data_int     : std_logic_vector(C_BLOCK_SIZE-1 downto 0) := (others => '0');
    signal msgout_last_int     : std_logic := '0';
    signal collector_ready_int : std_logic_vector(NUM_CORES-1 downto 0);

    signal output_register : std_logic_vector(C_BLOCK_SIZE-1 downto 0) := (others => '0');
    signal output_valid    : std_logic := '0';

    type state_type is (IDLE, SEARCHING, OUTPUTTING);
    signal current_state : state_type := IDLE;

begin

    -- move all of this stuff into FSM above
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                -- Reset all internal signals
                expected_message_id <= (others => '0');
                for i in 0 to NUM_CORES-1 loop
                    buf(i).full <= '0';
                    buf(i).data <= (others => '0');
                    buf(i).message_id <= (others => '0');
                    buf(i).last <= '0';
                    collector_ready_int(i) <= '0';
                end loop;
                output_valid       <= '0';
                msgout_valid_int   <= '0';
                msgout_data_int    <= (others => '0');
                msgout_last_int    <= '0'; 
                
            else
                -- Manage input from exponentiation cores
                for i in 0 to NUM_CORES-1 loop
                    if buf(i).full = '0' then
                        collector_ready_int(i) <= '1';
                    else
                        collector_ready_int(i) <= '0';
                    end if;

                    -- Check if we can accept data from core i
                    if core_valid_array(i) = '1' and collector_ready_array(i) = '1' then
                        -- Store data into buf(i)
                        buf(i).data       <= core_msg_array(i);
                        buf(i).message_id <= core_msg_ids(i);
                        buf(i).last       <= core_msg_last(i); 
                        buf(i).full       <= '1';
                    end if;
                end loop;


                -- Manage output to rsa_msgout
                if current_state = SEARCHING then



                    for i in 0 to NUM_CORES-1 loop
                        if buf(i).full = '1' and buf(i).message_id = expected_message_id then -- Found the expected message

                            msgout_valid_int <= '1';
                            msgout_data_int  <= buf(i).data;
                            msgout_last_int  <= buf(i).last;
                            buf(i).full      <= '0'; -- Mark buffer slot as empty

                            current_state <= OUTPUTTING;
                            exit;
                        end if;
                    end loop;


                -- Handle output to rsa_msgout
                elsif current_state = OUTPUTTING then
                    if msgout_ready = '1' then -- Data has been accepted by rsa_msgout
                        --output_valid      <= '0';
                        msgout_valid_int  <= '0';
                        msgout_data_int   <= (others => '0'); 
                        msgout_last_int   <= '0';
                        expected_message_id <= std_logic_vector(unsigned(expected_message_id) + 1);
                        current_state <= SEARCHING;
                    end if;
                else -- IDLE state
                    current_state <= SEARCHING;
                end if;
                
            end if;
        end if;
    end process;
    

    -- Assign outputs to internal signals
    msgout_valid <= msgout_valid_int;
    msgout_data  <= msgout_data_int;
    msgout_last  <= msgout_last_int;  -- Adjust as needed
    collector_ready_array <= collector_ready_int;

end Behavioral;
