library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity adder257 is 
    generic (
        DATA_SIZE : natural := 256
    );
    port (
        clk   : in std_logic;
        ready : out std_logic;

        i_A  : in std_logic_vector(256 downto 0);
        i_B  : in std_logic_vector(256 downto 0);
        i_dv : in std_logic;

        o_C  : out std_logic_vector(257 downto 0) := (others => '0');
        o_dv : out std_logic := '0'
    );
end adder257;

architecture behavioral of adder257 is
    type chunk_array_t is array (natural range <>) of std_logic_vector(63 downto 0);

    -- SIGNALS
    signal iter : integer range 0 to 3;

    signal A_blocks     : chunk_array_t(3 downto 0) := (others => (others => '0'));
    signal B_blocks     : chunk_array_t(3 downto 0) := (others => (others => '0'));
    signal A_upper      : std_logic_vector(0 downto 0) := "0";
    signal B_upper      : std_logic_vector(0 downto 0) := "0";

    signal carry        : std_logic_vector(0 downto 0) := (others => '0');

    signal C_blocks     : chunk_array_t(3 downto 0) := (others => (others => '0'));
    signal C_carry      : std_logic_vector(1 downto 0);
begin

    process (i_A, i_B) begin
        A_blocks(0) <= i_A(63  downto   0);
        A_blocks(1) <= i_A(127 downto  64);
        A_blocks(2) <= i_A(191 downto 128);
        A_blocks(3) <= i_A(255 downto 192);

        B_blocks(0) <= i_B(63  downto   0);
        B_blocks(1) <= i_B(127 downto  64);
        B_blocks(2) <= i_B(191 downto 128);
        B_blocks(3) <= i_B(255 downto 192);

        A_upper     <= i_A(256 downto 256);
        B_upper     <= i_B(256 downto 256);
    end process;

    adder_process: process (clk) 
        variable sum_with_carry : std_logic_vector(64 downto 0);
        variable carry_last     : std_logic_vector(64 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if (i_dv = '1') then
                iter <= 1;
                o_dv <= '0';
                C_blocks(1) <= (others => '0');
                C_blocks(2) <= (others => '0');
                C_blocks(3) <= (others => '0');
                carry <= (others => '0');
                carry_last := (others => '0');
            elsif (iter = 3) then
                iter <= 0;
            elsif (iter /= 0) then
                iter <= iter + 1;
            end if;

            -- Addition
            if (iter = 0) then
                carry_last(0) := '0';
            else
                carry_last(0) := carry(0);
            end if;

            sum_with_carry := std_logic_vector(unsigned('0' & A_blocks(iter)) + unsigned('0' & B_blocks(iter)) + unsigned(carry_last));

            C_blocks(iter) <= sum_with_carry(63 downto 0);
            carry <= sum_with_carry(64 downto 64);

            -- Output valid
            if (iter = 3) then
                o_dv <= '1';
            else 
                o_dv <= '0';
            end if;
        end if;
    end process;

    carry_process: process (carry, A_upper, B_upper) begin
        C_carry <= std_logic_vector(unsigned('0' & A_upper) + unsigned('0' & B_upper) + unsigned('0' & carry));
    end process;

    o_C <= C_carry & C_blocks(3) & C_blocks(2) & C_blocks(1) & C_blocks(0);
    ready <= '1' when iter = 0 else '0';

end architecture;
