`timescale 1ns / 1ps

typedef enum logic [3:0] {
    MONPRO_IDLE,
    MONPRO_COMPUTE_B_N,
    // MONPRO_LOAD,
    MONPRO_CASE1,
    MONPRO_CASE2,
    MONPRO_CASE3,
    MONPRO_CASE4,
    MONPRO_LAST_SUB,
    MONPRO_DONE
} monpro_state_t;

module monpro #(
    parameter unsigned DATAWIDTH = 64
    ) (
    input logic clk,
    input logic rstn,

    input logic start,
    output logic ready,
    output logic o_valid,

    input logic unsigned [DATAWIDTH-1:0] i_A,
    input logic unsigned [DATAWIDTH-1:0] i_B,
    input logic unsigned [DATAWIDTH-1:0] i_N,
    output logic unsigned [DATAWIDTH-1:0] o_U
    );

    // Iteration counter
    logic unsigned [$clog2(DATAWIDTH):0] i_cnt;

    // Data registers
    logic unsigned [DATAWIDTH-1:0] r_A;
    logic unsigned [DATAWIDTH-1:0] r_B;
    logic unsigned [DATAWIDTH-1:0] r_N;

    logic unsigned [DATAWIDTH:0] U_reg;
    /* verilator lint_off UNUSED */
    logic unsigned [DATAWIDTH:0] B_N_sum_reg;
    /* verilator lint_on UNUSED */

    /* verilator lint_off UNUSED */
    logic w_A_i;
    logic w_B_0;
    logic w_U_0;
    logic w_A_and_B;
    logic w_is_odd;

    logic w_A_i_next;
    logic w_B_0_next;
    logic w_U_0_next;
    logic w_A_and_B_next;
    logic w_is_odd_next;
    /* verilator lint_on UNUSED */

    // Combinational
    logic unsigned [DATAWIDTH:0] adder_input_1;
    logic unsigned [DATAWIDTH:0] adder_input_2;
    logic unsigned [DATAWIDTH:0] adder_result;
    logic unsigned [DATAWIDTH:0] adder_bypass_result;
    logic unsigned [DATAWIDTH:0] monpro_comb_result;

    logic alu_sub_mode = 0;
    logic adder_input_mux_select_1 = 0;
    logic [1:0] adder_input_mux_select_2 = 2'b00;
    logic adder_bypass_mux_select = 0;
    logic adder_result_shift_bypass = 0;

    always_comb begin
        // Select adder input
        if (adder_input_mux_select_1) begin
            adder_input_1 = {1'b0, r_B};
        end else begin
            adder_input_1 = U_reg;
        end

        case (adder_input_mux_select_2)
            2'b00: begin
                adder_input_2 = {1'b0, r_B};
            end

            2'b01: begin
                adder_input_2 = {1'b0, r_N};
            end

            2'b10: begin
                adder_input_2 = B_N_sum_reg;
            end

            default: begin
                adder_input_2 = {1'b0, r_B};
            end
        endcase

        if (alu_sub_mode) begin
            adder_result = adder_input_1 - adder_input_2;
        end else begin
            adder_result = adder_input_1 + adder_input_2;
        end

        if (adder_bypass_mux_select) begin
            adder_bypass_result = U_reg;
        end else begin
            adder_bypass_result = adder_result;
        end

        if (adder_result_shift_bypass) begin
            monpro_comb_result = adder_bypass_result;
        end else begin
            monpro_comb_result = adder_bypass_result >> 1;
        end
    end

    // Next state determination task


    // State
    monpro_state_t current_state = MONPRO_IDLE, next_state = MONPRO_IDLE;
    always_ff @(posedge clk) begin
        if (~rstn) begin
            current_state <= MONPRO_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;
        ready = 0;

        w_A_i = r_A[0];
        w_B_0 = r_B[0];
        w_U_0 = U_reg[0];
        w_A_and_B = w_A_i & w_B_0;
        w_is_odd = w_U_0 ^ (w_A_and_B);

        w_A_i_next = r_A[1];
        w_B_0_next = r_B[0];
        w_U_0_next = monpro_comb_result[0];
        w_A_and_B_next = w_A_i_next & w_B_0_next;
        w_is_odd_next = w_U_0_next ^ (w_A_and_B_next);

        case (current_state)
            MONPRO_IDLE: begin
                if (start) begin
                    next_state = MONPRO_COMPUTE_B_N;
                end else begin
                    ready = 1;
                end
            end

            MONPRO_COMPUTE_B_N: begin
                if (w_A_i & w_is_odd) begin
                    next_state = MONPRO_CASE1;
                end else if (w_A_i & ~w_is_odd) begin
                    next_state = MONPRO_CASE2;
                end else if (~w_A_i & w_is_odd) begin
                    next_state = MONPRO_CASE3;
                end else begin
                    next_state = MONPRO_CASE4;
                end
            end

            MONPRO_CASE1, MONPRO_CASE2, MONPRO_CASE3, MONPRO_CASE4: begin
                if (i_cnt == DATAWIDTH - 1) begin
                    if (monpro_comb_result >= {1'b0, r_N}) begin
                        next_state = MONPRO_LAST_SUB;
                    end else begin
                        next_state = MONPRO_DONE;
                    end
                end else begin
                    if (w_A_i_next & w_is_odd_next) begin
                        next_state = MONPRO_CASE1;
                    end else if (w_A_i_next & ~w_is_odd_next) begin
                        next_state = MONPRO_CASE2;
                    end else if (~w_A_i_next & w_is_odd_next) begin
                        next_state = MONPRO_CASE3;
                    end else begin
                        next_state = MONPRO_CASE4;
                    end
                end
            end

            MONPRO_LAST_SUB: begin
                next_state = MONPRO_DONE;
            end

            MONPRO_DONE: begin
                next_state = MONPRO_IDLE;
            end

            default: begin
                next_state = MONPRO_IDLE;
            end
        endcase
    end

    // Register results
    always_ff @(posedge clk) begin
        if (~rstn) begin
            i_cnt <= '0;

            r_A <= '0;
            r_B <= '0;
            r_N <= '0;
            U_reg <= '0;

            // Reset output data
            o_U <= '0;
            o_valid <= '0;
        end else begin
            case (current_state)
                MONPRO_IDLE: begin
                    if (start) begin
                        r_A <= i_A;
                        r_B <= i_B;
                        r_N <= i_N;
                        U_reg <= '0;
                    end
                    i_cnt <= '0;

                    // Reset output data
                    o_U <= '0;
                    o_valid <= '0;

                    // Set mux signals for B + N compute
                    alu_sub_mode <= 0;
                    adder_input_mux_select_1 <= 1;
                    adder_input_mux_select_2 <= 2'b01;
                    adder_bypass_mux_select <= 0;
                    adder_result_shift_bypass <= 1;
                end

                MONPRO_COMPUTE_B_N: begin
                    B_N_sum_reg <= monpro_comb_result;
                    if (w_A_i & w_is_odd) begin
                        alu_sub_mode <= 0;
                        adder_input_mux_select_1 <= 0;
                        adder_input_mux_select_2 <= 2'b10;
                        adder_bypass_mux_select <= 0;
                        adder_result_shift_bypass <= 0;
                    end else if (w_A_i & ~w_is_odd) begin
                        alu_sub_mode <= 0;
                        adder_input_mux_select_1 <= 0;
                        adder_input_mux_select_2 <= 2'b00;
                        adder_bypass_mux_select <= 0;
                        adder_result_shift_bypass <= 0;
                    end else if (~w_A_i & w_is_odd) begin
                        alu_sub_mode <= 0;
                        adder_input_mux_select_1 <= 0;
                        adder_input_mux_select_2 <= 2'b01;
                        adder_bypass_mux_select <= 0;
                        adder_result_shift_bypass <= 0;
                    end else begin
                        alu_sub_mode <= 0;
                        adder_input_mux_select_1 <= 0;
                        adder_input_mux_select_2 <= 2'b01;
                        adder_bypass_mux_select <= 1;
                        adder_result_shift_bypass <= 0;
                    end
                end

                MONPRO_CASE1, MONPRO_CASE2, MONPRO_CASE3, MONPRO_CASE4: begin
                    if (i_cnt == DATAWIDTH - 1) begin
                        if (monpro_comb_result >= {1'b0, r_N}) begin
                            alu_sub_mode <= 1;
                            adder_input_mux_select_1 <= 0;
                            adder_input_mux_select_2 <= 2'b01;
                            adder_bypass_mux_select <= 0;
                            adder_result_shift_bypass <= 1;
                        end
                    end else begin
                        if (w_A_i_next & w_is_odd_next) begin
                            alu_sub_mode <= 0;
                            adder_input_mux_select_1 <= 0;
                            adder_input_mux_select_2 <= 2'b10;
                            adder_bypass_mux_select <= 0;
                            adder_result_shift_bypass <= 0;
                        end else if (w_A_i_next & ~w_is_odd_next) begin
                            alu_sub_mode <= 0;
                            adder_input_mux_select_1 <= 0;
                            adder_input_mux_select_2 <= 2'b00;
                            adder_bypass_mux_select <= 0;
                            adder_result_shift_bypass <= 0;
                        end else if (~w_A_i_next & w_is_odd_next) begin
                            alu_sub_mode <= 0;
                            adder_input_mux_select_1 <= 0;
                            adder_input_mux_select_2 <= 2'b01;
                            adder_bypass_mux_select <= 0;
                            adder_result_shift_bypass <= 0;
                        end else begin
                            alu_sub_mode <= 0;
                            adder_input_mux_select_1 <= 0;
                            adder_input_mux_select_2 <= 2'b01;
                            adder_bypass_mux_select <= 1;
                            adder_result_shift_bypass <= 0;
                        end
                        i_cnt <= i_cnt + 1;
                        r_A <= {1'b0, r_A[DATAWIDTH-1:1]};
                    end
                    U_reg <= monpro_comb_result;
                end

                MONPRO_LAST_SUB: begin
                    U_reg <= monpro_comb_result;
                end

                MONPRO_DONE: begin
                    o_U <= U_reg[DATAWIDTH-1:0];
                    o_valid <= '1;
                end

                default: begin
                    o_U <= '0;
                    o_valid <= '0;
                end
            endcase
        end
    end

endmodule
