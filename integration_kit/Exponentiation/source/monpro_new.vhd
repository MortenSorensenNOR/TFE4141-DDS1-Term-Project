library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.std_logic_arith.all;

entity monpro_new is
    generic (
        DATA_SIZE : natural := 256
    ) ;
    port (
        clk : in std_logic;
        srstn : in std_logic;

        start : in std_logic;
        ready : out std_logic := '0';
        o_valid : out std_logic := '0';

        i_A : in std_logic_vector (DATA_SIZE-1 downto 0);
        i_B : in std_logic_vector (DATA_SIZE-1 downto 0);
        i_N : in std_logic_vector (DATA_SIZE-1 downto 0);
        i_M : in std_logic_vector (DATA_SIZE-1 downto 0); -- Precomputed 2^k - n
        o_U : out std_logic_vector (DATA_SIZE-1 downto 0) := (others => '0')
    ) ;
end monpro_new; 

architecture behavioral of monpro_new is
    -- Iteration counter
    signal cnt_i : integer range 0 to DATA_SIZE+2;

    -- Data registers
    signal r_A : std_logic_vector (DATA_SIZE-1 downto 0) := (others => '0');
    signal r_B : std_logic_vector (DATA_SIZE-1 downto 0) := (others => '0');
    signal r_N : std_logic_vector (DATA_SIZE-1 downto 0) := (others => '0');
    signal r_M : std_logic_vector (DATA_SIZE-1 downto 0) := (others => '0'); -- Precomputed 2^k - n

    signal U_reg : std_logic_vector (DATA_SIZE downto 0) := (others => '0');
    signal B_N_sum_reg : std_logic_vector (DATA_SIZE downto 0) := (others => '0');

    signal w_A_i        : std_logic;
    signal w_B_0        : std_logic;
    signal w_U_0        : std_logic;
    signal w_A_and_B    : std_logic;
    signal w_is_odd     : std_logic;
    
    -- Adder signals
    signal adder_ready   : std_logic;

    signal adder_input_1 : std_logic_vector(DATA_SIZE downto 0) := (others => '0');
    signal adder_input_2 : std_logic_vector(DATA_SIZE downto 0) := (others => '0');
    signal adder_i_dv    : std_logic := '0';

    signal adder_output  : std_logic_vector(DATA_SIZE+1 downto 0) := (others => '0');
    signal adder_o_dv    : std_logic;

    -- FSM STATES
    type FSM_STATE is ( MONPRO_IDLE,
                        MONPRO_COMPUTE_B_N,
                        MONPRO_CASE_123,
                        MONPRO_CASE_123_REGISTER_RESULT,
                        MONPRO_CASE4,
                        MONPRO_LAST_SUB,
                        MONPRO_DONE );
    signal current_state, next_state : FSM_STATE; 

    signal reset : std_logic := '0'; -- inverted reset signal, just 0 for now
    
