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
        key_n 	    : in STD_LOGIC_VECTOR(C_block_size-1 downto 0);

        -- Precomputed input data
        r           : in STD_LOGIC_VECTOR (C_block_size-1 downto 0);
        r_square    : in STD_LOGIC_VECTOR (C_block_size-1 downto 0);

		--ouput controll
        ready_out	: in STD_LOGIC;     -- The output interface is ready for a new message
		valid_out	: out STD_LOGIC;

		--output data
		msg_out 	: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC
	);
end exponentiation;

architecture expBehave of exponentiation is
    -- State
    type state_t is (
        IDLE, 
        COMPUTE_M_BAR, 
        COMPUTING_X_BAR, 
        COMPUTING_EXPONENT, 
        COMPUTE_X, 
        DONE,
        WAIT_DONE_SEND
    );
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
    signal mon_pro_ready    : STD_LOGIC := '0'; 
    signal mon_pro_o_valid  : STD_LOGIC := '0';
    signal mon_pro_start    : STD_LOGIC := '0';

    -- MonPro input data signals
    signal mon_pro_A : STD_LOGIC_VECTOR (C_block_size-1 downto 0);
    signal mon_pro_B : STD_LOGIC_VECTOR (C_block_size-1 downto 0);
    signal mon_pro_key_n : STD_LOGIC_VECTOR (C_block_size-1 downto 0);

    -- MonPro output data signals
    signal mon_pro_u : STD_LOGIC_VECTOR (C_block_size-1 downto 0);
    
    -- Internal Valid register
    signal r_valid_out : STD_LOGIC := '0';
begin

    u_mon_pro : entity work.monpro(behavioral)
    generic map (
        DATA_SIZE => C_block_size
    )
    port map (
        clk => clk,
        srstn => reset_n,

        start => mon_pro_start,
        ready => mon_pro_ready,
        o_valid => mon_pro_o_valid,

        i_A => mon_pro_A,
        i_B => mon_pro_B,
        i_N => mon_pro_key_n,
        o_U => mon_pro_u
    );

    -- State
    p_state_transition: process (clk) is begin
        if rising_edge(clk) then
            if reset_n = '0' then
                current_state <= IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process p_state_transition;

    -- Next state logic
    p_next_state_logic: process (current_state, valid_in, mon_pro_o_valid, ready_out) is begin
        next_state <= current_state;
        ready_in <= '0';

        case current_state is 
            when IDLE => 
                if valid_in = '1' then
                    next_state <= COMPUTE_M_BAR;
                end if;
                ready_in <= '1';

            when COMPUTE_M_BAR => 
                if mon_pro_o_valid = '1' then
                    next_state <= COMPUTING_X_BAR;
                end if;

            when COMPUTING_X_BAR =>
                if mon_pro_o_valid = '1' then
                    if r_key_e_d(C_block_size-1) = '1' then
                        next_state <= COMPUTING_EXPONENT;
                    else
                        -- i is not yet decremented, so use 1 instead of 0
                        if i = 1 then
                            next_state <= COMPUTE_X;
                        else
                            next_state <= COMPUTING_X_BAR;
                        end if;
                    end if;
                end if;

            when COMPUTING_EXPONENT => 
                if mon_pro_o_valid = '1' then
                    -- i has been decremented now
                    if i = 0 then
                        next_state <= COMPUTE_X;
                    else
                        next_state <= COMPUTING_X_BAR;
                    end if;
                end if;

            when COMPUTE_X =>
                if mon_pro_o_valid = '1' then
                    next_state <= DONE;
                end if;
                
            when DONE =>
                if ready_out = '1' then
                    next_state <= WAIT_DONE_SEND;
                end if;

            when WAIT_DONE_SEND => 
                if ready_out = '1' then
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
                r_valid_out <= '0';
                
                x <= (others => '0');

            else
                case current_state is 
                    when IDLE => 
                        -- Reset iteration counter
                        i <= 256;

                        -- Signals
                        mon_pro_start <= '0';
                        r_valid_out <= '0';
                        
                        x <= (others => '0');

                        -- Data
                        if valid_in = '1' then
                            M_bar <= message;       -- Assign start value for M, will be used to compute M_bar
                            x_bar <= r;             -- Start value is r mod n
                            r_r_square <= r_square; -- Save for later
                            r_key_e_d  <= key_e_d;

                            mon_pro_key_n <= key_n; -- Wont change during RSA compute
                        end if;

                    when COMPUTE_M_BAR =>
                        if mon_pro_o_valid = '1' then
                            M_bar <= mon_pro_u;
                            mon_pro_start <= '0';
                        elsif mon_pro_ready = '1' then
                            mon_pro_A <= M_bar;
                            mon_pro_B <= r_r_square;
                            mon_pro_start <= '1';
                        else
                            mon_pro_start <= '0';
                        end if;
        
                    when COMPUTING_X_BAR => 
                        if mon_pro_o_valid = '1' then
                            i <= i - 1;
                            x_bar <= mon_pro_u;
                            mon_pro_start <= '0';

                            -- Shift register for exponent
                            r_key_e_d <= r_key_e_d(C_block_size - 2 downto 0) & '0';

                        elsif mon_pro_ready = '1' then
                            mon_pro_A <= x_bar;
                            mon_pro_B <= x_bar;
                            mon_pro_start <= '1';
                        else
                            mon_pro_start <= '0';
                        end if;

                    when COMPUTING_EXPONENT => 
                        if mon_pro_o_valid = '1' then
                            x_bar <= mon_pro_u;
                            mon_pro_start <= '0';
                        elsif mon_pro_ready = '1' then
                            mon_pro_A <= M_bar;
                            mon_pro_B <= x_bar;
                            mon_pro_start <= '1';
                        else
                            mon_pro_start <= '0';
                        end if;

                    when COMPUTE_X => 
                        if mon_pro_o_valid = '1' then
                            x <= mon_pro_u;
                            mon_pro_start <= '0';
                        elsif mon_pro_ready = '1' then
                            mon_pro_A <= x_bar;

                            -- Assign a 1 to B port
                            mon_pro_B <= (others => '0');
                            mon_pro_B(0) <= '1';
                                
                            mon_pro_start <= '1';
                        else
                            mon_pro_start <= '0';
                        end if;

                    when DONE => 
                        if (ready_out) then
                            r_valid_out <= '1';
                        else 
                            r_valid_out <= '0';
                        end if;
                        mon_pro_start <= '0';     
                        msg_out <= x;

                    when WAIT_DONE_SEND =>
                        if ready_out = '1' then
                            r_valid_out <= '0';
                        end if;

                    when others =>
                        i <= 256;
                        mon_pro_start <= '0';
                        r_valid_out <= '0';        
                end case;
            end if;
        end if;
    end process p_signals;

    -- Assign valid_out based on r_valid_out and ready_out
    valid_assign: process (current_state, ready_out, r_valid_out) is begin
        case current_state is
            when IDLE =>
                valid_out <= r_valid_out and not ready_out;
                
            when DONE =>
                valid_out <= r_valid_out;
            
            when WAIT_DONE_SEND =>
                valid_out <= r_valid_out;
            
            when others => 
                valid_out <= r_valid_out;
        end case;
    end process valid_assign;

end expBehave;

