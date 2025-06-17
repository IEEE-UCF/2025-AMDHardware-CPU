// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop__pch.h"
#include "Vtop__Syms.h"
#include "Vtop___024root.h"

// Parameter definitions for Vtop___024root
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__INST_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__REG_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__PC_TYPE_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__IMM_TYPE_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__INST_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__PC_TYPE_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__M1__DOT__INPUT_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__M1__DOT__INPUT_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__M2__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__M3__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__M3__DOT__INST_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__M3__DOT__PC_TYPE_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__INST_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__REG_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__rs_equality__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__INST_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__REG_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__stage2__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__stage2__DOT__INST_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__INST_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__BUFFER_DEPTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__REG_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__REG_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__REG_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__REG_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__INPUT_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__INPUT_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__INPUT_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__INPUT_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__a_bypass__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__a_bypass__DOT__REG_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__INPUT_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__INPUT_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__b_bypass__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__b_bypass__DOT__REG_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__INPUT_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__INPUT_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__gen_imme__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__gen_imme__DOT__INST_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__gen_imme__DOT__IMM_TYPE_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__b_mux__DOT__INPUT_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__id_stage__DOT__b_mux__DOT__INPUT_NUM;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__idex_reg__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__ex_stage__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__exmm_reg__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__mm_stage_inst__DOT__DATA_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__mm_stage_inst__DOT__ADDR_WIDTH;
constexpr IData/*31:0*/ Vtop___024root::cpu_top__DOT__wb_stage__DOT__DATA_WIDTH;
constexpr QData/*63:0*/ Vtop___024root::cpu_top__DOT__if_stage__DOT__M2__DOT__RESET_ADDR;


void Vtop___024root___ctor_var_reset(Vtop___024root* vlSelf);

Vtop___024root::Vtop___024root(Vtop__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vtop___024root___ctor_var_reset(this);
}

void Vtop___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vtop___024root::~Vtop___024root() {
}
