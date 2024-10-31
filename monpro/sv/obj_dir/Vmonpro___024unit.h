// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vmonpro.h for the primary calling header

#ifndef _VMONPRO___024UNIT_H_
#define _VMONPRO___024UNIT_H_  // guard

#include "verilated.h"

//==========

class Vmonpro__Syms;
class Vmonpro_VerilatedVcd;


//----------

VL_MODULE(Vmonpro___024unit) {
  public:
    
    // INTERNAL VARIABLES
  private:
    Vmonpro__Syms* __VlSymsp;  // Symbol table
  public:
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vmonpro___024unit);  ///< Copying not allowed
  public:
    Vmonpro___024unit(const char* name = "TOP");
    ~Vmonpro___024unit();
    
    // INTERNAL METHODS
    void __Vconfigure(Vmonpro__Syms* symsp, bool first);
  private:
    void _ctor_var_reset() VL_ATTR_COLD;
    static void traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
