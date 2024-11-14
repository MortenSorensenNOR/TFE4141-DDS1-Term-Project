`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2024 01:54:30 AM
// Design Name: 
// Module Name: tb_adder257
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_adder257();

    logic clk = 1'b0;
    
    initial begin
        forever begin
            clk = ~clk;
            #5;
        end
    end

    logic [256:0] A = 257'h1a9bbe83f060d1a8f805552855b0f7bb7ad592e22f3b7361ed33af64a75b9647f;
    logic [256:0] B = 257'h12b3cf84434564c56bcf98a1d976d405b2bd8ece20cdd17d762c318ea5eae629c;
    logic dv = 1'b0;
    
    logic [63:0] C[4];
    logic [1:0] C_carry;
    logic o_dv;
    
    logic [63:0] i_A[4];
    logic [63:0] i_B[4];
    assign i_A = '{A[63:0], A[127:64], A[191:128], A[255:192]};
    assign i_B = '{B[63:0], B[127:64], B[191:128], B[255:192]};
    
    logic [257:0] o_C;

    adder257 adder_inst (
        .clk(clk),
        .i_dv(dv),
        
        .i_A(i_A),
        .i_B(i_B),
        .i_A_upper(A[256]),
        .i_B_upper(B[256]),
        
        .o_C(C),
        .o_C_carry(C_carry),
        .o_dv(o_dv)
    );
    
    assign o_C = {C_carry, C[3], C[2], C[1], C[0]};
    
    initial begin
        #20;
        @(posedge clk);
        dv <= 1'b1;
        @(posedge clk);
        dv <= 1'b0;
        
        while (o_dv == 0) begin
            @(posedge clk);     
        end
        
        $display("Result: %x", o_C);
        $finish;
    end

endmodule
