----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2024 02:54:46 PM
-- Design Name: 
-- Module Name: tb_adder257 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_adder257 is
--  Port ( );
end tb_adder257;

architecture Behavioral of tb_adder257 is
    constant DATA_SIZE : integer := 256;
    constant PERIOD : time := 10 ns;
    
    constant A_VAL : std_logic_vector (DATA_SIZE downto 0) :=  "11010100110111011111010000011111100000110000011010001101010001111100000000101010101010010100001010101101100001111011110111011011110101101010110010010111000100010111100111011011100110110000111101101001100111010111101100100101001110101101110010110010001111111";
    constant B_VAL : std_logic_vector (DATA_SIZE downto 0) :=  "10010101100111100111110000100010000110100010101100100110001010110101111001111100110001010000111011001011101101101010000000101101100101011110110001110110011100010000011001101110100010111110101110110001011000011000110001110101001011110101011100110001010011100";
    constant C_VAL : std_logic_vector (DATA_SIZE+1 downto 0) :=  "101101010011111000111000001000001100111010011000110110011011100110001111010100111011011100101000101111001001111100101111000001001011011001001100100001101100000101000000001001010001001101111101100011010111111110000011110011010011010100011001111100011100011011";
    
    signal clk : std_logic := '0';
    signal ready : std_logic;

    signal i_A : std_logic_vector (256 downto 0);
    signal i_B : std_logic_vector (256 downto 0);
    signal i_dv : std_logic;
    
    signal o_C : std_logic_vector (257 downto 0);
    signal o_dv : std_logic;

begin
    
    DUT : entity work.adder257(behavioral)
    generic map (
        DATA_SIZE => DATA_SIZE
    )
    port map (
        clk => clk,
        ready => ready,
        
        i_A => i_A,
        i_B => i_B,
        i_dv => i_dv,
        
        o_C => o_C,
        o_dv => o_dv
    );

    clk <= not(clk) after PERIOD/2;
    
    STIM : process begin
        i_A <= (others => '0');
        i_B <= (others => '0');
        i_dv <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        i_A <= A_VAL;
        i_B <= B_VAL;
        i_dv <= '1';
        wait until rising_edge(clk);
        i_dv <= '0';
        
        wait until o_dv='1' for 1024 * PERIOD;
        assert (o_dv = '1') report "Timed out" severity warning;
        assert (o_C = C_VAL) report "Wrong result" severity warning;
        wait;
    end process;

end Behavioral;
