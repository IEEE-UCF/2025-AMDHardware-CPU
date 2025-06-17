// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop__pch.h"
#include "Vtop___024root.h"

VL_ATTR_COLD void Vtop___024root___eval_static(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_static\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtop___024root___eval_initial__TOP(Vtop___024root* vlSelf);

VL_ATTR_COLD void Vtop___024root___eval_initial(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_initial\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtop___024root___eval_initial__TOP(vlSelf);
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__reset__0 = vlSelfRef.reset;
}

VL_ATTR_COLD void Vtop___024root___eval_initial__TOP(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_initial__TOP\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.cpu_top__DOT__gpu_write_en = 0U;
    vlSelfRef.cpu_top__DOT__gpu_write_addr = 0U;
    vlSelfRef.cpu_top__DOT__gpu_write_data = 0ULL;
    vlSelfRef.cpu_top__DOT__gpu_read_addr = 0U;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M3__DOT__inst_valid = 1U;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M3__DOT__inst_word = 0x13U;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__ecall = 0U;
}

VL_ATTR_COLD void Vtop___024root___eval_final(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_final\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__stl(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtop___024root___eval_phase__stl(Vtop___024root* vlSelf);

VL_ATTR_COLD void Vtop___024root___eval_settle(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_settle\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY(((0x64U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("/home/jackn/Documents/GithubRepos/2025-AMDHardware-CPU/tb/../src/cpu_top.sv", 1, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vtop___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelfRef.__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__stl(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___dump_triggers__stl\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VstlTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf);

VL_ATTR_COLD void Vtop___024root___eval_stl(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_stl\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        Vtop___024root___ico_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD void Vtop___024root___eval_triggers__stl(Vtop___024root* vlSelf);

VL_ATTR_COLD bool Vtop___024root___eval_phase__stl(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__stl\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtop___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelfRef.__VstlTriggered.any();
    if (__VstlExecute) {
        Vtop___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__ico(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___dump_triggers__ico\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VicoTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VicoTriggered.word(0U))) {
        VL_DBG_MSGF("         'ico' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__act(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___dump_triggers__act\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk)\n");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @(negedge clk)\n");
    }
    if ((4ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 2 is active: @(posedge reset)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__nba(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___dump_triggers__nba\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk)\n");
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @(negedge clk)\n");
    }
    if ((4ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 2 is active: @(posedge reset)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtop___024root___ctor_var_reset(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___ctor_var_reset\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->reset = VL_RAND_RESET_I(1);
    vlSelf->__SYM__interrupt = VL_RAND_RESET_I(1);
    vlSelf->imem_addr = VL_RAND_RESET_Q(64);
    vlSelf->imem_data = VL_RAND_RESET_I(32);
    vlSelf->imem_ready = VL_RAND_RESET_I(1);
    vlSelf->dmem_addr = VL_RAND_RESET_Q(64);
    vlSelf->dmem_write_data = VL_RAND_RESET_Q(64);
    vlSelf->dmem_read = VL_RAND_RESET_I(1);
    vlSelf->dmem_write = VL_RAND_RESET_I(1);
    vlSelf->dmem_read_data = VL_RAND_RESET_Q(64);
    vlSelf->dmem_ready = VL_RAND_RESET_I(1);
    vlSelf->debug_pc = VL_RAND_RESET_Q(64);
    vlSelf->debug_inst = VL_RAND_RESET_I(32);
    vlSelf->pipeline_stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__interrupt = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__imem_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__imem_data = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__imem_ready = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__dmem_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__dmem_write_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__dmem_read = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__dmem_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__dmem_read_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__dmem_ready = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__debug_pc = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__debug_inst = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__pipeline_stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_pc = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_pc4 = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_inst = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__if_inst_valid = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_inst_buffer_empty = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_inst_buffer_full = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_is_equal = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_read_out_gpu = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_read_out_a = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_read_out_b = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_bra_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_jal_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_jar_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_reg_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_mem_read = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_mem_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_alu_op = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_has_imm = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_imm_type = VL_RAND_RESET_I(2);
    vlSelf->cpu_top__DOT__id_pc_sel = VL_RAND_RESET_I(2);
    vlSelf->cpu_top__DOT__id_is_load = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_rs1 = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_rs2 = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__idex_reg_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_mem_read = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_mem_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_alu_op = VL_RAND_RESET_I(4);
    vlSelf->cpu_top__DOT__idex_rs1_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_rs2_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_imm = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__idex_rs1 = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__idex_rs2 = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__ex_alu_result = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__exmm_reg_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_mem_read = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_mem_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_alu_result = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__exmm_write_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__exmm_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__mm_mem_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_alu_result = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__mm_reg_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__wb_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__ex_forward_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_forward_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_mem_forward_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__ex_forward_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__mm_forward_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__mm_mem_forward_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__gpu_write_en = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__gpu_write_addr = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__gpu_write_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__gpu_read_addr = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__load_stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__global_stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__branch_taken = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__pc_sel = VL_RAND_RESET_I(2);
    vlSelf->cpu_top__DOT__if_stage__DOT__bra_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__jal_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__jar_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__d_pc = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__d_pc4 = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__d_inst_word = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__if_stage__DOT__inst_valid = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__inst_buffer_empty = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__inst_buffer_full = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__pc_next = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__pc_curr = VL_RAND_RESET_Q(64);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->cpu_top__DOT__if_stage__DOT__pc_next_options[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__if_stage__DOT__inst_word = VL_RAND_RESET_I(32);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->cpu_top__DOT__if_stage__DOT__M1__DOT__data_in[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__if_stage__DOT__M1__DOT__sel = VL_RAND_RESET_I(2);
    vlSelf->cpu_top__DOT__if_stage__DOT__M1__DOT__data_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__M2__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__M2__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__M2__DOT__stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__M2__DOT__pc_next = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__M2__DOT__pc_reg = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__M3__DOT__pc = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__if_stage__DOT__M3__DOT__pc_sel = VL_RAND_RESET_I(2);
    vlSelf->cpu_top__DOT__if_stage__DOT__M3__DOT__inst_valid = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__if_stage__DOT__M3__DOT__inst_word = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__interrupt = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__w_en = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__w_en_gpu = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__has_imm = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__imm_type = VL_RAND_RESET_I(2);
    vlSelf->cpu_top__DOT__id_stage__DOT__pc4 = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__pc = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__w_result = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__w_result_gpu = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__ex_pro = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__mm_pro = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__mm_mem = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__inst_word = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__load_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__is_load = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__w_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__w_rd_gpu = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__rs_gpu = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__ex_pro_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__mm_pro_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__mm_mem_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__is_equal = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__read_out_gpu = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__read_out_a = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__read_out_b = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__bra_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__jal_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__jar_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__inst_buffer_empty = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__inst_buffer_full = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__load_stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__reg_stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__d_pc = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__d_pc4 = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_out = VL_RAND_RESET_Q(64);
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__b_out_options[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__a_file_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_file_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__d_inst = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__d_inst_next = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__rs_equality__DOT__data_a = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__rs_equality__DOT__data_b = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__rs_equality__DOT__is_equal = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__pc = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__inst = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__data_a = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__bra_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jal_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jalr_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__bra_offset = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jal_offset = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jalr_offset = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__dest = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__load_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__is_load = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__rs1_addr = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__rs2_addr = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__stall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4 = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__pc = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__inst = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__inst_buffer_empty = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__inst_buffer_full = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__d_pc4 = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__d_pc = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__d_inst = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__d_inst_next = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4_reg = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__pc_reg = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_en = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__data_in = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__data_out = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_empty = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer[__Vi0] = VL_RAND_RESET_I(32);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_next = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr = VL_RAND_RESET_I(4);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr = VL_RAND_RESET_I(4);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_empty_flag = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__lower_bits_equal = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__upper_bit_equal = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__interrupt = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_cpu = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_gpu = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_cpu = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_gpu = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_cpu = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_gpu = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_a = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_b = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_gpu = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_gpu = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_main = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options[__Vi0] = VL_RAND_RESET_Q(64);
    }
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__write_addr = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__data_in = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__write_en = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__read_addr_a = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__read_addr_b = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__data_out_a = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__data_out_b = VL_RAND_RESET_Q(64);
    for (int __Vi0 = 0; __Vi0 < 32; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0;
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__write_addr = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__data_in = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__write_en = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__read_addr_a = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__read_addr_b = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__data_out_a = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__data_out_b = VL_RAND_RESET_Q(64);
    for (int __Vi0 = 0; __Vi0 < 32; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0;
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__write_addr = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__data_in = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__write_en = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__read_addr = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__data_out = VL_RAND_RESET_Q(64);
    for (int __Vi0 = 0; __Vi0 < 32; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0;
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__data_in[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__sel = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__data_out = VL_RAND_RESET_Q(64);
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__data_in[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__sel = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__data_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__file_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__ex_pro = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_pro = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_mem = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__file_out_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__ex_pro_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_pro_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_mem_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel = VL_RAND_RESET_I(2);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options[__Vi0] = VL_RAND_RESET_Q(64);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_in[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__sel = VL_RAND_RESET_I(2);
    vlSelf->cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__file_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__ex_pro = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_pro = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_mem = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__file_out_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__ex_pro_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_pro_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_mem_rs = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel = VL_RAND_RESET_I(2);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options[__Vi0] = VL_RAND_RESET_Q(64);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_in[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__sel = VL_RAND_RESET_I(2);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__id_stage__DOT__gen_imme__DOT__inst = VL_RAND_RESET_I(32);
    vlSelf->cpu_top__DOT__id_stage__DOT__gen_imme__DOT__imm_type = VL_RAND_RESET_I(2);
    vlSelf->cpu_top__DOT__id_stage__DOT__gen_imme__DOT__imm = VL_RAND_RESET_Q(64);
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->cpu_top__DOT__id_stage__DOT__b_mux__DOT__data_in[__Vi0] = VL_RAND_RESET_Q(64);
    }
    vlSelf->cpu_top__DOT__id_stage__DOT__b_mux__DOT__sel = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__id_stage__DOT__b_mux__DOT__data_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_reg__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rst = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_reg__DOT__reg_write_in = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_reg__DOT__mem_read_in = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_reg__DOT__mem_write_in = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_reg__DOT__alu_op_in = VL_RAND_RESET_I(4);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rs1_data_in = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rs2_data_in = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_reg__DOT__imm_in = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rd_in = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rs1_in = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rs2_in = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__idex_reg__DOT__reg_write_out = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_reg__DOT__mem_read_out = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_reg__DOT__mem_write_out = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__idex_reg__DOT__alu_op_out = VL_RAND_RESET_I(4);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rs1_data_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rs2_data_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_reg__DOT__imm_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rd_out = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rs1_out = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__idex_reg__DOT__rs2_out = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__ex_stage__DOT__ea = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__ex_stage__DOT__eb = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__ex_stage__DOT__epc4 = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__ex_stage__DOT__ealuc = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__ex_stage__DOT__ecall = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__ex_stage__DOT__eal = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__ex_stage__DOT__ealu = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__rst = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__reg_write_in = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__mem_read_in = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__mem_write_in = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__alu_result_in = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__write_data_in = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__rd_in = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__reg_write_out = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__mem_read_out = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__mem_write_out = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__alu_result_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__write_data_out = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__exmm_reg__DOT__rd_out = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__rst = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__ex_mem_alu_result = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__ex_mem_write_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__ex_mem_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__ex_mem_mem_read = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__ex_mem_mem_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__ex_mem_reg_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__mem_addr = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__mem_write_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__mem_read = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__mem_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__mem_read_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd = VL_RAND_RESET_I(5);
    vlSelf->cpu_top__DOT__mm_stage_inst__DOT__mem_wb_reg_write = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__wb_stage__DOT__walu = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__wb_stage__DOT__wmem = VL_RAND_RESET_Q(64);
    vlSelf->cpu_top__DOT__wb_stage__DOT__wmem2reg = VL_RAND_RESET_I(1);
    vlSelf->cpu_top__DOT__wb_stage__DOT__wdata = VL_RAND_RESET_Q(64);
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__reset__0 = VL_RAND_RESET_I(1);
}
