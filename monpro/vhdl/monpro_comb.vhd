library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity monpro_comb is
   generic (
      DATA_SIZE : natural := 257
   ) ;
   port (
      B : in std_logic_vector (DATA_SIZE-1 downto 0);
      N : in std_logic_vector (DATA_SIZE-1 downto 0);
      Un : in std_logic_vector (DATA_SIZE-1 downto 0);

      Unp1 : out std_logic_vector (DATA_SIZE-1 downto 0);

      n_b_mux : in std_logic;
      bypass_mux : in std_logic;
      srl_mux : in std_logic
   ) ;
end monpro_comb ; 

architecture behavioral of monpro_comb is
    signal n_b_sig, res_sig : std_logic_vector (DATA_SIZE-1 downto 0);
    signal adder_out_sig, bypass_sig : std_logic_vector (DATA_SIZE-1 downto 0);
begin


   ---------------------------
   -- Mux for N or B selection
   ---------------------------
   with n_b_mux select
   n_b_sig <= B when '0',
            N when '1',
            (OTHERS => '0') when others;

   ---------------------------
   -- 256 bits Adder
   ---------------------------
   adder_out_sig <= std_logic_vector(unsigned(Un) + unsigned(n_b_sig));

   -------------------------------------
   -- Mux for bypassing or not the adder
   -------------------------------------
   with bypass_mux select
   bypass_sig <= adder_out_sig when '0',
               Un when '1',
               (OTHERS => '0') when others;

   -------------------------------------
   -- Mux for bypassing or not the SRL
   -------------------------------------
   with srl_mux select
   res_sig <= bypass_sig(DATA_SIZE-1 downto 0) when '0', --257
              '0' & bypass_sig(DATA_SIZE-1 downto 1) when '1', -- srl shiffting --256
              (OTHERS => '0') when others;

   Unp1 <= res_sig; -- output result

end architecture ;