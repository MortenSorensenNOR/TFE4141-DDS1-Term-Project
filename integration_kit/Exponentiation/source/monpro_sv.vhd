library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity monpro_sv is
    generic (
        DATA_SIZE : natural := 256
    ) ;
    port (
        clk : in std_logic;
        srstn : in std_logic;

        start : in std_logic;
        ready : out std_logic;
        o_valid : out std_logic;

        i_A : in std_logic_vector (DATA_SIZE-1 downto 0);
        i_B : in std_logic_vector (DATA_SIZE-1 downto 0);
        i_N : in std_logic_vector (DATA_SIZE-1 downto 0);
        o_U : out std_logic_vector (DATA_SIZE-1 downto 0)
    ) ;
end monpro_sv ; 

architecture behavioral of monpro_sv is
    -- Iteration counter
    signal cnt_i : integer range 0 to DATA_SIZE;

    -- Data registers
    signal r_A : std_logic_vector (DATA_SIZE-1 downto 0);
    signal r_B : std_logic_vector (DATA_SIZE-1 downto 0);
    signal r_N : std_logic_vector (DATA_SIZE-1 downto 0);

    signal U_reg : std_logic_vector (DATA_SIZE downto 0);

    signal w_A_i : std_logic;
    signal w_B_0 : std_logic;
    signal w_U_0 : std_logic;
    signal w_A_and_B : std_logic;
    signal w_is_odd : std_logic;

    -- Combinational
    signal adder_input : std_logic_vector (DATA_SIZE downto 0);
    signal adder_result : std_logic_vector (DATA_SIZE downto 0);
    signal adder_bypass_result : std_logic_vector (DATA_SIZE downto 0);
    signal monpro_comb_result : std_logic_vector (DATA_SIZE downto 0);

    signal alu_sub_mode, adder_input_mux_select, adder_bypass_mux_select, adder_result_shift_mux_select : std_logic;

    -- FSM STATES
    type FSM_STATE is ( MONPRO_IDLE,
                        MONPRO_LOAD,
                        MONPRO_CASE1A,
                        MONPRO_CASE1B,
                        MONPRO_CASE2,
                        MONPRO_CASE3,
                        MONPRO_CASE4,
                        MONPRO_LAST_SUB,
                        MONPRO_DONE );
    signal current_state, next_state : FSM_STATE; 
    
