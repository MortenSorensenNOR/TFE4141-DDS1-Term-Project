// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmonpro.h for the primary calling header

#include "Vmonpro.h"
#include "Vmonpro__Syms.h"

//==========

VL_CTOR_IMP(Vmonpro) {
    Vmonpro__Syms* __restrict vlSymsp = __VlSymsp = new Vmonpro__Syms(this, name());
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vmonpro::__Vconfigure(Vmonpro__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-9);
    Verilated::timeprecision(-12);
}

Vmonpro::~Vmonpro() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void Vmonpro::_initial__TOP__2(Vmonpro__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_initial__TOP__2\n"); );
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->monpro__DOT__current_state = 0U;
    vlTOPp->monpro__DOT__next_state = 0U;
}

void Vmonpro::_settle__TOP__3(Vmonpro__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_settle__TOP__3\n"); );
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    WData/*95:0*/ __Vtemp14[3];
    WData/*95:0*/ __Vtemp15[3];
    WData/*95:0*/ __Vtemp18[3];
    WData/*95:0*/ __Vtemp22[3];
    // Body
    VL_EXTEND_WQ(65,64, __Vtemp14, vlTOPp->monpro__DOT__r_N);
    VL_EXTEND_WQ(65,64, __Vtemp15, vlTOPp->monpro__DOT__r_B);
    if (vlTOPp->monpro__DOT__adder_input_mux_select) {
        vlTOPp->monpro__DOT__adder_input[0U] = __Vtemp14[0U];
        vlTOPp->monpro__DOT__adder_input[1U] = __Vtemp14[1U];
        vlTOPp->monpro__DOT__adder_input[2U] = __Vtemp14[2U];
    } else {
        vlTOPp->monpro__DOT__adder_input[0U] = __Vtemp15[0U];
        vlTOPp->monpro__DOT__adder_input[1U] = __Vtemp15[1U];
        vlTOPp->monpro__DOT__adder_input[2U] = __Vtemp15[2U];
    }
    VL_ADD_W(3, __Vtemp18, vlTOPp->monpro__DOT__U_reg, vlTOPp->monpro__DOT__adder_input);
    vlTOPp->monpro__DOT__adder_result[0U] = __Vtemp18[0U];
    vlTOPp->monpro__DOT__adder_result[1U] = __Vtemp18[1U];
    vlTOPp->monpro__DOT__adder_result[2U] = (1U & __Vtemp18[2U]);
    if (vlTOPp->monpro__DOT__adder_bypass_mux_select) {
        vlTOPp->monpro__DOT__adder_bypass_result[0U] 
            = vlTOPp->monpro__DOT__U_reg[0U];
        vlTOPp->monpro__DOT__adder_bypass_result[1U] 
            = vlTOPp->monpro__DOT__U_reg[1U];
        vlTOPp->monpro__DOT__adder_bypass_result[2U] 
            = vlTOPp->monpro__DOT__U_reg[2U];
    } else {
        vlTOPp->monpro__DOT__adder_bypass_result[0U] 
            = vlTOPp->monpro__DOT__adder_result[0U];
        vlTOPp->monpro__DOT__adder_bypass_result[1U] 
            = vlTOPp->monpro__DOT__adder_result[1U];
        vlTOPp->monpro__DOT__adder_bypass_result[2U] 
            = vlTOPp->monpro__DOT__adder_result[2U];
    }
    VL_SHIFTR_WWI(65,65,32, __Vtemp22, vlTOPp->monpro__DOT__adder_bypass_result, 1U);
    if (vlTOPp->monpro__DOT__adder_result_shift_mux_select) {
        vlTOPp->monpro__DOT__monpro_comb_result[0U] 
            = vlTOPp->monpro__DOT__adder_bypass_result[0U];
        vlTOPp->monpro__DOT__monpro_comb_result[1U] 
            = vlTOPp->monpro__DOT__adder_bypass_result[1U];
        vlTOPp->monpro__DOT__monpro_comb_result[2U] 
            = (1U & vlTOPp->monpro__DOT__adder_bypass_result[2U]);
    } else {
        vlTOPp->monpro__DOT__monpro_comb_result[0U] 
            = __Vtemp22[0U];
        vlTOPp->monpro__DOT__monpro_comb_result[1U] 
            = __Vtemp22[1U];
        vlTOPp->monpro__DOT__monpro_comb_result[2U] 
            = (1U & __Vtemp22[2U]);
    }
    vlTOPp->ready = 0U;
    if ((1U & (~ ((IData)(vlTOPp->monpro__DOT__current_state) 
                  >> 2U)))) {
        if ((1U & (~ ((IData)(vlTOPp->monpro__DOT__current_state) 
                      >> 1U)))) {
            if ((1U & (~ (IData)(vlTOPp->monpro__DOT__current_state)))) {
                if ((1U & (~ (IData)(vlTOPp->start)))) {
                    vlTOPp->ready = 1U;
                }
            }
        }
    }
    vlTOPp->monpro__DOT__next_state = vlTOPp->monpro__DOT__current_state;
    if ((4U & (IData)(vlTOPp->monpro__DOT__current_state))) {
        vlTOPp->monpro__DOT__next_state = ((2U & (IData)(vlTOPp->monpro__DOT__current_state))
                                            ? ((1U 
                                                & (IData)(vlTOPp->monpro__DOT__current_state))
                                                ? 0U
                                                : 1U)
                                            : 1U);
    } else {
        if ((2U & (IData)(vlTOPp->monpro__DOT__current_state))) {
            vlTOPp->monpro__DOT__next_state = ((1U 
                                                & (IData)(vlTOPp->monpro__DOT__current_state))
                                                ? 1U
                                                : 3U);
        } else {
            if ((1U & (IData)(vlTOPp->monpro__DOT__current_state))) {
                vlTOPp->monpro__DOT__next_state = (
                                                   (0x40U 
                                                    == (IData)(vlTOPp->monpro__DOT__i_cnt))
                                                    ? 7U
                                                    : 
                                                   ((1U 
                                                     & ((IData)(vlTOPp->monpro__DOT__r_A) 
                                                        & vlTOPp->monpro__DOT__U_reg[0U]))
                                                     ? 2U
                                                     : 
                                                    ((1U 
                                                      & ((IData)(vlTOPp->monpro__DOT__r_A) 
                                                         & (~ 
                                                            vlTOPp->monpro__DOT__U_reg[0U])))
                                                      ? 4U
                                                      : 
                                                     ((1U 
                                                       & ((~ (IData)(vlTOPp->monpro__DOT__r_A)) 
                                                          & vlTOPp->monpro__DOT__U_reg[0U]))
                                                       ? 5U
                                                       : 6U))));
            } else {
                if (vlTOPp->start) {
                    vlTOPp->monpro__DOT__next_state = 1U;
                }
            }
        }
    }
}

