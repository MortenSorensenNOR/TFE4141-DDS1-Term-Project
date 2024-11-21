library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rsa_types.all;

entity dispatcher is
    generic (
        NUM_CORES    : integer := NUM_CORES;
        C_BLOCK_SIZE : integer := C_BLOCK_SIZE;
        ID_WIDTH     : integer := ID_WIDTH
    );
    port (
        clk                 : in std_logic;
        reset_n             : in std_logic;

        msgin_valid         : in std_logic;
        msgin_ready         : out std_logic;
        msgin_data          : in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        msgin_last          : in std_logic; 

        core_ready_array    : in std_logic_vector(NUM_CORES-1 downto 0);
        core_message        : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        core_message_id     : out std_logic_vector(ID_WIDTH-1 downto 0);
        core_message_last   : out std_logic;
        core_select_array   : out std_logic_vector(NUM_CORES-1 downto 0)
    );
end dispatcher;

architecture behavioral of dispatcher is
    -- Internal signals
    signal core_selected : integer := 0;  -- Indicates if a core is selected
    signal selected_core_index : integer range 0 to NUM_CORES-1 := 0;  -- Holds the selected core index
    signal core_message_id_reg : std_logic_vector(ID_WIDTH-1 downto 0) := (others => '0');  -- Tracks the message ID
    
    signal msgin_ready_internal : std_logic := '0';
    signal core_select_internal : std_logic_vector(NUM_CORES-1 downto 0) := (others => '0');
    signal core_message_internal : std_logic_vector(C_BLOCK_SIZE-1 downto 0) := (others => '0');

    signal internal_last : std_logic := '0';

begin
    -- Core Selection and Data Handling Process
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                -- Reset all internal signals
                core_selected <= 0;
                selected_core_index <= 0;
                core_message_id_reg <= (others => '0');
                msgin_ready_internal <= '0';
                core_select_internal <= (others => '0');
                core_message_internal <= (others => '0');
            else
                if core_selected = 0 then
                    -- Search for an available core
                    for i in 0 to NUM_CORES-1 loop
                        if core_ready_array(i) = '1' then
                            selected_core_index <= i;
                            core_selected <= 1;
                            exit;  -- Stop searching once an available core is found
                        end if;
                    end loop;
                elsif core_selected = 1 then
                    -- If msgin_valid is asserted, proceed to output data
                    if msgin_valid = '1' then
                        -- Set internal signals for core selection and data transfer
                        msgin_ready_internal <= '1';
                        core_message_internal <= msgin_data;
                        internal_last <= msgin_last;
                        core_select_internal(selected_core_index) <= '1';
                        
                        core_selected <= 2;  -- Release core selection for next iteration
                    end if;
                elsif core_selected = 2 then
                    core_message_id_reg <= std_logic_vector(unsigned(core_message_id_reg) + 1);
                    msgin_ready_internal <= '0';
                    core_message_internal <= (others => '0');
                    core_select_internal <= (others => '0');
                    core_selected <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Assign outputs to internal signals
    msgin_ready <= msgin_ready_internal;
    core_message <= core_message_internal;
    core_message_id <= core_message_id_reg;
    core_message_last <= internal_last; --might need to delay this or something
    core_select_array <= core_select_internal;

end behavioral;