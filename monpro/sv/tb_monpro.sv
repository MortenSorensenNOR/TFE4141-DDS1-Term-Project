`timescale 1ns / 1ps

module tb_monpro #(
    parameter unsigned DATAWIDTH = 256,

    parameter logic unsigned [DATAWIDTH-1:0] A = 256'h1f94373be50b1cc0ced44eebde66dd7acb02d59c51941d2497184c45aab39f5f,
    parameter logic unsigned [DATAWIDTH-1:0] B = 256'h1f94373be50b1cc0ced44eebde66dd7acb02d59c51941d2497184c45aab39f5f,
    parameter logic unsigned [DATAWIDTH-1:0] N = 256'h2e5f7417fd9c9471c4ee1077900d7e4051e4d3f682b95bc27f5d128e05df33b5,
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
            assert (U_EXPECTED == U) $display ("Test Passed :)");
                else $error("Output did not match expected result");
        end
    end
endmodule
