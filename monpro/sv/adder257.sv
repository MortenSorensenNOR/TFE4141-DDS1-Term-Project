// 257-bit Cary-Save Adder
`timescale 1ns / 1ps

module adder257 (
    input logic clk,
    output logic ready,

    input logic [63:0] i_A[4],
    input logic [63:0] i_B[4],
    input logic i_A_upper,      // Upper 257th bit of A
    input logic i_B_upper,      // Upper 257th bit of B
    input logic i_dv,

    output logic [63:0] o_C[4],
    output logic [1:0] o_C_carry,
    output logic o_dv
    );

    logic carry;
    logic [1:0] iter = '0;

    logic [63:0] C[4] = '{'0, '0, '0, '0};

    always_ff @(posedge clk) begin
        if (i_dv) begin
            iter <= 1;
            C[1] <= '0;
            C[2] <= '0;
            C[3] <= '0;
        end else if (iter != '0) begin
            iter <= iter + 1;
        end

        {carry, C[iter]} <= i_A[iter] + i_B[iter] + {64'b0, carry & (iter[0] | iter[1])};

        if (iter == 2'b11) begin
            o_dv <= 1'b1;
        end else begin
            o_dv <= 1'b0;
        end
    end

    always_comb begin
        o_C_carry = i_A_upper + i_B_upper + carry;
    end

    assign o_C = C;
    assign ready = (iter == 2'b00);
endmodule;
