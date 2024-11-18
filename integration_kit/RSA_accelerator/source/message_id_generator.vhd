library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity message_id_generator is
    generic (
        ID_WIDTH : integer := 4
    );
    port (
        clk                 : in std_logic;
        reset_n             : in std_logic;
        msgin_valid         : in std_logic;
        msgin_ready         : in std_logic;
        assigned_message_id : out std_logic_vector(ID_WIDTH-1 downto 0)
    );
end message_id_generator;

architecture rtl of message_id_generator is
    signal message_id_counter : unsigned(ID_WIDTH-1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                message_id_counter <= (others => '0');
            else
                if msgin_valid = '1' and msgin_ready = '1' then
                    if message_id_counter = (2**ID_WIDTH - 1) then
                        message_id_counter <= (others => '0');
                    else
                        message_id_counter <= message_id_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    assigned_message_id <= std_logic_vector(message_id_counter);
end rtl;
