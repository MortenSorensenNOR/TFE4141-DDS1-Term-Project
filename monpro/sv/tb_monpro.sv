`timescale 1ns / 1ps

module tb_monpro #(
    parameter unsigned DATAWIDTH = 256,

    parameter logic unsigned [DATAWIDTH-1:0] A = 256'h79d5686c6da2c90cd58f3ed75486c6adacbf3e872a288a754763b6da42bf2478,
    parameter logic unsigned [DATAWIDTH-1:0] B = 256'h79d5686c6da2c90cd58f3ed75486c6adacbf3e872a288a754763b6da42bf2478,
    parameter logic unsigned [DATAWIDTH-1:0] N = 256'h99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d,
    parameter logic unsigned [DATAWIDTH-1:0] U_EXPECTED = 256'h1362a24b630a8e265b65d361fb91a90e5a2dc8b25bb2ccc2afc1d440adedd68
    ) (
    input logic clk,
    input logic rstn,

    input logic start,
    output logic o_valid
    );

    logic unsigned [DATAWIDTH-1:0] U;

    /* verilator lint_off UNUSED */
    logic w_ready;
    /* verilator lint_on UNUSED */

    monpro #(
        .DATAWIDTH(DATAWIDTH)
    ) monpro_inst (
        .clk(clk),
        .rstn(rstn),

        .start(start),
        .ready(w_ready),
        .o_valid(o_valid),

        .i_A(A),
        .i_B(B),
        .i_N(N),
        .o_U(U)
    );

    always_ff @(posedge clk) begin
        if (o_valid & rstn) begin
            $display("Result: %064h", U);
        end
    end
endmodule
