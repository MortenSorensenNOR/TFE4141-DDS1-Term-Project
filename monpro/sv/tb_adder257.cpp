#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Vadder257.h"

#define DATAWIDTH 64
#define RESET_CLKS 8

#define MAX_SIM_TIME 12345678910
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

void assign_data(Vadder257* dut, vluint64_t A[5], vluint64_t B[5]) {
    for (int i = 0; i < 4; i++) {
        dut->i_A[i] = A[i];
        dut->i_B[i] = B[i];
    }
    dut->i_A_upper = A[4];
    dut->i_B_upper = B[4];
}

int main(int argc, char** argv) {
    srand(time(NULL));

    Verilated::commandArgs(argc, argv);
    Vadder257* dut = new Vadder257;
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    for (int i = 0; i < RESET_CLKS; i++) {
        dut->clk ^= 1;
        dut->eval();

        for (int i = 0; i < 4; i++) {
            dut->i_A[i] = 0;
            dut->i_B[i] = 0;
        }
        dut->i_A_upper = 0;
        dut->i_B_upper = 0;
        dut->i_dv = 0;

        m_trace->dump(sim_time);
        sim_time++;
    }

    vluint64_t A[5] = {
        11004493287459540401, 9978106160811052080, 13223986148226053993, 12698187832401579312, 1
    };

    vluint64_t B[5] = {
        13630405444296409890, 16466853912938689950, 1165744445649406927, 7006763506994538468, 1
    };

    while (sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1;
        dut->eval();
    
        if (dut->clk == 1) {
            posedge_cnt++;
            dut->i_dv = 0;

            if (posedge_cnt == 12) {
                printf("Assigning data (%ld)\n", posedge_cnt);

                dut->i_dv = 1;
                assign_data(dut, A, B);
            }

            if (posedge_cnt > 12 && dut->ready) {
                printf("Assigning data (%ld)\n", posedge_cnt);

                A[0] += 1;
                dut->i_dv = 1;
                assign_data(dut, A, B);
            }

            static bool has_finished = false;
            if (dut->o_dv) {
                has_finished = true;
                printf("Finished (%ld)\n", posedge_cnt);
            }

            if (has_finished) {
                static int a = 0;
                a++;
                
                if (a == 32) {
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

