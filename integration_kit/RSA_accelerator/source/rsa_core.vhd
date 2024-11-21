--------------------------------------------------------------------------------
-- Author       : Oystein Gjermundnes
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018-2019
-- Project      : RSA accelerator
-- License      : This is free and unencumbered software released into the
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose:
--   RSA encryption core template. This core currently computes
--   C = M xor key_n
--
--   Replace/change this module so that it implements the function
--   C = M**key_e mod key_n.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rsa_types.all;


entity rsa_core is
    generic (
        NUM_CORES    : integer := NUM_CORES;
        C_BLOCK_SIZE : integer := C_BLOCK_SIZE;
        ID_WIDTH     : integer := ID_WIDTH
    );
	port (
		-----------------------------------------------------------------------------
		-- Clocks and reset
		-----------------------------------------------------------------------------
		clk                    :  in std_logic;
		reset_n                :  in std_logic;

		-----------------------------------------------------------------------------
		-- Slave msgin interface
		-----------------------------------------------------------------------------
		-- Message that will be sent out is valid
		msgin_valid             : in std_logic;
		-- Slave ready to accept a new message
		msgin_ready             : out std_logic;
		-- Message that will be sent out of the rsa_msgin module
		msgin_data              :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		-- Indicates boundary of last packet
		msgin_last              :  in std_logic;

		-----------------------------------------------------------------------------
		-- Master msgout interface
		-----------------------------------------------------------------------------
		-- Message that will be sent out is valid
		msgout_valid            : out std_logic;
		-- Slave ready to accept a new message
		msgout_ready            :  in std_logic;
		-- Message that will be sent out of the rsa_msgin module
		msgout_data             : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		-- Indicates boundary of last packet
		msgout_last             : out std_logic;

		-----------------------------------------------------------------------------
		-- Interface to the register block
		-----------------------------------------------------------------------------
		key_e_d                 :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		key_n                   :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		rsa_status              : out std_logic_vector(31 downto 0);

		r                       :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		r_square                :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		sub_val_pre             :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0)
	);
end rsa_core;

architecture rtl of rsa_core is

    -- Shared signals to pass data to cores
    signal dispatch_message         : std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    signal dispatch_message_id      : std_logic_vector(ID_WIDTH-1 downto 0);
    signal dispatch_message_last    : std_logic;

    signal core_ready_array         : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_select_array        : std_logic_vector(NUM_CORES-1 downto 0);

    -- Signals to connect to the collector
    signal core_message_out_array       : core_message_array_type;
    signal core_message_id_out_array    : core_message_id_array_type;

    signal collector_ready_array        : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_valid_outs              : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_message_last_out_array  : std_logic_vector(NUM_CORES-1 downto 0);

begin


    -- Instantiate the dispatcher
    dispatcher_inst : entity work.dispatcher
        generic map (
            NUM_CORES    => NUM_CORES,
            C_BLOCK_SIZE => C_BLOCK_SIZE,
            ID_WIDTH     => ID_WIDTH
        )
        port map (
            clk                 => clk,
            reset_n             => reset_n,

            msgin_valid         => msgin_valid,
            msgin_ready         => msgin_ready,
            msgin_data          => msgin_data,
            msgin_last          => msgin_last,


            core_message        => dispatch_message,
            core_message_id     => dispatch_message_id,
            core_message_last   => dispatch_message_last,
            core_select_array   => core_select_array,
            core_ready_array    => core_ready_array
        );

    -- Instantiate the exponentiation core wrappers
    gen_exponentiation_cores : for i in 0 to NUM_CORES-1 generate
        exp_core : entity work.exponentiation
            generic map (
                C_BLOCK_SIZE => C_BLOCK_SIZE,
                ID_WIDTH     => ID_WIDTH
            )
            port map (
                valid_in	    => core_select_array(i),
                ready_in	    => core_ready_array(i),

                message         => dispatch_message,
                message_id      => dispatch_message_id,
                message_last    => dispatch_message_last,
                key_e_d         => key_e_d,
                key_n           => key_n,

                r               => r,
                r_square        => r_square,
                sub_val_pre     => sub_val_pre,

                ready_out       => collector_ready_array(i),
                valid_out       => core_valid_outs(i),

                msg_out         => core_message_out_array(i),
                msg_id_out      => core_message_id_out_array(i),
                msg_last_out    => core_message_last_out_array(i),

                clk             => clk,
                reset_n         => reset_n
            );
    end generate;

    -- Instantiate the collector
    collector_inst : entity work.collector
        generic map (
            NUM_CORES    => NUM_CORES,
            C_BLOCK_SIZE => C_BLOCK_SIZE,
            ID_WIDTH     => ID_WIDTH
        )
        port map (
            clk         => clk,         
            reset_n     => reset_n,

            core_valid_array        => core_valid_outs,
            collector_ready_array   => collector_ready_array,
            core_msg_array          => core_message_out_array,
            core_msg_ids            => core_message_id_out_array,
            core_msg_last           => core_message_last_out_array,

            msgout_valid            => msgout_valid,
            msgout_ready            => msgout_ready,
            msgout_data             => msgout_data,
            msgout_last             => msgout_last
        );



end rtl;

--Old code for my convenience :^)

-- architecture rtl of rsa_core is
--     signal msgin_last_reg : std_logic := '0';
--     signal msgin_last_last_reg: std_logic := '0';
--     signal msgout_last_reg : std_logic := '0';
--     -- signal r_msgout_last  : std_logic := '0';
--begin
-- 	i_exponentiation : entity work.exponentiation
-- 		generic map (
-- 			C_block_size => C_BLOCK_SIZE
-- 		)
-- 		port map (
--             valid_in  => msgin_valid ,
--             ready_in  => msgin_ready ,

-- 			message   => msgin_data  ,
-- 			key_e_d   => key_e_d     ,
--             key_n     => key_n       ,

--             r         => r           ,
--             r_square  => r_square    ,

-- 			ready_out => msgout_ready,
-- 			valid_out => msgout_valid,

-- 			msg_out   => msgout_data ,

-- 			clk       => clk         ,
-- 			reset_n   => reset_n
-- 		);

--     delay_msgout_last_proc: process (clk) is begin
--         if rising_edge(clk) then
--             if (reset_n = '0') then
--                 msgin_last_reg <= '0';
--                 msgin_last_last_reg <= '0';
--                 msgout_last_reg <= '0';
--                 msgout_last <= '0';
--             else
            
--                 if msgin_ready = '1' then
--                     msgin_last_reg <= msgin_last;
--                 end if;
                
--                 if msgout_ready = '1' then
--                     msgout_last <= msgin_last_reg;
--                 end if;
--             end if;
--         end if;
--     end process delay_msgout_last_proc;
-- 	rsa_status   <= (others => '0');
-- end rtl;