begin
    ----------------------------------
    -- MONPRO Combinational process
    ----------------------------------
    MONPRO_COMB : process(  alu_sub_mode,
                            adder_input_mux_select,
                            adder_bypass_mux_select,
                            adder_result_shift_mux_select,
                            U_reg,
                            adder_result,
                            adder_input,
                            adder_bypass_result,
                            monpro_comb_result )
    begin
        -------------------------------------
        -- Select adder input MUX
        -------------------------------------
        if adder_input_mux_select = '1' then
            adder_input <= '0' & r_N; -- DATA_SIZE+1 padding
        else
            adder_input <= '0' & r_B; -- DATA_SIZE+1 padding
        end if;

        -------------------------------------
        -- Adder
        -------------------------------------
        if alu_sub_mode = '1' then
            adder_result <= std_logic_vector(unsigned(U_reg) - unsigned(adder_input));
        else
            adder_result <= std_logic_vector(unsigned(U_reg) + unsigned(adder_input));
        end if;

        -------------------------------------
        -- BYPASS MUX
        -------------------------------------
        if adder_bypass_mux_select = '1' then
            adder_bypass_result <= U_reg;
        else
            adder_bypass_result <= adder_result;
        end if;

        -------------------------------------
        -- SHIFT REGISTER MUX
        -------------------------------------
        if adder_result_shift_mux_select = '1' then
            monpro_comb_result <= adder_bypass_result;
        else
            monpro_comb_result <= '0' & adder_bypass_result(DATA_SIZE downto 1);
        end if;
    end process ; -- MONPRO_COMB


    ----------------------------------
    -- FSM Control process
    ----------------------------------
    FSM_CTRL : process(clk)
    begin
        if rising_edge(clk) then
            if srstn = '0' then
                current_state <= MONPRO_IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process ; -- CTRL


    ----------------------------------
    -- FSM Transition process
    ----------------------------------
    FSM_TRANS : process( current_state, start, w_A_i, w_is_odd, cnt_i )
    begin
        next_state <= current_state;
        ready <= '0';

        case( current_state ) is
            when MONPRO_IDLE =>
                if start = '1' then
                    ready <= '0';
                    next_state <= MONPRO_LOAD;
                else
                    ready <= '1';
                    next_state <= MONPRO_IDLE;
                end if;    

            when MONPRO_LOAD =>
                if cnt_i = DATA_SIZE then
                    if (U_reg >= ('0' & r_N)) then
                        next_state <= MONPRO_LAST_SUB;
                    else 
                        next_state <= MONPRO_DONE;
                    end if;
                else 
                    if (w_A_i='1' and w_is_odd='1') then
                        next_state <= MONPRO_CASE1A;
                    elsif (w_A_i='1' and w_is_odd='0') then
                        next_state <= MONPRO_CASE2;
                    elsif (w_A_i='0' and w_is_odd='1') then
                        next_state <= MONPRO_CASE3;
                    else
                        next_state <= MONPRO_CASE4;
                    end if;
                end if;

            when MONPRO_CASE1A =>
                next_state <= MONPRO_CASE1B;

            when MONPRO_CASE1B =>
                next_state <= MONPRO_LOAD;

            when MONPRO_CASE2 =>
                next_state <= MONPRO_LOAD;

            when MONPRO_CASE3 =>
                next_state <= MONPRO_LOAD;

            when MONPRO_CASE4 =>
                next_state <= MONPRO_LOAD;

            when MONPRO_LAST_SUB => 
                next_state <= MONPRO_DONE;

            when MONPRO_DONE =>
                next_state <= MONPRO_IDLE;
        
            when others =>
                next_state <= MONPRO_IDLE;
        end case ;
    end process ; -- FSM_TRANS

    
    ----------------------------------
    -- FSM Transition Assignments process
    ---------------------------------- 
    FSM_ASSIG : process( clk )
    begin
        if rising_edge(clk) then
            if srstn = '0' then
                cnt_i <= 0;

                r_A   <= (OTHERS => '0');
                r_B   <= (OTHERS => '0');
                r_N   <= (OTHERS => '0');
                U_reg <= (OTHERS => '0');
                
                o_U <= (OTHERS => '0');
                o_valid <= '0';
            else
                U_reg <= U_reg;
                case (current_state) is
                    when MONPRO_IDLE =>
                        if start = '1' then
                            r_A <= i_A;
                            r_B <= i_B;
                            r_N <= i_N;
                            U_reg <= (OTHERS => '0');
                        end if;

                        cnt_i <= 0;

                        -- Reset output data
                        o_U <= (OTHERS => '0');
                        o_valid <= '0';
                        -- U_reg <= monpro_comb_result;
                

                    when MONPRO_LOAD =>
                        if (cnt_i = DATA_SIZE) then
                            if (U_reg >= ('0' & r_N)) then
                                alu_sub_mode <= '1';
                                adder_input_mux_select <= '1';
                                adder_bypass_mux_select <= '0';
                                adder_result_shift_mux_select <= '1';
                            end if;
                        else 
                            if (w_A_i='1' and w_is_odd='1') then
                                alu_sub_mode <= '0';
                                adder_input_mux_select <= '0';
                                adder_bypass_mux_select <= '0';
                                adder_result_shift_mux_select <= '1';
                            elsif (w_A_i='1' and w_is_odd='0') then
                                alu_sub_mode <= '0';
                                adder_input_mux_select <= '0';
                                adder_bypass_mux_select <= '0';
                                adder_result_shift_mux_select <= '0';
                            elsif (w_A_i='0' and w_is_odd='1') then
                                alu_sub_mode <= '0';
                                adder_input_mux_select <= '1';
                                adder_bypass_mux_select <= '0';
                                adder_result_shift_mux_select <= '0';
                            else
                                alu_sub_mode <= '0';
                                adder_input_mux_select <= '1';
                                adder_bypass_mux_select <= '1';
                                adder_result_shift_mux_select <= '0';
                            end if;
                            cnt_i <= cnt_i + 1;
                            r_A <= '0' & r_A(DATA_SIZE-1 downto 1);
                        end if;
                    

                    when MONPRO_CASE1A =>
                        U_reg <= monpro_comb_result;
                        adder_input_mux_select <= '1';
                        adder_bypass_mux_select <= '0';
                        adder_result_shift_mux_select <= '0';

                    when MONPRO_CASE1B =>
                        U_reg <= monpro_comb_result;

                    when MONPRO_CASE2 =>
                        U_reg <= monpro_comb_result;

                    when MONPRO_CASE3 =>
                        U_reg <= monpro_comb_result;

                    when MONPRO_CASE4 =>
                        U_reg <= monpro_comb_result;

                    when MONPRO_LAST_SUB =>
                        U_reg <= monpro_comb_result;

                    when MONPRO_DONE =>
                        o_U <= U_reg(DATA_SIZE-1 downto 0);
                        o_valid <= '1';

                    when others =>
                        U_reg <= U_reg;
                        o_U <= (OTHERS => '0');
                        o_valid <= '0';
                end case;
            end if;    
        end if;
    end process ; -- FSM_ASSIG

    w_A_i <= r_A(0);
    w_B_0 <= r_B(0);
    w_U_0 <= U_reg(0);
    w_A_and_B <= w_A_i and w_B_0;
    w_is_odd <= w_U_0 xor (w_A_and_B);

end architecture ;
