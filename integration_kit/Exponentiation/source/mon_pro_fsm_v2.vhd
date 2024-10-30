library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity monpro_fsm_v2 is
   generic (
      DATA_SIZE : natural := 257
   ) ;
   port (
      clk : in std_logic;
      rst : in std_logic;

      start : in std_logic;   -- launch the monpro algorithm (sample the A, B, N)
      ready : out std_logic;  -- indicates that we are in the IDLE state (able to start)
      valid : out std_logic;  -- shows that the result is valid (1 clock cycle)

      A_in : in std_logic_vector (DATA_SIZE-1 downto 0); -- wired to the higher lvl
      B_in : in std_logic_vector (DATA_SIZE-1 downto 0); -- wired to the higher lvl
      N_in : in std_logic_vector (DATA_SIZE-1 downto 0); -- wired to the higher lvl
      Unp1_in : in std_logic_vector (DATA_SIZE-1 downto 0); -- wired to Unp1 (result output of monpro_comb)
      
      A_out : out std_logic_vector (DATA_SIZE-1 downto 0); -- wired to monpro_comb's input
      B_out : out std_logic_vector (DATA_SIZE-1 downto 0); -- wired to monpro_comb's input "B"
      N_out : out std_logic_vector (DATA_SIZE-1 downto 0); -- wired to monpro_comb's input "N"
      U_out : out std_logic_vector (DATA_SIZE-1 downto 0); -- wired to monpro_comb's input "Un"

      x,y,z : out std_logic; -- wired to monpro_comb muxes'selection (in order: nb_mux, bypass_mux, srl_mux)

      result : out std_logic_vector (DATA_SIZE-1 downto 0) -- registerde result
   ) ;
end monpro_fsm_v2 ; 

architecture behavioral of monpro_fsm_v2 is
   type FSM_STATE is (IDLE, LOADING, CASE_1B, FINISHED);
   signal state_reg, state_nxt : FSM_STATE;
   
   signal a_reg, a_nxt : std_logic_vector (DATA_SIZE-1 downto 0);
   signal b_reg, b_nxt : std_logic_vector (DATA_SIZE-1 downto 0);
   signal n_reg, n_nxt : std_logic_vector (DATA_SIZE-1 downto 0);
   signal un_reg, un_nxt : std_logic_vector (DATA_SIZE-1 downto 0);

   signal cnt_reg, cnt_nxt : natural range 0 to 256;

   signal is_odd : std_logic;
   signal config : std_logic_vector (1 downto 0);
