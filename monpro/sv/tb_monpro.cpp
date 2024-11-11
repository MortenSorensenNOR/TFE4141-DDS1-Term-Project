#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Vtb_monpro.h"

#define DATAWIDTH 64
#define RESET_CLKS 8

#define MAX_SIM_TIME 12345678910
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

int main(int argc, char** argv) {
    srand(time(NULL));

    Verilated::commandArgs(argc, argv);
    Vtb_monpro* dut = new Vtb_monpro;
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    for (int i = 0; i < RESET_CLKS; i++) {
        dut->clk ^= 1;
        dut->eval();

        // dut->i_A = 0;
        // dut->i_B = 0;
        // dut->i_N = 0;
        dut->start = 0;
        dut->rstn = 0;
    
        m_trace->dump(sim_time);
        sim_time++;
    }
    dut->rstn = 1;
           
    vluint64_t A = 0x228c0e57eaa1af70;
    vluint64_t B = 0x228c0e57eaa1af70;
    vluint64_t N = 0x3567cae757bd801f;
    vluint64_t expected_U = 0xc0bf71cc942bada;

    while (sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1;
        dut->eval();
    
        if (dut->clk == 1) {
            posedge_cnt++;
            // dut->i_A = 0;
            // dut->i_B = 0;
            // dut->i_N = 0;
            dut->start = 0;

            if (posedge_cnt == 8) {
                // dut->i_A = A;
                // dut->i_B = B;
                // dut->i_N = N;
                dut->start = 1;
            }

            static bool finished = false;
            if (dut->o_valid) {
                printf("Finished in %lu cycles\n", posedge_cnt);
                finished = true;
            }

            if (finished) {
                static int cnt = 0;
                cnt++;
                if (cnt == 2) {
                    break;
                }
            }

        }

        m_trace->dump(sim_time);
        sim_time++;
    }
    
    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);

}
