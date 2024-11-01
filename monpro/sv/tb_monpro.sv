`timescale 1ns / 1ps

module tb_monpro #(
    parameter unsigned DATAWIDTH = 256,

    parameter logic unsigned [DATAWIDTH-1:0] A = 256'h12d456b52fa348795ea45d718801f8b06f36e8dfb75a67edb55c3f24802639dc,
    parameter logic unsigned [DATAWIDTH-1:0] B = 256'ha428af0aabd7dd0c3010b45dbc7634cb64d24c0582925701dd93aa34c2f108d,
    parameter logic unsigned [DATAWIDTH-1:0] N = 256'h19bfb084128dd8d58b7ab2b15fc9b082746e37ffd238398df42fa049b078ccbd,
    parameter logic unsigned [DATAWIDTH-1:0] U_EXPECTED = 256'h8135951beae3febd4223575ca05ef93dfa1f34400e1a532d94ee29520104d16
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