begin

   --U_out <= un_reg;
   result <= un_reg;
   A_out <= a_reg;
   B_out <= B_reg;
   N_out <= N_reg;

   ----------------------------------
    -- CTRL : Control process for FSM
    ----------------------------------
    CTRL : process( clk, rst )
    begin
        if rst = '1' then
            state_reg <= IDLE;
            cnt_reg <= 0;
            a_reg <= (OTHERS => '0');
            b_reg <= (OTHERS => '0');
            n_reg <= (OTHERS => '0');
            un_reg <= (OTHERS => '0');

        elsif rising_edge(clk) then
            cnt_reg <= cnt_nxt;
            a_reg <= a_nxt;
            b_reg <= b_nxt;
            n_reg <= n_nxt;
            un_reg <= un_nxt;
            state_reg <= state_nxt;
        end if ;
    end process ; -- CTRL


    OPE : process(cnt_reg, a_reg, b_reg, n_reg, un_reg, state_reg, start, A_in, B_in, N_in)
    begin
      is_odd <= (un_reg(0) xor (b_reg(0) and a_reg(0)));
      config <= is_odd & a_reg(0);

      cnt_nxt <= cnt_reg;
      a_nxt <= a_reg;
      b_nxt <= b_reg;
      n_nxt <= n_reg;
      un_nxt <= un_reg;
      state_nxt <= state_reg;

      x <= '0';
      y <= '0';
      z <= '0';

      U_out <= (OTHERS => '0');

      ready <= '0';
      valid <= '0';

      case( state_reg ) is
      
         when IDLE =>
            a_nxt <= A_in;
            b_nxt <= B_in;
            n_nxt <= N_in;
            un_nxt <= (OTHERS => '0');
            ready <= '1';
            if start = '1' then
               state_nxt <= LOADING;
            else
               state_nxt <= IDLE;
            end if;

         when LOADING =>
            a_nxt <= '0' & a_reg(DATA_SIZE-1 downto 1);
            cnt_nxt <= cnt_reg + 1;
            if cnt_reg = 0 then
               un_nxt <= (OTHERS => '0');
            else
               is_odd <= (Unp1_in(0) xor (b_reg(0) and a_reg(0)));
               un_nxt <= Unp1_in;
               U_out <= Unp1_in;
            end if;

            case (config) is
               when "00" =>
                  -- CASE 4
                  x <= '0'; -- d.c
                  y <= '1';
                  z <= '1';
                  if cnt_reg = DATA_SIZE-1 then
                     state_nxt <= FINISHED;
                  else
                     state_nxt <= LOADING;
                  end if;
               when "01" =>
                  -- CASE 2
                  x <= '0';
                  y <= '0';
                  z <= '1';
                  if cnt_reg = DATA_SIZE-1 then
                     state_nxt <= FINISHED;
                  else
                     state_nxt <= LOADING;
                  end if;
               when "10" =>
                  -- CASE 3
                  x <= '1';
                  y <= '0';
                  z <= '1';
                  if cnt_reg = DATA_SIZE-1 then
                     state_nxt <= FINISHED;
                  else
                     state_nxt <= LOADING;
                  end if;
               when "11" =>
                  -- CASE 1
                  x <= '0';
                  y <= '0';
                  z <= '0';
                  state_nxt <= CASE_1B;
               when others =>
                  -- ERROR CASE
                  x <= '0';
                  y <= '0';
                  z <= '0';
                  state_nxt <= IDLE;
            end case;

         when CASE_1B =>
            -- CASE 1b
            x <= '1';
            y <= '0';
            z <= '1';
            un_nxt <= Unp1_in;
            U_out <= Unp1_in;
            if cnt_reg = DATA_SIZE-1 then
               state_nxt <= FINISHED;
            else
               state_nxt <= LOADING;
            end if;

         when FINISHED =>
            valid <= '1'; -- Result is finished
            state_nxt <= IDLE;
      
         when others =>
            x <= '0';
            y <= '0';
            z <= '0';
            state_nxt <= IDLE;
      
      end case ;


               

    end process ; -- OPE
end architecture ;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------


architecture behavioral_v2 of monpro_fsm_v2 is
   type FSM_STATE is (IDLE, LOADING, CASE_1, CASE_1B, CASE_2, CASE_3, CASE_4, FINISHED);
   signal state_reg, state_nxt : FSM_STATE;
   
   signal a_reg, a_nxt : std_logic_vector (DATA_SIZE-1 downto 0);
   signal b_reg, b_nxt : std_logic_vector (DATA_SIZE-1 downto 0);
   signal n_reg, n_nxt : std_logic_vector (DATA_SIZE-1 downto 0);
   signal un_reg, un_nxt : std_logic_vector (DATA_SIZE-1 downto 0);
   signal prev_un_reg, prev_un_nxt : std_logic_vector (DATA_SIZE-1 downto 0);


   signal cnt_reg, cnt_nxt : natural range 0 to 256;
