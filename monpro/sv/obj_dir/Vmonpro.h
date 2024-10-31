// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VMONPRO_H_
#define _VMONPRO_H_  // guard

#include "verilated.h"

//==========

class Vmonpro__Syms;
class Vmonpro_VerilatedVcd;


//----------

VL_MODULE(Vmonpro) {
  public:
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(clk,0,0);
    VL_IN8(rstn,0,0);
    VL_IN8(start,0,0);
    VL_OUT8(ready,0,0);
    VL_OUT8(o_valid,0,0);
    VL_IN64(i_A,63,0);
    VL_IN64(i_B,63,0);
    VL_IN64(i_N,63,0);
    VL_OUT64(o_U,63,0);
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    CData/*6:0*/ monpro__DOT__i_cnt;
    CData/*0:0*/ monpro__DOT__adder_input_mux_select;
    CData/*0:0*/ monpro__DOT__adder_bypass_mux_select;
    CData/*0:0*/ monpro__DOT__adder_result_shift_mux_select;
    CData/*2:0*/ monpro__DOT__current_state;
    CData/*2:0*/ monpro__DOT__next_state;
    WData/*64:0*/ monpro__DOT__U_reg[3];
    WData/*64:0*/ monpro__DOT__adder_input[3];
    WData/*64:0*/ monpro__DOT__adder_result[3];
    WData/*64:0*/ monpro__DOT__adder_bypass_result[3];
    WData/*64:0*/ monpro__DOT__monpro_comb_result[3];
    QData/*63:0*/ monpro__DOT__r_A;
    QData/*63:0*/ monpro__DOT__r_B;
    QData/*63:0*/ monpro__DOT__r_N;
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    CData/*0:0*/ __Vclklast__TOP__clk;
    CData/*0:0*/ __Vm_traceActivity[2];
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    Vmonpro__Syms* __VlSymsp;  // Symbol table
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vmonpro);  ///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible with respect to DPI scope names.
    Vmonpro(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vmonpro();
    /// Trace signals in the model; called by application code
    void trace(VerilatedVcdC* tfp, int levels, int options = 0);
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval() { eval_step(); }
    /// Evaluate when calling multiple units/models per time step.
    void eval_step();
    /// Evaluate at end of a timestep for tracing, when using eval_step().
    /// Application must call after all eval() and before time changes.
    void eval_end_step() {}
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(Vmonpro__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(Vmonpro__Syms* symsp, bool first);
  private:
    static QData _change_request(Vmonpro__Syms* __restrict vlSymsp);
    static QData _change_request_1(Vmonpro__Syms* __restrict vlSymsp);
  public:
    static void _combo__TOP__4(Vmonpro__Syms* __restrict vlSymsp);
  private:
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _eval(Vmonpro__Syms* __restrict vlSymsp);
  private:
#ifdef VL_DEBUG
    void _eval_debug_assertions();
#endif  // VL_DEBUG
  public:
    static void _eval_initial(Vmonpro__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _eval_settle(Vmonpro__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _initial__TOP__2(Vmonpro__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _sequent__TOP__1(Vmonpro__Syms* __restrict vlSymsp);
    static void _settle__TOP__3(Vmonpro__Syms* __restrict vlSymsp) VL_ATTR_COLD;
  private:
    static void traceChgSub0(void* userp, VerilatedVcd* tracep);
    static void traceChgTop0(void* userp, VerilatedVcd* tracep);
    static void traceCleanup(void* userp, VerilatedVcd* /*unused*/);
    static void traceFullSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceFullTop0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitTop(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    void traceRegister(VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
