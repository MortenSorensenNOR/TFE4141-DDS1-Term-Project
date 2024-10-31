// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vmonpro__Syms.h"


//======================

void Vmonpro::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vmonpro::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vmonpro__Syms* __restrict vlSymsp = static_cast<Vmonpro__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vmonpro::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vmonpro::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vmonpro__Syms* __restrict vlSymsp = static_cast<Vmonpro__Syms*>(userp);
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vmonpro::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vmonpro__Syms* __restrict vlSymsp = static_cast<Vmonpro__Syms*>(userp);
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBit(c+27,"clk", false,-1);
        tracep->declBit(c+28,"rstn", false,-1);
        tracep->declBit(c+29,"start", false,-1);
        tracep->declBit(c+30,"ready", false,-1);
        tracep->declBit(c+31,"o_valid", false,-1);
        tracep->declQuad(c+32,"i_A", false,-1, 63,0);
        tracep->declQuad(c+34,"i_B", false,-1, 63,0);
        tracep->declQuad(c+36,"i_N", false,-1, 63,0);
        tracep->declQuad(c+38,"o_U", false,-1, 63,0);
        tracep->declBus(c+41,"monpro DATAWIDTH", false,-1, 31,0);
        tracep->declBit(c+27,"monpro clk", false,-1);
        tracep->declBit(c+28,"monpro rstn", false,-1);
        tracep->declBit(c+29,"monpro start", false,-1);
        tracep->declBit(c+30,"monpro ready", false,-1);
        tracep->declBit(c+31,"monpro o_valid", false,-1);
        tracep->declQuad(c+32,"monpro i_A", false,-1, 63,0);
        tracep->declQuad(c+34,"monpro i_B", false,-1, 63,0);
        tracep->declQuad(c+36,"monpro i_N", false,-1, 63,0);
        tracep->declQuad(c+38,"monpro o_U", false,-1, 63,0);
        tracep->declBus(c+1,"monpro i_cnt", false,-1, 6,0);
        tracep->declQuad(c+2,"monpro r_A", false,-1, 63,0);
        tracep->declQuad(c+4,"monpro r_B", false,-1, 63,0);
        tracep->declQuad(c+6,"monpro r_N", false,-1, 63,0);
        tracep->declArray(c+8,"monpro U_reg", false,-1, 64,0);
        tracep->declArray(c+11,"monpro adder_input", false,-1, 64,0);
        tracep->declArray(c+14,"monpro adder_result", false,-1, 64,0);
        tracep->declArray(c+17,"monpro adder_bypass_result", false,-1, 64,0);
        tracep->declArray(c+20,"monpro monpro_comb_result", false,-1, 64,0);
        tracep->declBit(c+23,"monpro adder_input_mux_select", false,-1);
        tracep->declBit(c+24,"monpro adder_bypass_mux_select", false,-1);
        tracep->declBit(c+25,"monpro adder_result_shift_mux_select", false,-1);
        tracep->declBus(c+26,"monpro current_state", false,-1, 2,0);
        tracep->declBus(c+40,"monpro next_state", false,-1, 2,0);
    }
}

void Vmonpro::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vmonpro::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vmonpro__Syms* __restrict vlSymsp = static_cast<Vmonpro__Syms*>(userp);
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vmonpro::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vmonpro__Syms* __restrict vlSymsp = static_cast<Vmonpro__Syms*>(userp);
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->monpro__DOT__i_cnt),7);
        tracep->fullQData(oldp+2,(vlTOPp->monpro__DOT__r_A),64);
        tracep->fullQData(oldp+4,(vlTOPp->monpro__DOT__r_B),64);
        tracep->fullQData(oldp+6,(vlTOPp->monpro__DOT__r_N),64);
        tracep->fullWData(oldp+8,(vlTOPp->monpro__DOT__U_reg),65);
        tracep->fullWData(oldp+11,(vlTOPp->monpro__DOT__adder_input),65);
        tracep->fullWData(oldp+14,(vlTOPp->monpro__DOT__adder_result),65);
        tracep->fullWData(oldp+17,(vlTOPp->monpro__DOT__adder_bypass_result),65);
        tracep->fullWData(oldp+20,(vlTOPp->monpro__DOT__monpro_comb_result),65);
        tracep->fullBit(oldp+23,(vlTOPp->monpro__DOT__adder_input_mux_select));
        tracep->fullBit(oldp+24,(vlTOPp->monpro__DOT__adder_bypass_mux_select));
        tracep->fullBit(oldp+25,(vlTOPp->monpro__DOT__adder_result_shift_mux_select));
        tracep->fullCData(oldp+26,(vlTOPp->monpro__DOT__current_state),3);
        tracep->fullBit(oldp+27,(vlTOPp->clk));
        tracep->fullBit(oldp+28,(vlTOPp->rstn));
        tracep->fullBit(oldp+29,(vlTOPp->start));
        tracep->fullBit(oldp+30,(vlTOPp->ready));
        tracep->fullBit(oldp+31,(vlTOPp->o_valid));
        tracep->fullQData(oldp+32,(vlTOPp->i_A),64);
        tracep->fullQData(oldp+34,(vlTOPp->i_B),64);
        tracep->fullQData(oldp+36,(vlTOPp->i_N),64);
        tracep->fullQData(oldp+38,(vlTOPp->o_U),64);
        tracep->fullCData(oldp+40,(vlTOPp->monpro__DOT__next_state),3);
        tracep->fullIData(oldp+41,(0x40U),32);
    }
}