void Vmonpro::_eval_initial(Vmonpro__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_eval_initial\n"); );
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
    vlTOPp->_initial__TOP__2(vlSymsp);
    vlTOPp->__Vm_traceActivity[1U] = 1U;
    vlTOPp->__Vm_traceActivity[0U] = 1U;
}

void Vmonpro::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::final\n"); );
    // Variables
    Vmonpro__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vmonpro::_eval_settle(Vmonpro__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_eval_settle\n"); );
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__3(vlSymsp);
    vlTOPp->__Vm_traceActivity[1U] = 1U;
    vlTOPp->__Vm_traceActivity[0U] = 1U;
}

void Vmonpro::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_ctor_var_reset\n"); );
    // Body
    clk = VL_RAND_RESET_I(1);
    rstn = VL_RAND_RESET_I(1);
    start = VL_RAND_RESET_I(1);
    ready = VL_RAND_RESET_I(1);
    o_valid = VL_RAND_RESET_I(1);
    i_A = VL_RAND_RESET_Q(64);
    i_B = VL_RAND_RESET_Q(64);
    i_N = VL_RAND_RESET_Q(64);
    o_U = VL_RAND_RESET_Q(64);
    monpro__DOT__i_cnt = VL_RAND_RESET_I(7);
    monpro__DOT__r_A = VL_RAND_RESET_Q(64);
    monpro__DOT__r_B = VL_RAND_RESET_Q(64);
    monpro__DOT__r_N = VL_RAND_RESET_Q(64);
    VL_RAND_RESET_W(65, monpro__DOT__U_reg);
    VL_RAND_RESET_W(65, monpro__DOT__adder_input);
    VL_RAND_RESET_W(65, monpro__DOT__adder_result);
    VL_RAND_RESET_W(65, monpro__DOT__adder_bypass_result);
    VL_RAND_RESET_W(65, monpro__DOT__monpro_comb_result);
    monpro__DOT__adder_input_mux_select = VL_RAND_RESET_I(1);
    monpro__DOT__adder_bypass_mux_select = VL_RAND_RESET_I(1);
    monpro__DOT__adder_result_shift_mux_select = VL_RAND_RESET_I(1);
    monpro__DOT__current_state = VL_RAND_RESET_I(3);
    monpro__DOT__next_state = VL_RAND_RESET_I(3);
    { int __Vi0=0; for (; __Vi0<2; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
