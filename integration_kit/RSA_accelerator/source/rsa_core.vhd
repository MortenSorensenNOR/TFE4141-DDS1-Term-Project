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
entity rsa_core is
	generic (
		-- Users to add parameters here
		C_BLOCK_SIZE          : integer := 256
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
		r_square                :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0)
	);
end rsa_core;

architecture rtl of rsa_core is
    signal msgin_last_reg : std_logic := '0';
    signal msgin_last_last_reg: std_logic := '0';
    signal msgout_last_reg : std_logic := '0';
    -- signal r_msgout_last  : std_logic := '0';
begin
	i_exponentiation : entity work.exponentiation
		generic map (
			C_block_size => C_BLOCK_SIZE
		)
		port map (
            valid_in  => msgin_valid ,
            ready_in  => msgin_ready ,

			message   => msgin_data  ,
			key_e_d   => key_e_d     ,
            key_n     => key_n       ,

            r         => r           ,
            r_square  => r_square    ,

			ready_out => msgout_ready,
			valid_out => msgout_valid,

			msg_out   => msgout_data ,

			clk       => clk         ,
			reset_n   => reset_n
		);

    delay_msgout_last_proc: process (clk) is begin
        if rising_edge(clk) then
            if (reset_n = '0') then
                msgin_last_reg <= '0';
                msgin_last_last_reg <= '0';
                msgout_last_reg <= '0';
                msgout_last <= '0';
            else
            
                if msgin_ready = '1' then
                    msgin_last_reg <= msgin_last;
                end if;
                
                if msgout_ready = '1' then
                    msgout_last <= msgin_last_reg;
                end if;
            end if;
        end if;
    end process delay_msgout_last_proc;
	rsa_status   <= (others => '0');
end rtl;