begin

   U_out <= un_reg;
   result <= un_reg;
   A_out <= a_reg;
   B_out <= b_reg;
   N_out <= n_reg;

   ----------------------------------
    -- CTRL : Control process for FSM
    ----------------------------------
    CTRL : process( clk, rst )
    begin
        if rst = '1' then
            state_reg <= IDLE;
            cnt_reg <= 0;
            a_reg <= (OTHERS => '0');
            b_reg <= (OTHERS => '0');
            n_reg <= (OTHERS => '0');
            un_reg <= (OTHERS => '0');
            prev_un_reg <= (OTHERS => '0');

        elsif rising_edge(clk) then
            cnt_reg <= cnt_nxt;
            a_reg <= a_nxt;
            b_reg <= b_nxt;
            n_reg <= n_nxt;
            un_reg <= un_nxt;
            state_reg <= state_nxt;
            prev_un_reg <= prev_un_nxt;
        end if ;
    end process ; -- CTRL


    OPE : process(cnt_reg, a_reg, b_reg, n_reg, un_reg, state_reg, start, A_in, B_in, N_in, prev_un_reg)
      variable config : std_logic_vector (1 downto 0) := (OTHERS => '0');
    begin
      --config := (un_reg(0) xor (b_reg(0) and a_reg(0))) & a_reg(0);

      cnt_nxt <= cnt_reg;
      a_nxt <= a_reg;
      b_nxt <= b_reg;
      n_nxt <= n_reg;
      un_nxt <= un_reg;
      state_nxt <= state_reg;
      prev_un_nxt <= prev_un_reg;

      --x <= '0';
      --y <= '0';
      --z <= '0';

      ready <= '0';
      valid <= '0';



      case( state_reg ) is
      
         when IDLE =>
            cnt_nxt <= 0;
            ready <= '1';
            a_nxt <= A_in;
            b_nxt <= B_in;
            n_nxt <= N_in;
            x <= '0';
            y <= '0';
            z <= '0';
            if start = '1' then
               state_nxt <= LOADING;
            else
               state_nxt <= IDLE;
            end if;

         when LOADING =>
            a_nxt <= '0' & a_reg(DATA_SIZE-1 downto 1);
            cnt_nxt <= cnt_reg + 1; -- the next value will be for the next loading state
            if cnt_reg = 0 then
               config := (b_reg(0) and a_reg(0)) & a_reg(0);
               un_nxt <= (OTHERS => '0');
            else
               config := (Unp1_in(0) xor (b_reg(0) and a_reg(0))) & a_reg(0);
               un_nxt <= Unp1_in;
            end if;
            
            if cnt_reg = DATA_SIZE then
               state_nxt <= FINISHED; -- End of A reached
            else
               case( config ) is
               when "00" =>
                  state_nxt <= CASE_4;
               when "01" =>      
                  state_nxt <= CASE_2;
               when "10" =>
                  state_nxt <= CASE_3;
               when "11" =>
                  state_nxt <= CASE_1;
               when others =>
                  state_nxt <= IDLE; -- Error
               end case ;
            end if;
            

         when CASE_1 =>
            x <= '0';
            y <= '0';
            z <= '0';
            --prev_un_nxt <= Unp1_in;
            --un_nxt <= un_reg;
            un_nxt <= Unp1_in;

            state_nxt <= CASE_1B;
            

         when CASE_1B =>
            x <= '1';
            y <= '0';
            z <= '1';
            --un_nxt <= prev_un_nxt;
            --un_nxt <= Unp1_in;
            state_nxt <= LOADING;

         when CASE_2 =>
            x <= '0';
            y <= '0';
            z <= '1';
            un_nxt <= Unp1_in;
            state_nxt <= LOADING;

         when CASE_3 =>
            x <= '1';
            y <= '0';
            z <= '1';
            --un_nxt <= Unp1_in;
            state_nxt <= LOADING;

         when CASE_4 =>
            x <= '0'; -- d.c
            y <= '1';
            z <= '1';
            --un_nxt <= Unp1_in;
            state_nxt <= LOADING;

         when FINISHED =>
            result <= un_reg;
            valid <= '1';
            state_nxt <= IDLE;

         when others =>
            state_nxt <= IDLE;
      
      end case ;
 
    end process ; -- OPE
end architecture ;