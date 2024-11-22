----------------------------------------------------------------------
-- File : uvvm_monpro.vhd
-- Author : Corentin MION
-- Creation : Wed. 06 Nov 2024 17h00m12s 
-- Descritpion : UVVM (vhdl-2008) Testbench for heavy MonPro testing
-- Comments :
----------------------------------------------------------------------

library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

library std;
    use std.env.all;
    use std.textio.all;

library uvvm_util;
  context uvvm_util.uvvm_util_context;

entity uvvm_monpro is
end uvvm_monpro ; 

architecture behavioral of uvvm_monpro is
    -----------------------------------------------------------------
    -- CONSTANTS
    -----------------------------------------------------------------
    -- TEST Related
    constant VECTORS_TESTING_FILE : string := "C:\Users\cmion\Documents\NTNU\TFE4141-DDS1-Term-Project\integration_kit\Exponentiation\testing_files\raw_monpro_new_test_data.txt";
    constant NB_VAL : integer := 5;    -- number of column value per vectors
    constant C_CLK_PERIOD : time := 10 ns;    -- clock period
    -- DUT related
    constant DATA_SIZE : integer := 256;

    -----------------------------------------------------------------
    -- SIGNALS
    -----------------------------------------------------------------
    signal clk : std_logic := '0';
    signal srstn, srst : std_logic := '0';
    signal clock_ena : boolean := false;

    -- DUT related
    signal dut_start : std_logic := '0';
    signal dut_ready : std_logic;
    signal dut_o_valid : std_logic;

    signal dut_i_A : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
    signal dut_i_B : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
    signal dut_i_N : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
    signal dut_o_U : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
    signal dut_i_M : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');

    
begin
    ---------------------------------------
    -- DUT : Monpro_sv
    ---------------------------------------
    DUT : entity work.monpro_new(behavioral)
    generic map (
        DATA_SIZE => DATA_SIZE
    )
    port map (
        clk => clk,
        srstn => srstn,
    
        start => dut_start,
        ready => dut_ready,
        o_valid => dut_o_valid,
    
        i_A => dut_i_A,
        i_B => dut_i_B,
        i_N => dut_i_N,
        i_M => dut_i_M,
        o_U => dut_o_U
    );

    -----------------------------------------------------------------------------
    -- Clock Generator
    -----------------------------------------------------------------------------
    clock_generator(clk, clock_ena, C_CLK_PERIOD, "MONPRO TB clock");

    -----------------------------------------------------------------------------
    -- ResetN generation
    -----------------------------------------------------------------------------
    srstn <= not(srst);

    -----------------------------------------------------------------------------
    -- Main testing process
    -----------------------------------------------------------------------------
    p_main : process
        constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;
        --type t_integer_array is array(integer range <> )  of integer;
        type t_integer_array is array(integer range <> )  of std_logic_vector (DATA_SIZE-1 downto 0);

        file test_vector            : text open read_mode is VECTORS_TESTING_FILE; -- File declaration
        variable row                : line; -- line declaration
        variable v_data_read        : t_integer_array(0 to NB_VAL-1);
        variable v_num_vect         : integer := 0;
        variable v_excepted_result : std_logic_vector (DATA_SIZE-1 downto 0) := (OTHERS => '0');
    begin
        --------------------------------------------------------------
        report_global_ctrl(VOID);
        report_msg_id_panel(VOID);
        enable_log_msg(ALL_MESSAGES);
        log(ID_LOG_HDR, "Start Simulation of TB for IRQC", C_SCOPE);
        --------------------------------------------------------------
        --set_inputs_passive(VOID);
        clock_ena <= true;
        --------------------------------------------------------------
        log("Reset Triggered");
        gen_pulse(srst, 10 * C_CLK_PERIOD, "Pulsed reset-signal - active for 10T");
        --------------------------------------------------------------
        


        --------------------------------------------------------------
        while (not endfile(test_vector)) loop
            --log("Waiting for Ready signal");
            --check_value(dut_ready, '1', ERROR, "Ready should be = '1' in IDLE state");
            --await_value(dut_ready, '1', 0 ns, 2* C_CLK_PERIOD, ERROR, "Ready should be ='1' before assigning '1' to start");

            ---------------------------------
            -- READING MULTI-VALUES VECTOR --
            wait until rising_edge(clk);
            v_num_vect := v_num_vect + 1;
            readline(test_vector,row);
            for i in 0 to NB_VAL-1 loop
                hread(row,v_data_read(i));
            end loop;
            ---- Splitting test vector ----
            --dut_i_A <= std_logic_vector(to_unsigned(v_data_read(0), DATA_SIZE));
            --dut_i_B <= std_logic_vector(to_unsigned(v_data_read(1), DATA_SIZE));
            --dut_i_N <= std_logic_vector(to_unsigned(v_data_read(2), DATA_SIZE));
            --v_excepted_result := std_logic_vector(to_unsigned(v_data_read(3), DATA_SIZE));
            dut_i_A <= v_data_read(0);
            dut_i_B <= v_data_read(1);
            dut_i_N <= v_data_read(2);
            v_excepted_result := v_data_read(3);
            dut_i_M <= v_data_read(4);
            ----- Logging read values -----
            log("~~~~ TEST VECTOR N°" & to_string(v_num_vect) & " ~~~~");
            --log("-> Read A : " & integer'image(v_data_read(0)));
            --log("-> Read B : " & integer'image(v_data_read(1)));
            --log("-> Read N : " & integer'image(v_data_read(2)));
            --log("-> Read v_excepted_result : " & to_string(v_data_read(3)));
            --log("-> Read A : " & integer'image(v_data_read(0)));
            --log("-> Read B : " & integer'image(v_data_read(1)));
            --log("-> Read N : " & integer'image(v_data_read(2)));
            --log("-> Read v_excepted_result : " & to_string(v_data_read(3)));
            ---------------------------------    

            
            log("Waiting for Ready signal");
            await_value(dut_ready, '1', 0 ns, 5* C_CLK_PERIOD, ERROR, "Checking that Ready='1' BEFORE assigning '1' to start");
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            gen_pulse(dut_start, 2 * C_CLK_PERIOD, "Pulsed start-signal - active for 1T");
            await_value(dut_ready, '0', 0 ns, 5* C_CLK_PERIOD, ERROR, "Checking that Ready='0' AFTER receiving start='1'");

            
            -- Waiting valid signal .....
            log("Waiting valid signal");
            await_value(dut_o_valid, '1', 0 ns, 6*1024* C_CLK_PERIOD, ERROR, "Waiting for Valid='1' (until 6*1024*T) to get the result");

            check_value(dut_o_U, v_excepted_result, ERROR, "Comparing wanted result with DUT result");
             
        end loop;

        wait for 1000 ns;             -- to allow some time for completion
        report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
        log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

        std.env.stop;
    end process p_main;

end architecture ;
