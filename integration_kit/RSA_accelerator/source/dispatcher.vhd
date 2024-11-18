library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dispatcher is
    generic (
        NUM_CORES    : integer := 5;
        C_BLOCK_SIZE : integer := 256;
        ID_WIDTH     : integer := 3
    );
    port (
        clk                 : in std_logic;
        reset_n             : in std_logic;
        msgin_valid         : in std_logic;
        msgin_ready         : out std_logic;
        msgin_data          : in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        assigned_message_id : in std_logic_vector(ID_WIDTH-1 downto 0);
        core_busy           : in std_logic_vector(NUM_CORES-1 downto 0);  -- Input only
        core_valid_in       : out std_logic;  -- Single output
        core_message        : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);  -- Single output
        core_message_id     : out std_logic_vector(ID_WIDTH-1 downto 0);  -- Single output
        core_select         : out std_logic_vector(NUM_CORES-1 downto 0)  -- One-hot select signal
    );
end dispatcher;

architecture rtl of dispatcher is
    -- Internal signals
    signal selected_core_index : integer range 0 to NUM_CORES-1 := 0;
    signal core_selected       : std_logic := '0';
begin
    process(clk)
        variable available_core_found : boolean;
        variable v_msgin_ready        : std_logic;
        variable v_core_select        : std_logic_vector(NUM_CORES-1 downto 0);
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                msgin_ready    <= '1';
                core_valid_in  <= '0';
                core_message   <= (others => '0');
                core_message_id<= (others => '0');
                core_select    <= (others => '0');
            else
                -- Default assignments
                v_msgin_ready  := '0';
                core_valid_in  <= '0';
                core_message   <= (others => '0');
                core_message_id<= (others => '0');
                v_core_select  := (others => '0');
                available_core_found := false;

                if msgin_valid = '1' then
                    -- Check for available cores
                    for i in 0 to NUM_CORES-1 loop
                        if core_busy(i) = '0' then
                            available_core_found := true;
                            selected_core_index  <= i;
                            exit;  -- Exit the loop after finding the first available core
                        end if;
                    end loop;

                    if available_core_found then
                        -- Assign message to the selected core
                        core_valid_in      <= '1';
                        core_message       <= msgin_data;
                        core_message_id    <= assigned_message_id;
                        v_core_select(selected_core_index) := '1';

                        -- Message accepted
                        v_msgin_ready := '1';
                    else
                        -- No core available, stall input
                        v_msgin_ready := '0';
                    end if;
                else
                    -- No valid message, ready to accept new message
                    v_msgin_ready := '1';
                end if;

                -- Update outputs
                msgin_ready <= v_msgin_ready;
                core_select <= v_core_select;
            end if;
        end if;
    end process;

end rtl;