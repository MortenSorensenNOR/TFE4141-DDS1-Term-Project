-- library ieee;
-- use ieee.std_logic_1164.all;
-- use IEEE.NUMERIC_STD.ALL;

-- entity adder257 is 
--     generic (
--         DATA_SIZE : natural := 256
--     );
--     port (
--         clk   : in std_logic;
--         ready : out std_logic;

--         i_A  : in std_logic_vector(256 downto 0);
--         i_B  : in std_logic_vector(256 downto 0);
--         i_dv : in std_logic;

--         o_C  : out std_logic_vector(257 downto 0) := (others => '0');
--         o_dv : out std_logic := '0'
--     );
-- end adder257;

-- architecture behavioral of adder257 is
--     type chunk_array_t is array (natural range <>) of std_logic_vector(48 downto 0);

--     -- SIGNALS
--     signal iter : integer range 0 to 6;

--     signal A_blocks     : chunk_array_t(5 downto 0) := (others => (others => '0'));
--     signal B_blocks     : chunk_array_t(5 downto 0) := (others => (others => '0'));

--     signal C_blocks     : chunk_array_t(5 downto 0) := (others => (others => '0'));
-- begin

--     process (i_A, i_B) begin
--         A_blocks(0) <= '0' & i_A(47  downto   0);
--         A_blocks(1) <= '0' & i_A(95  downto  48);
--         A_blocks(2) <= '0' & i_A(143 downto  96);
--         A_blocks(3) <= '0' & i_A(191 downto 144);
--         A_blocks(4) <= '0' & i_A(239 downto 192);
--         A_blocks(5) <= (others => '0') & i_A(256 downto 239);

--         B_blocks(0) <= '0' & i_B(47  downto   0);
--         B_blocks(1) <= '0' & i_B(95  downto  48);
--         B_blocks(2) <= '0' & i_B(143 downto  96);
--         B_blocks(3) <= '0' & i_B(191 downto 144);
--         B_blocks(4) <= '0' & i_B(239 downto 192);
--         B_blocks(5) <= (others => '0') & i_B(256 downto 239);
--     end process;

--     adder_process: process (clk) begin
--         if rising_edge(clk) then
--             if (i_dv = '1') then
--                 iter <= 1;
--                 o_dv <= '0';
--             elsif (iter = 6) then
--                 iter <= 0;
--             elsif (iter /= 0) then
--                 iter <= iter + 1;
--             end if;

--             C_blocks(0) <= std_logic_vector(unsigned(A_blocks(0)) + unsigned(B_blocks(0)))        
--             C_blocks(1) <= std_logic_vector(unsigned(A_blocks(0)) + unsigned(B_blocks(0)) + unsigned(C_blocks(0)(48)))        
--             C_blocks(2) <= std_logic_vector(unsigned(A_blocks(0)) + unsigned(B_blocks(0)) + unsigned(C_blocks(1)(48)))        
--             C_blocks(3) <= std_logic_vector(unsigned(A_blocks(0)) + unsigned(B_blocks(0)) + unsigned(C_blocks(2)(48)))        
--             C_blocks(4) <= std_logic_vector(unsigned(A_blocks(0)) + unsigned(B_blocks(0)) + unsigned(C_blocks(3)(48)))        
--             C_blocks(5) <= std_logic_vector(unsigned(A_blocks(0)) + unsigned(B_blocks(0)) + unsigned(C_blocks(4)(48)))        

--             -- Output valid
--             if (iter = 6) then
--                 o_dv <= '1';
--             else 
--                 o_dv <= '0';
--             end if;
--         end if;
--     end process;

--     o_C <= C_blocks(5)(17 downto 0) & C_blocks(4)(47 downto 0) & 
--            C_blocks(3)(47 downto 0) & C_blocks(2)(47 downto 0) & 
--            C_blocks(1)(47 downto 0) & C_blocks(0)(47 downto 0);

--     ready <= '1' when iter = 0 else '0';

-- end architecture;
