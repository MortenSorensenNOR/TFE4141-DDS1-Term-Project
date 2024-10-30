library ieee;
use ieee.std_logic_1164.all;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC;
        ready_in	: out STD_LOGIC;    -- We are ready for a new message

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key_e_d 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );

        -- Precomputed input data
        r           : in STD_LOGIC_VECTOR (C_block_size-1 downto 0);
        r_square    : in STD_LOGIC_VECTOR (C_block_size-1 downto 0);

		--ouput controll
        ready_out	: in STD_LOGIC;     -- The output interface is ready for a new message
		valid_out	: out STD_LOGIC;

		--output data
		msg_out 	: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--key_n
		key_n 	    : in STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC;
	);
end exponentiation;

architecture expBehave of exponentiation is
    -- State
    type state_t is (IDLE, COMPUTE_M_BAR, COMPUTING_X_BAR, COMPUTING_EXPONENT, COMPUTE_X, DONE);
    signal current_state : state_t := IDLE;
    signal next_state : state_t := IDLE;

    -- Iteration counter
    signal i : integer range 0 to 256 := 256;

    -- Shift register for key_e_d
    signal r_key_e_d : STD_LOGIC_VECTOR (C_block_size-1 downto 0);

    -- Data registers
    signal x_bar : STD_LOGIC_VECTOR (C_block_size-1 downto 0);
    signal M_bar : STD_LOGIC_VECTOR (C_block_size-1 downto 0);
    
    signal x : STD_LOGIC_VECTOR (C_block_size-1 downto 0);

    -- Save the r_square value
    signal r_r_square : STD_LOGIC_VECTOR (C_block_size-1 downto 0);

    -- MonPro signals
    signal mon_pro_ready : STD_LOGIC; 
    signal mon_pro_done  : STD_LOGIC;
    signal mon_pro_start : STD_LOGIC;

    -- MonPro input data signals
    signal mon_pro_A : STD_LOGIC_VECTOR (C_block_size-1 downto 0);
    signal mon_pro_B : STD_LOGIC_VECTOR (C_block_size-1 downto 0);
    signal mon_pro_key_n : STD_LOGIC_VECTOR (C_block_size-1 downto 0);

    -- MonPro output data signals
    signal mon_pro_u : STD_LOGIC_VECTOR (C_block_size-1 downto 0);

    -- MonPro Combinational signals (input and output from combinational computation block)
    signal mon_pro_comb_A_in : STD_LOGIC_VECTOR (C_block_size downto 0);
    signal mon_pro_comb_B_in : STD_LOGIC_VECTOR (C_block_size downto 0);
    signal mon_pro_comb_N_in : STD_LOGIC_VECTOR (C_block_size downto 0);
    signal mon_pro_comb_U_in : STD_LOGIC_VECTOR (C_block_size downto 0);
    signal mon_pro_comb_U_out : STD_LOGIC_VECTOR (C_block_size downto 0);
    signal mon_pro_comb_mux_x : STD_LOGIC;
    signal mon_pro_comb_mux_y : STD_LOGIC;
    signal mon_pro_comb_mux_z : STD_LOGIC;

