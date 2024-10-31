// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmonpro.h for the primary calling header

#include "Vmonpro.h"
#include "Vmonpro__Syms.h"

//==========

void Vmonpro::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vmonpro::eval\n"); );
    Vmonpro__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        vlSymsp->__Vm_activity = true;
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("monpro.sv", 14, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vmonpro::_eval_initial_loop(Vmonpro__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("monpro.sv", 14, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void Vmonpro::_sequent__TOP__1(Vmonpro__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_sequent__TOP__1\n"); );
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    WData/*95:0*/ __Vtemp3[3];
    WData/*95:0*/ __Vtemp4[3];
    WData/*95:0*/ __Vtemp7[3];
    WData/*95:0*/ __Vtemp11[3];
    // Body
    if (vlTOPp->rstn) {
        if ((4U & (IData)(vlTOPp->monpro__DOT__current_state))) {
            if ((2U & (IData)(vlTOPp->monpro__DOT__current_state))) {
                if ((1U & (IData)(vlTOPp->monpro__DOT__current_state))) {
                    vlTOPp->o_valid = 1U;
                }
            }
        } else {
            if ((1U & (~ ((IData)(vlTOPp->monpro__DOT__current_state) 
                          >> 1U)))) {
                if ((1U & (~ (IData)(vlTOPp->monpro__DOT__current_state)))) {
                    vlTOPp->o_valid = 0U;
                }
            }
        }
    } else {
        vlTOPp->o_valid = 0U;
    }
    if (vlTOPp->rstn) {
        if ((1U & (~ ((IData)(vlTOPp->monpro__DOT__current_state) 
                      >> 2U)))) {
            if ((1U & (~ ((IData)(vlTOPp->monpro__DOT__current_state) 
                          >> 1U)))) {
                vlTOPp->monpro__DOT__i_cnt = ((1U & (IData)(vlTOPp->monpro__DOT__current_state))
                                               ? (0x7fU 
                                                  & ((IData)(1U) 
                                                     + (IData)(vlTOPp->monpro__DOT__i_cnt)))
                                               : 0U);
            }
        }
    } else {
        vlTOPp->monpro__DOT__i_cnt = 0U;
    }
    if (vlTOPp->rstn) {
        if ((1U & (~ ((IData)(vlTOPp->monpro__DOT__current_state) 
                      >> 2U)))) {
            if ((1U & (~ ((IData)(vlTOPp->monpro__DOT__current_state) 
                          >> 1U)))) {
                if ((1U & (~ (IData)(vlTOPp->monpro__DOT__current_state)))) {
                    if (vlTOPp->start) {
                        vlTOPp->monpro__DOT__r_N = vlTOPp->i_N;
                    }
                }
            }
        }
    } else {
        vlTOPp->monpro__DOT__r_N = 0ULL;
    }
    if (vlTOPp->rstn) {
        if ((1U & (~ ((IData)(vlTOPp->monpro__DOT__current_state) 
                      >> 2U)))) {
            if ((1U & (~ ((IData)(vlTOPp->monpro__DOT__current_state) 
                          >> 1U)))) {
                if ((1U & (~ (IData)(vlTOPp->monpro__DOT__current_state)))) {
                    if (vlTOPp->start) {
                        vlTOPp->monpro__DOT__r_B = vlTOPp->i_B;
                    }
                }
            }
        }
    } else {
        vlTOPp->monpro__DOT__r_B = 0ULL;
    }
    if (vlTOPp->rstn) {
        if ((4U & (IData)(vlTOPp->monpro__DOT__current_state))) {
            if ((2U & (IData)(vlTOPp->monpro__DOT__current_state))) {
                if ((1U & (IData)(vlTOPp->monpro__DOT__current_state))) {
                    vlTOPp->o_U = (((QData)((IData)(
                                                    vlTOPp->monpro__DOT__U_reg[1U])) 
                                    << 0x20U) | (QData)((IData)(
                                                                vlTOPp->monpro__DOT__U_reg[0U])));
                }
            }
        } else {
            if ((2U & (IData)(vlTOPp->monpro__DOT__current_state))) {
                if ((1U & (~ (IData)(vlTOPp->monpro__DOT__current_state)))) {
                    vlTOPp->monpro__DOT__adder_input_mux_select = 1U;
                    vlTOPp->monpro__DOT__adder_bypass_mux_select = 0U;
                    vlTOPp->monpro__DOT__adder_result_shift_mux_select = 0U;
                }
            } else {
                if ((1U & (IData)(vlTOPp->monpro__DOT__current_state))) {
                    if ((1U & ((IData)(vlTOPp->monpro__DOT__r_A) 
                               & vlTOPp->monpro__DOT__U_reg[0U]))) {
                        vlTOPp->monpro__DOT__adder_input_mux_select = 0U;
                        vlTOPp->monpro__DOT__adder_bypass_mux_select = 0U;
                        vlTOPp->monpro__DOT__adder_result_shift_mux_select = 1U;
                    } else {
                        if ((1U & ((IData)(vlTOPp->monpro__DOT__r_A) 
                                   & (~ vlTOPp->monpro__DOT__U_reg[0U])))) {
                            vlTOPp->monpro__DOT__adder_input_mux_select = 0U;
                            vlTOPp->monpro__DOT__adder_bypass_mux_select = 0U;
                            vlTOPp->monpro__DOT__adder_result_shift_mux_select = 0U;
                        } else {
                            if ((1U & ((~ (IData)(vlTOPp->monpro__DOT__r_A)) 
                                       & vlTOPp->monpro__DOT__U_reg[0U]))) {
                                vlTOPp->monpro__DOT__adder_input_mux_select = 1U;
                                vlTOPp->monpro__DOT__adder_bypass_mux_select = 0U;
                                vlTOPp->monpro__DOT__adder_result_shift_mux_select = 0U;
                            } else {
                                vlTOPp->monpro__DOT__adder_input_mux_select = 1U;
                                vlTOPp->monpro__DOT__adder_bypass_mux_select = 1U;
                                vlTOPp->monpro__DOT__adder_result_shift_mux_select = 0U;
                            }
                        }
                    }
                    vlTOPp->monpro__DOT__r_A = (0x7fffffffffffffffULL 
                                                & (vlTOPp->monpro__DOT__r_A 
                                                   >> 1U));
                } else {
                    if (vlTOPp->start) {
                        vlTOPp->monpro__DOT__r_A = vlTOPp->i_A;
                    }
                    vlTOPp->o_U = 0ULL;
                }
            }
        }
    } else {
        vlTOPp->monpro__DOT__r_A = 0ULL;
        vlTOPp->o_U = 0ULL;
    }
    if (vlTOPp->rstn) {
        if ((4U & (IData)(vlTOPp->monpro__DOT__current_state))) {
            if ((2U & (IData)(vlTOPp->monpro__DOT__current_state))) {
                if ((1U & (~ (IData)(vlTOPp->monpro__DOT__current_state)))) {
                    vlTOPp->monpro__DOT__U_reg[0U] 
                        = vlTOPp->monpro__DOT__monpro_comb_result[0U];
                    vlTOPp->monpro__DOT__U_reg[1U] 
                        = vlTOPp->monpro__DOT__monpro_comb_result[1U];
                    vlTOPp->monpro__DOT__U_reg[2U] 
                        = vlTOPp->monpro__DOT__monpro_comb_result[2U];
                }
            } else {
                vlTOPp->monpro__DOT__U_reg[0U] = vlTOPp->monpro__DOT__monpro_comb_result[0U];
                vlTOPp->monpro__DOT__U_reg[1U] = vlTOPp->monpro__DOT__monpro_comb_result[1U];
                vlTOPp->monpro__DOT__U_reg[2U] = vlTOPp->monpro__DOT__monpro_comb_result[2U];
            }
        } else {
            if ((2U & (IData)(vlTOPp->monpro__DOT__current_state))) {
                vlTOPp->monpro__DOT__U_reg[0U] = vlTOPp->monpro__DOT__monpro_comb_result[0U];
                vlTOPp->monpro__DOT__U_reg[1U] = vlTOPp->monpro__DOT__monpro_comb_result[1U];
                vlTOPp->monpro__DOT__U_reg[2U] = vlTOPp->monpro__DOT__monpro_comb_result[2U];
            } else {
                if ((1U & (~ (IData)(vlTOPp->monpro__DOT__current_state)))) {
                    if (vlTOPp->start) {
                        vlTOPp->monpro__DOT__U_reg[0U] = 0U;
                        vlTOPp->monpro__DOT__U_reg[1U] = 0U;
                        vlTOPp->monpro__DOT__U_reg[2U] = 0U;
                    }
                }
            }
        }
    } else {
        vlTOPp->monpro__DOT__U_reg[0U] = 0U;
        vlTOPp->monpro__DOT__U_reg[1U] = 0U;
        vlTOPp->monpro__DOT__U_reg[2U] = 0U;
    }
    VL_EXTEND_WQ(65,64, __Vtemp3, vlTOPp->monpro__DOT__r_N);
    VL_EXTEND_WQ(65,64, __Vtemp4, vlTOPp->monpro__DOT__r_B);
    if (vlTOPp->monpro__DOT__adder_input_mux_select) {
        vlTOPp->monpro__DOT__adder_input[0U] = __Vtemp3[0U];
        vlTOPp->monpro__DOT__adder_input[1U] = __Vtemp3[1U];
        vlTOPp->monpro__DOT__adder_input[2U] = __Vtemp3[2U];
    } else {
        vlTOPp->monpro__DOT__adder_input[0U] = __Vtemp4[0U];
        vlTOPp->monpro__DOT__adder_input[1U] = __Vtemp4[1U];
        vlTOPp->monpro__DOT__adder_input[2U] = __Vtemp4[2U];
    }
    VL_ADD_W(3, __Vtemp7, vlTOPp->monpro__DOT__U_reg, vlTOPp->monpro__DOT__adder_input);
    vlTOPp->monpro__DOT__adder_result[0U] = __Vtemp7[0U];
    vlTOPp->monpro__DOT__adder_result[1U] = __Vtemp7[1U];
    vlTOPp->monpro__DOT__adder_result[2U] = (1U & __Vtemp7[2U]);
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
    VL_SHIFTR_WWI(65,65,32, __Vtemp11, vlTOPp->monpro__DOT__adder_bypass_result, 1U);
    if (vlTOPp->monpro__DOT__adder_result_shift_mux_select) {
        vlTOPp->monpro__DOT__monpro_comb_result[0U] 
            = vlTOPp->monpro__DOT__adder_bypass_result[0U];
        vlTOPp->monpro__DOT__monpro_comb_result[1U] 
            = vlTOPp->monpro__DOT__adder_bypass_result[1U];
        vlTOPp->monpro__DOT__monpro_comb_result[2U] 
            = (1U & vlTOPp->monpro__DOT__adder_bypass_result[2U]);
    } else {
        vlTOPp->monpro__DOT__monpro_comb_result[0U] 
            = __Vtemp11[0U];
        vlTOPp->monpro__DOT__monpro_comb_result[1U] 
            = __Vtemp11[1U];
        vlTOPp->monpro__DOT__monpro_comb_result[2U] 
            = (1U & __Vtemp11[2U]);
    }
    vlTOPp->monpro__DOT__current_state = ((IData)(vlTOPp->rstn)
                                           ? (IData)(vlTOPp->monpro__DOT__next_state)
                                           : 0U);
}

VL_INLINE_OPT void Vmonpro::_combo__TOP__4(Vmonpro__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_combo__TOP__4\n"); );
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
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

void Vmonpro::_eval(Vmonpro__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_eval\n"); );
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk)))) {
        vlTOPp->_sequent__TOP__1(vlSymsp);
        vlTOPp->__Vm_traceActivity[1U] = 1U;
    }
    vlTOPp->_combo__TOP__4(vlSymsp);
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

VL_INLINE_OPT QData Vmonpro::_change_request(Vmonpro__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_change_request\n"); );
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData Vmonpro::_change_request_1(Vmonpro__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_change_request_1\n"); );
    Vmonpro* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vmonpro::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmonpro::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((rstn & 0xfeU))) {
        Verilated::overWidthError("rstn");}
    if (VL_UNLIKELY((start & 0xfeU))) {
        Verilated::overWidthError("start");}
}
#endif  // VL_DEBUG
