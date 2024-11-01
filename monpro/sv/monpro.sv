`timescale 1ns / 1ps

typedef enum logic [2:0] {
    MONPRO_IDLE,
    MONPRO_LOAD,
    MONPRO_CASE1A,
    MONPRO_CASE1B,
    MONPRO_CASE2,
    MONPRO_CASE3,
    MONPRO_CASE4,
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
    logic w_A_i;
    logic w_B_0;
    logic w_U_0;
    logic w_A_and_B;
    logic w_is_odd;
    /* verilator lint_on UNUSED */

    // Combinational
    logic unsigned [DATAWIDTH:0] adder_input;
    logic unsigned [DATAWIDTH:0] adder_result;
    logic unsigned [DATAWIDTH:0] adder_bypass_result;
    logic unsigned [DATAWIDTH:0] monpro_comb_result;

    logic adder_input_mux_select, adder_bypass_mux_select, adder_result_shift_mux_select;

    always_comb begin
        // Select adder input
        if (adder_input_mux_select) begin
            adder_input = {1'b0, r_N};
        end else begin
            adder_input = {1'b0, r_B};
        end

        adder_result = U_reg + adder_input;

        if (adder_bypass_mux_select) begin
            adder_bypass_result = U_reg;
        end else begin
            adder_bypass_result = adder_result;
        end

        if (adder_result_shift_mux_select) begin
            monpro_comb_result = adder_bypass_result;
        end else begin
            monpro_comb_result = adder_bypass_result >> 1;
        end
    end

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

        case (current_state)
            MONPRO_IDLE: begin
                if (start) begin
                    next_state = MONPRO_LOAD;
                end else begin
                    ready = 1;
                end
            end

            MONPRO_LOAD: begin
                if (i_cnt == DATAWIDTH) begin
                    next_state = MONPRO_DONE;
                end else begin
                    if (w_A_i & w_is_odd) begin
                        next_state = MONPRO_CASE1A;
                    end else if (w_A_i & ~w_is_odd) begin
                        next_state = MONPRO_CASE2;
                    end else if (~w_A_i & w_is_odd) begin
                        next_state = MONPRO_CASE3;
                    end else begin
                        next_state = MONPRO_CASE4;
                    end
                end
            end

            MONPRO_CASE1A: begin
                next_state = MONPRO_CASE1B;
            end

            MONPRO_CASE1B: begin
                next_state = MONPRO_LOAD;
            end

            MONPRO_CASE2: begin
                next_state = MONPRO_LOAD;
            end

            MONPRO_CASE3: begin
                next_state = MONPRO_LOAD;
            end

            MONPRO_CASE4: begin
                next_state = MONPRO_LOAD;
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
                    // U_reg <= monpro_comb_result;
                end

                MONPRO_LOAD: begin
                    if (w_A_i & w_is_odd) begin
                        adder_input_mux_select <= 0;
                        adder_bypass_mux_select <= 0;
                        adder_result_shift_mux_select <= 1;
                    end else if (w_A_i & ~w_is_odd) begin
                        adder_input_mux_select <= 0;
                        adder_bypass_mux_select <= 0;
                        adder_result_shift_mux_select <= 0;
                    end else if (~w_A_i & w_is_odd) begin
                        adder_input_mux_select <= 1;
                        adder_bypass_mux_select <= 0;
                        adder_result_shift_mux_select <= 0;
                    end else begin
                        adder_input_mux_select <= 1;
                        adder_bypass_mux_select <= 1;
                        adder_result_shift_mux_select <= 0;
                    end
                    i_cnt <= i_cnt + 1;
                    r_A <= {1'b0, r_A[DATAWIDTH-1:1]};
                end

                MONPRO_CASE1A: begin
                    U_reg <= monpro_comb_result;
                    adder_input_mux_select <= 1;
                    adder_bypass_mux_select <= 0;
                    adder_result_shift_mux_select <= 0;
                end

                MONPRO_CASE1B: begin
                    U_reg <= monpro_comb_result;
                end

                MONPRO_CASE2: begin
                    U_reg <= monpro_comb_result;
                end

                MONPRO_CASE3: begin
                    U_reg <= monpro_comb_result;
                end

                MONPRO_CASE4: begin
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

    assign w_A_i = r_A[0];
    assign w_B_0 = r_B[0];
    assign w_U_0 = U_reg[0];
    assign w_A_and_B = w_A_i & w_B_0;
    assign w_is_odd = w_U_0 ^ (w_A_and_B);

endmodule
