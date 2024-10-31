// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vmonpro__Syms.h"


void Vmonpro::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    Vmonpro__Syms* __restrict vlSymsp = static_cast<Vmonpro__Syms*>(userp);
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void Vmonpro::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    Vmonpro__Syms* __restrict vlSymsp = static_cast<Vmonpro__Syms*>(userp);
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        if (VL_UNLIKELY(vlTOPp->__Vm_traceActivity[1U])) {
            tracep->chgCData(oldp+0,(vlTOPp->monpro__DOT__i_cnt),7);
            tracep->chgQData(oldp+1,(vlTOPp->monpro__DOT__r_A),64);
            tracep->chgQData(oldp+3,(vlTOPp->monpro__DOT__r_B),64);
            tracep->chgQData(oldp+5,(vlTOPp->monpro__DOT__r_N),64);
            tracep->chgWData(oldp+7,(vlTOPp->monpro__DOT__U_reg),65);
            tracep->chgWData(oldp+10,(vlTOPp->monpro__DOT__adder_input),65);
            tracep->chgWData(oldp+13,(vlTOPp->monpro__DOT__adder_result),65);
            tracep->chgWData(oldp+16,(vlTOPp->monpro__DOT__adder_bypass_result),65);
            tracep->chgWData(oldp+19,(vlTOPp->monpro__DOT__monpro_comb_result),65);
            tracep->chgBit(oldp+22,(vlTOPp->monpro__DOT__adder_input_mux_select));
            tracep->chgBit(oldp+23,(vlTOPp->monpro__DOT__adder_bypass_mux_select));
            tracep->chgBit(oldp+24,(vlTOPp->monpro__DOT__adder_result_shift_mux_select));
            tracep->chgCData(oldp+25,(vlTOPp->monpro__DOT__current_state),3);
        }
        tracep->chgBit(oldp+26,(vlTOPp->clk));
        tracep->chgBit(oldp+27,(vlTOPp->rstn));
        tracep->chgBit(oldp+28,(vlTOPp->start));
        tracep->chgBit(oldp+29,(vlTOPp->ready));
        tracep->chgBit(oldp+30,(vlTOPp->o_valid));
        tracep->chgQData(oldp+31,(vlTOPp->i_A),64);
        tracep->chgQData(oldp+33,(vlTOPp->i_B),64);
        tracep->chgQData(oldp+35,(vlTOPp->i_N),64);
        tracep->chgQData(oldp+37,(vlTOPp->o_U),64);
        tracep->chgCData(oldp+39,(vlTOPp->monpro__DOT__next_state),3);
    }
}

void Vmonpro::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    Vmonpro__Syms* __restrict vlSymsp = static_cast<Vmonpro__Syms*>(userp);
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
        vlTOPp->__Vm_traceActivity[1U] = 0U;
    }
}