begin

    -- Main adder of the MonPro unit, optimized for clock frequency
    u_adder257 : entity work.adder257(behavioral)
    generic map (
        DATA_SIZE => DATA_SIZE
        --NB_STAGE => 6
    )
    port map (
        clk => clk,
        --rst => not(srstn),
        ready => adder_ready,

        i_A  => adder_input_1,
        i_B  => adder_input_2,
        i_dv => adder_i_dv,

        o_C  => adder_output,
        o_dv => adder_o_dv

    );

    -- FSM Register State
    FSM_CTRL : process(clk) begin
        if rising_edge(clk) then
            if srstn = '0' then
                current_state <= MONPRO_IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process ; -- CTRL

    -- TODO: ADD PROCESS SENSITIVITY LIST
    FSM_TRANS : process(
        cnt_i,
        current_state,
        start,
        adder_input_1,
        adder_input_2,
        adder_i_dv,
        adder_output,
        adder_o_dv,
        w_A_i,
        w_B_0,
        w_U_0,
        w_A_and_B,
        w_is_odd,
        U_reg
    )
    begin
        next_state <= current_state;
        ready <= '0';

        case( current_state ) is
            when MONPRO_IDLE =>
                if start = '1' then
                    ready <= '0';
                    next_state <= MONPRO_COMPUTE_B_N;
                elsif (adder_ready = '0') then
                    ready <= '0';
                else
                    ready <= '1';
                end if; 
            
            when MONPRO_COMPUTE_B_N =>
                if (adder_o_dv = '1') then
                    if (r_A(0) = '1') then
                        -- Case 1 and 2
                        if (w_B_0 = '1') then
                            next_state <= MONPRO_CASE_123; -- Case 1
                        else
                            next_state <= MONPRO_CASE_123; -- Case 2
                        end if;
                    else
                        next_state <= MONPRO_CASE4; -- Case 4
                    end if;
                end if;

            when MONPRO_CASE_123 =>
                if (adder_o_dv = '1') then
                    if (cnt_i = (DATA_SIZE - 1)) then
                        if (adder_output(DATA_SIZE+1 downto 1) >= ('0' & r_N)) then
                            next_state <= MONPRO_LAST_SUB;
                        else 
                            next_state <= MONPRO_DONE;
                        end if;
                    else
                        if (w_A_i = '0' and w_is_odd = '0') then
                            next_state <= MONPRO_CASE4;
                        else 
                            next_state <= MONPRO_CASE_123;
                        end if;
                    end if;
                end if;

            when MONPRO_CASE4 =>
                if (cnt_i = (DATA_SIZE - 1)) then
                    if ('0' & U_reg(DATA_SIZE downto 1) >= ('0' & r_N)) then
                        next_state <= MONPRO_LAST_SUB;
                    else
                        next_state <= MONPRO_DONE;
                    end if;
                else
                    if (w_A_i = '0' and (U_reg(1) xor w_A_and_B) = '0') then
                        next_state <= MONPRO_CASE4;
                    else
                        next_state <= MONPRO_CASE_123;
                    end if;
                end if;

            when MONPRO_LAST_SUB =>
                if (adder_o_dv='1') then
                    next_state <= MONPRO_DONE;
                end if;

            when MONPRO_DONE =>
                next_state <= MONPRO_IDLE;
        
            when others =>
                next_state <= MONPRO_IDLE;
        end case ;
    end process ; -- FSM_TRANS

    -- Assign signals and such based on state
    p_signals : process (clk) is begin
        if rising_edge(clk) then
            if srstn = '0' then
                cnt_i <= 0;

                r_A <= (others => '0');
                r_B <= (others => '0');
                r_N <= (others => '0');
                r_M <= (others => '0');
                U_reg <= (others => '0');

                o_U <= (others => '0');
                o_valid <= '0';
                
                adder_input_1 <= (others => '0');
                adder_input_2 <= (others => '0');
                adder_i_dv <= '0';

            else 
                case (current_state) is
                    when MONPRO_IDLE =>
                        if start = '1' then
                            r_A <= i_A;
                            r_B <= i_B;
                            r_N <= i_N;
                            r_M <= i_M;
                            U_reg <= (others => '0');
                        end if;

                        cnt_i <= 0;
                        o_U <= (others => '0');
                        o_valid <= '0';

                        adder_input_1 <= '0' & i_B;
                        adder_input_2 <= '0' & i_N;

                        if (start = '1') then
                            adder_i_dv <= '1';
                        else
                            adder_i_dv <= '0';
                        end if;

                    when MONPRO_COMPUTE_B_N =>
                        if (adder_o_dv = '1') then
                            B_N_sum_reg <= adder_output(DATA_SIZE downto 0);

                            -- Decide next state adder input signals
                            -- Becuase U_reg = 0, is_odd = A[i] and B[0]
                            -- Since A[i] = 0 means is_odd = 0, nothing 
                            -- needs to be done for A[i] = 0 in terms of signals
                            if (r_A(0) = '1') then
                                -- Case 1 and 2
                                if (w_B_0 = '1') then
                                    -- Case 1
                                    adder_input_1 <= U_reg;
                                    adder_input_2 <= adder_output(DATA_SIZE downto 0);
                                    adder_i_dv    <= '1';
                                else
                                    -- Case 2
                                    adder_input_1 <= U_reg;
                                    adder_input_2 <= '0' & r_B;
                                    adder_i_dv    <= '1';
                                end if;
                            end if;
                        else
                            adder_i_dv <= '0';
                        end if;

                    when MONPRO_CASE_123 =>
                        if (adder_o_dv = '1') then
                            U_reg <= adder_output(DATA_SIZE+1 downto 1);
                            r_A <= '0' & r_A(DATA_SIZE - 1 downto 1);
                            cnt_i <= cnt_i + 1;

                            if (cnt_i = (DATA_SIZE - 1)) then
                                if (adder_output(DATA_SIZE+1 downto 1) >= ('0' & r_N)) then
                                    adder_input_1 <= adder_output(DATA_SIZE+1 downto 1);
                                    adder_input_2 <= '0' & r_M;
                                    adder_i_dv    <= '1';
                                else 
                                    adder_i_dv    <= '0';
                                end if;
                            else
                                if (w_A_i = '1' and w_is_odd = '1') then
                                    adder_input_1 <= adder_output(DATA_SIZE+1 downto 1);
                                    adder_input_2 <= B_N_sum_reg;
                                    adder_i_dv    <= '1';
                                elsif (w_A_i = '1' and w_is_odd = '0') then
                                    adder_input_1 <= adder_output(DATA_SIZE+1 downto 1);
                                    adder_input_2 <= '0' & r_B;
                                    adder_i_dv    <= '1';
                                elsif (w_A_i = '0' and w_is_odd = '1') then
                                    adder_input_1 <= adder_output(DATA_SIZE+1 downto 1);
                                    adder_input_2 <= '0' & r_N;
                                    adder_i_dv    <= '1';
                                else
                                    adder_i_dv <= '0';
                                end if;
                            end if;
                        else
                            adder_i_dv <= '0';
                        end if;

                    when MONPRO_CASE4 =>
                        -- Next state signals
                        if (cnt_i = (DATA_SIZE - 1)) then
                            if ('0' & U_reg(DATA_SIZE downto 0) >= ('0' & r_N)) then
                                adder_input_1 <= '0' & U_reg(DATA_SIZE downto 1);
                                adder_input_2 <= '0' & r_M;
                                adder_i_dv    <= '1';
                            else
                                adder_i_dv <= '0';
                            end if;
                        else
                            if (w_A_i = '1' and (U_reg(1) xor w_A_and_B) = '1') then
                                adder_input_1 <= '0' & U_reg(DATA_SIZE downto 1);
                                adder_input_2 <= B_N_sum_reg;
                                adder_i_dv <= '1';
                            elsif (w_A_i = '1' and (U_reg(1) xor w_A_and_B) = '0') then
                                adder_input_1 <= '0' & U_reg(DATA_SIZE downto 1);
                                adder_input_2 <= '0' & r_B;
                                adder_i_dv <= '1';
                            elsif (w_A_i = '0' and (U_reg(1) xor w_A_and_B) = '1') then
                                adder_input_1 <= '0' & U_reg(DATA_SIZE downto 1);
                                adder_input_2 <= '0' & r_N;
                                adder_i_dv <= '1';
                            else
                                adder_i_dv <= '0';
                            end if;
                        end if;

                        U_reg <= '0' & U_reg(DATA_SIZE downto 1);
                        r_A <= '0' & r_A(DATA_SIZE - 1 downto 1);
                        cnt_i <= cnt_i + 1;

                    when MONPRO_LAST_SUB => 
                        if (adder_o_dv = '1') then
                            U_reg <= adder_output(DATA_SIZE downto 0);
                        end if;
                        adder_i_dv <= '0';

                    when MONPRO_DONE =>
                        o_U <= U_reg(DATA_SIZE-1 downto 0);
                        o_valid <= '1';

                    when others =>
                        U_reg <= U_reg;
                        o_U <= (others => '0');
                        o_valid <= '0';
                end case;
            end if;
        end if;
    end process;

    w_A_i     <= r_A(1);
    w_B_0     <= r_B(0);
    w_A_and_B <= w_A_i and w_B_0;
    w_U_0     <= adder_output(1);
    w_is_odd  <= w_A_and_B xor w_U_0;

end architecture ;

