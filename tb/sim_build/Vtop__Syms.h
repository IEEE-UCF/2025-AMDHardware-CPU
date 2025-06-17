// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VTOP__SYMS_H_
#define VERILATED_VTOP__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vtop.h"

// INCLUDE MODULE CLASSES
#include "Vtop___024root.h"

// DPI TYPES for DPI Export callbacks (Internal use)

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vtop__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vtop* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vtop___024root                 TOP;

    // SCOPE NAMES
    VerilatedScope __Vscope_TOP;
    VerilatedScope __Vscope_cpu_top;
    VerilatedScope __Vscope_cpu_top__ex_stage;
    VerilatedScope __Vscope_cpu_top__exmm_reg;
    VerilatedScope __Vscope_cpu_top__id_stage;
    VerilatedScope __Vscope_cpu_top__id_stage__a_bypass;
    VerilatedScope __Vscope_cpu_top__id_stage__a_bypass__bypass_selection;
    VerilatedScope __Vscope_cpu_top__id_stage__b_bypass;
    VerilatedScope __Vscope_cpu_top__id_stage__b_bypass__bypass_selection;
    VerilatedScope __Vscope_cpu_top__id_stage__b_mux;
    VerilatedScope __Vscope_cpu_top__id_stage__branch_addrs;
    VerilatedScope __Vscope_cpu_top__id_stage__gen_imme;
    VerilatedScope __Vscope_cpu_top__id_stage__load_stall_check;
    VerilatedScope __Vscope_cpu_top__id_stage__register_file;
    VerilatedScope __Vscope_cpu_top__id_stage__register_file__a_out;
    VerilatedScope __Vscope_cpu_top__id_stage__register_file__b_out;
    VerilatedScope __Vscope_cpu_top__id_stage__register_file__gpu;
    VerilatedScope __Vscope_cpu_top__id_stage__register_file__gpu__unnamedblk1;
    VerilatedScope __Vscope_cpu_top__id_stage__register_file__main;
    VerilatedScope __Vscope_cpu_top__id_stage__register_file__main__unnamedblk1;
    VerilatedScope __Vscope_cpu_top__id_stage__register_file__shadow;
    VerilatedScope __Vscope_cpu_top__id_stage__register_file__shadow__unnamedblk1;
    VerilatedScope __Vscope_cpu_top__id_stage__rs_equality;
    VerilatedScope __Vscope_cpu_top__id_stage__stage2;
    VerilatedScope __Vscope_cpu_top__id_stage__stage2__insts;
    VerilatedScope __Vscope_cpu_top__idex_reg;
    VerilatedScope __Vscope_cpu_top__if_stage;
    VerilatedScope __Vscope_cpu_top__if_stage__M1;
    VerilatedScope __Vscope_cpu_top__if_stage__M2;
    VerilatedScope __Vscope_cpu_top__if_stage__M3;
    VerilatedScope __Vscope_cpu_top__mm_stage_inst;
    VerilatedScope __Vscope_cpu_top__wb_stage;

    // SCOPE HIERARCHY
    VerilatedHierarchy __Vhier;

    // CONSTRUCTORS
    Vtop__Syms(VerilatedContext* contextp, const char* namep, Vtop* modelp);
    ~Vtop__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
