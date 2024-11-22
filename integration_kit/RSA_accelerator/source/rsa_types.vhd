library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package rsa_types is
    -- Generic constants (define these explicitly or make them parameters)
    constant NUM_CORES    : integer := 11; -- Default values
    constant ID_WIDTH     : integer := 4;
    constant C_BLOCK_SIZE : integer := 256;

    -- Define array types for core outputs and message IDs
    type core_message_array_type is array (0 to NUM_CORES-1) of std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    type core_message_id_array_type is array (0 to NUM_CORES-1) of std_logic_vector(ID_WIDTH-1 downto 0);
end package;