begin

    u_mon_pro_fsm : entity work.monpro_fsm_v2(behavioral_v2)
    generic map (
        DATA_SIZE => C_block_size + 1
    )
    port map (
        clk => clk,
        rst => ~reset_n,

        start => mon_pro_start,
        ready => mon_pro_ready,
        valid => mon_pro_done,

        A_in => mon_pro_A,
        B_in => mon_pro_B,
        N_in => mon_pro_key_n,
        result => mon_pro_u,

        -- MonPro Comb signals
        A_out => mon_pro_comb_A_in,
        B_out => mon_pro_comb_B_in,
        N_out => mon_pro_comb_N_in,
        U_out => mon_pro_comb_U_in,
        Unp1_in => mon_pro_comb_U_out,
        x => mon_pro_comb_mux_x,
        y => mon_pro_comb_mux_y,
        z => mon_pro_comb_mux_z
    );

    u_mon_pro_comb: entity work.monpro_comb(behavioral)
    generic map (
        DATA_SIZE => C_block_size + 1
    )
    port map (
        B => mon_pro_comb_B_in,
        N => mon_pro_comb_N_in,
        Un => mon_pro_comb_U_in,
        Unp1 => mon_pro_comb_U_out,
        n_b_mux => mon_pro_comb_mux_x,
        bypass_mux => mon_pro_comb_mux_y,
        srl_mux => mon_pro_comb_mux_z,
    );
    
    -- State
    p_state_transition: process (clk) is begin
        if rising_edge(clk) then
            if reset_n = '0' then
                current_state <= IDLE;
                i <= 256;
            else then
                current_state <= next_state;
            end if;
        end if;
    end process p_state_transition;

    -- Next state logic
    p_next_state_logic: process (all) is begin
        next_state <= current_state;

        case current_state is 
            when IDLE => 
                if valid_in = '1' then
                    next_state <= COMPUTE_M_BAR;
                end if;

            when COMPUTE_M_BAR => 
                if mon_pro_done = '1' then
                    next_state <= COMPUTING_X_BAR;
                end if;

            when COMPUTING_X_BAR =>
                if mon_pro_done = '1' then
                    if r_key_e_d[C_block_size-1] = '1' then
                        next_state <= COMPUTING_EXPONENT;
                    else then
                        -- i is not yet decremented, so use 1 instead of 0
                        if i = 1 then
                            next_state <= COMPUTE_X;
                        else then
                            next_state <= COMPUTING_X_BAR;
                        end if;
                    end if;
                end if;

            when COMPUTING_EXPONENT => 
                if mon_pro_done then
                    -- i has been decremented now
                    if i = '0' then
                        next_state <= COMPUTE_X;
                    else then
                        next_state <= COMPUTING_X_BAR;
                    end if;
                end if;

            when COMPUTE_X =>
                next_state <= DONE;

            when DONE =>
                if ready_out then
                    next_state <= IDLE;
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process p_next_state_logic;

    -- Assign signals and such based on state
    p_signals: process (clk) is begin
        if rising_edge(clk) then
            if reset_n = '0' then
                i <= 256;

                -- Reset data signals
                M_bar <= (others => '0');
                x_bar <= (others => '0');
                r_r_square <= (others => '0');

                mon_pro_key_n <= (others => '0');
                mon_pro_A <= (others => '0');
                mon_pro_B <= (others => '0');

                -- Reset signals
                mon_pro_start <= '0';

                -- Reset output signals
                valid_out <= '0';

            else then
                case current_state is 
                    when IDLE => 
                        -- Reset iteration counter
                        i <= 256;

                        -- Signals
                        mon_pro_start <= '0';
                        valid_out <= '0';

                        -- Data
                        if valid_in = '1' then
                            M_bar <= message;       -- Assign start value for M, will be used to compute M_bar
                            x_bar <= r;             -- Start value is r mod n
                            r_r_square <= r_square; -- Save for later
                            r_key_e_d  <= key_e_d;

                            mon_pro_key_n <= key_n; -- Wont change during RSA compute
                        end if;

                    when COMPUTE_M_BAR =>
                        if mon_pro_done = '1' then
                            M_bar <= mon_pro_u;
                            mon_pro_start <= '0';
                        elsif mon_pro_ready = '1' then
                            mon_pro_A <= M_bar;
                            mon_pro_B <= r_r_square;
                            mon_pro_start <= '1';
                        else then
                            mon_pro_start <= '0';
                        end if;
        
                    when COMPUTING_X_BAR => 
                        if mon_pro_done = '1' then
                            i <= i - 1;
                            x_bar <= mon_pro_u;
                            mon_pro_start <= '0';

                            -- Shift register for exponent
                            r_key_e_d <= r_key_e_d(C_block_size - 2 downto 0) & '0';

                        elsif mon_pro_ready = '1' then
                            mon_pro_A <= x_bar;
                            mon_pro_B <= x_bar;
                            mon_pro_start <= '1';
                        else then
                            mon_pro_start <= '0';
                        end if;

                    when COMPUTING_EXPONENT => 
                        if mon_pro_done = '1' then
                            x_bar <= mon_pro_u;
                            mon_pro_start <= '0';
                        elsif mon_pro_ready = '1' then
                            mon_pro_A <= M_bar;
                            mon_pro_B <= x_bar;
                            mon_pro_start <= '1';
                        else then
                            mon_pro_start <= '0';
                        end if;

                    when COMPUTE_X => 
                        if mon_pro_done = '1' then
                            x <= mon_pro_u;
                            mon_pro_start <= '0';
                        elsif mon_pro_ready = '1' then
                            mon_pro_A <= x_bar;

                            -- Assign a 1 to B port
                            mon_pro_B <= (others => '0');
                            mon_pro_B(0) <= '1';
                                
                            mon_pro_start <= '1';
                        else then
                            mon_pro_start <= '0';
                        end if;

                    when DONE => 
                        valid_out <= '1';        
                        msg_out <= x;

                    when others =>
                        i <= 256;
                        mon_pro_start <= '0';
                        valid_out <= '0';        
                end case;
            end if;
        end if;
    end process p_signals;

    -- Assign output signals
    ready_in <= (current_state = IDLE);

end expBehave;
