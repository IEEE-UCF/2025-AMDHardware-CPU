// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop__pch.h"
#include "Vtop___024root.h"

void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf);

void Vtop___024root___eval_ico(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_ico\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VicoTriggered.word(0U))) {
        Vtop___024root___ico_sequent__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___ico_sequent__TOP__0\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.cpu_top__DOT__imem_data = vlSelfRef.imem_data;
    vlSelfRef.cpu_top__DOT__imem_ready = vlSelfRef.imem_ready;
    vlSelfRef.cpu_top__DOT__dmem_ready = vlSelfRef.dmem_ready;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__rs1_addr 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0xfU));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__rs2_addr 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0x14U));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__file_out_rs 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0xfU));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__file_out_rs 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0x14U));
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealuc = vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out;
    vlSelfRef.imem_addr = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc;
    vlSelfRef.debug_pc = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc;
    vlSelfRef.cpu_top__DOT__imem_addr = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc;
    vlSelfRef.cpu_top__DOT__debug_pc = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc;
    vlSelfRef.cpu_top__DOT__if_inst_buffer_full = vlSelfRef.cpu_top__DOT__if_stage__DOT__inst_buffer_full;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst_next 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__d_inst 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__d_inst_next 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.dmem_addr = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_out;
    vlSelfRef.cpu_top__DOT__dmem_addr = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_out;
    vlSelfRef.dmem_write_data = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out;
    vlSelfRef.cpu_top__DOT__dmem_write_data = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out;
    vlSelfRef.dmem_read = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_read_out;
    vlSelfRef.cpu_top__DOT__dmem_read = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_read_out;
    vlSelfRef.dmem_write = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_write_out;
    vlSelfRef.cpu_top__DOT__dmem_write = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_write_out;
    vlSelfRef.debug_inst = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_inst_word;
    vlSelfRef.cpu_top__DOT__debug_inst = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_inst_word;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__inst_valid 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__M3__DOT__inst_valid;
    vlSelfRef.cpu_top__DOT__idex_alu_op = vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out;
    vlSelfRef.cpu_top__DOT__if_inst_buffer_empty = vlSelfRef.cpu_top__DOT__if_stage__DOT__inst_buffer_empty;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__inst_word 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__M3__DOT__inst_word;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__d_pc4 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4_reg;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__d_pc4 = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4_reg;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__d_pc 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc_reg;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__d_pc = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc_reg;
    vlSelfRef.cpu_top__DOT__idex_imm = vlSelfRef.cpu_top__DOT__idex_reg__DOT__imm_out;
    vlSelfRef.cpu_top__DOT__idex_rs1 = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_out;
    vlSelfRef.cpu_top__DOT__idex_rs2 = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__data_out_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0xfU))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__data_out_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0x14U))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__data_out_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0xfU))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__data_out_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0x14U))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__read_out_gpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers
        [vlSelfRef.cpu_top__DOT__gpu_read_addr];
    vlSelfRef.cpu_top__DOT__id_read_out_gpu = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers
        [vlSelfRef.cpu_top__DOT__gpu_read_addr];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_gpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers
        [vlSelfRef.cpu_top__DOT__gpu_read_addr];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers
        [vlSelfRef.cpu_top__DOT__gpu_read_addr];
    vlSelfRef.cpu_top__DOT__dmem_read_data = vlSelfRef.dmem_read_data;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_curr 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__pc_reg;
    vlSelfRef.cpu_top__DOT__exmm_alu_result = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_out;
    vlSelfRef.cpu_top__DOT__exmm_write_data = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out;
    vlSelfRef.cpu_top__DOT__mm_alu_result = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result;
    vlSelfRef.cpu_top__DOT__mm_mem_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data;
    vlSelfRef.cpu_top__DOT__exmm_mem_write = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_write_out;
    vlSelfRef.cpu_top__DOT__idex_rd = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rd_out;
    vlSelfRef.cpu_top__DOT__idex_reg_write = vlSelfRef.cpu_top__DOT__idex_reg__DOT__reg_write_out;
    vlSelfRef.cpu_top__DOT__idex_mem_read = vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_read_out;
    vlSelfRef.cpu_top__DOT__idex_mem_write = vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_write_out;
    vlSelfRef.cpu_top__DOT__exmm_reg_write = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__reg_write_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_main 
        = ((~ (IData)(vlSelfRef.__SYM__interrupt)) 
           & (IData)(vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_reg_write));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__w_en_gpu 
        = vlSelfRef.cpu_top__DOT__gpu_write_en;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__w_result_gpu 
        = vlSelfRef.cpu_top__DOT__gpu_write_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__w_rd_gpu 
        = vlSelfRef.cpu_top__DOT__gpu_write_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__rs_gpu = vlSelfRef.cpu_top__DOT__gpu_read_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_a 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0xfU));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_b 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0x14U));
    if (vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_read_out) {
        vlSelfRef.cpu_top__DOT__exmm_mem_read = 1U;
        vlSelfRef.cpu_top__DOT__if_pc = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc;
        vlSelfRef.cpu_top__DOT__exmm_rd = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__mm_reg_write = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_reg_write;
        vlSelfRef.cpu_top__DOT__if_pc4 = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc4;
        vlSelfRef.cpu_top__DOT__interrupt = vlSelfRef.__SYM__interrupt;
        vlSelfRef.cpu_top__DOT__mm_rd = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd;
        vlSelfRef.cpu_top__DOT__wb_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data;
    } else {
        vlSelfRef.cpu_top__DOT__exmm_mem_read = 0U;
        vlSelfRef.cpu_top__DOT__if_pc = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc;
        vlSelfRef.cpu_top__DOT__exmm_rd = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__mm_reg_write = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_reg_write;
        vlSelfRef.cpu_top__DOT__if_pc4 = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc4;
        vlSelfRef.cpu_top__DOT__interrupt = vlSelfRef.__SYM__interrupt;
        vlSelfRef.cpu_top__DOT__mm_rd = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd;
        vlSelfRef.cpu_top__DOT__wb_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result;
    }
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__upper_bit_equal 
        = ((1U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr)) 
           == (1U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr)));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__lower_bits_equal 
        = ((7U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr)) 
           == (7U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr)));
    vlSelfRef.cpu_top__DOT__clk = vlSelfRef.clk;
    vlSelfRef.cpu_top__DOT__reset = vlSelfRef.reset;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options[0U] 
        = (4ULL + vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__pc_reg);
    vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__bra_offset 
        = (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                >> 0x1fU)))) << 0xcU) 
           | (QData)((IData)(((0x800U & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                         << 4U)) | 
                              ((0x7e0U & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                          >> 0x14U)) 
                               | (0x1eU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                           >> 7U)))))));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jal_offset 
        = (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                >> 0x1fU)))) << 0x14U) 
           | (QData)((IData)((((0xff000U & vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr) 
                               | (0x800U & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                            >> 9U))) 
                              | (0x7feU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                           >> 0x14U))))));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jalr_offset 
        = (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                >> 0x1fU)))) << 0xbU) 
           | (QData)((IData)((0x7ffU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                        >> 0x14U)))));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0x14U))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0x14U))];
    vlSelfRef.cpu_top__DOT__if_inst_valid = vlSelfRef.cpu_top__DOT__if_stage__DOT__M3__DOT__inst_valid;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0xfU))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0xfU))];
    vlSelfRef.cpu_top__DOT__global_stall = (1U & ((IData)(vlSelfRef.cpu_top__DOT__load_stall) 
                                                  | ((~ (IData)(vlSelfRef.dmem_ready)) 
                                                     | (IData)(vlSelfRef.cpu_top__DOT__if_stage__DOT__inst_buffer_full))));
    vlSelfRef.cpu_top__DOT__if_inst = vlSelfRef.cpu_top__DOT__if_stage__DOT__d_inst_word;
    vlSelfRef.cpu_top__DOT__mm_forward_rd = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out;
    vlSelfRef.cpu_top__DOT__ex_forward_rd = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rd_out;
    vlSelfRef.cpu_top__DOT__mm_mem_forward_rd = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd;
    vlSelfRef.cpu_top__DOT__mm_forward_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result;
    vlSelfRef.cpu_top__DOT__mm_mem_forward_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data;
    vlSelfRef.cpu_top__DOT__idex_rs1_data = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_data_out;
    vlSelfRef.cpu_top__DOT__idex_rs2_data = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_data_out;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_read_data 
        = vlSelfRef.cpu_top__DOT__dmem_read_data;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M3__DOT__pc 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_curr;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_alu_result 
        = vlSelfRef.cpu_top__DOT__exmm_alu_result;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_write_data 
        = vlSelfRef.cpu_top__DOT__exmm_write_data;
    vlSelfRef.cpu_top__DOT__wb_stage__DOT__walu = vlSelfRef.cpu_top__DOT__mm_alu_result;
    vlSelfRef.cpu_top__DOT__wb_stage__DOT__wmem = vlSelfRef.cpu_top__DOT__mm_mem_data;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_mem_write 
        = vlSelfRef.cpu_top__DOT__exmm_mem_write;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_in = vlSelfRef.cpu_top__DOT__idex_rd;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__reg_write_in 
        = vlSelfRef.cpu_top__DOT__idex_reg_write;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_read_in 
        = vlSelfRef.cpu_top__DOT__idex_mem_read;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_write_in 
        = vlSelfRef.cpu_top__DOT__idex_mem_write;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_reg_write 
        = vlSelfRef.cpu_top__DOT__exmm_reg_write;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__write_en 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_main;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_gpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__w_en_gpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_gpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__w_result_gpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_gpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__w_rd_gpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_gpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__rs_gpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__read_addr_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_a;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__read_addr_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_a;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__read_addr_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_b;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__read_addr_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_b;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_mem_read 
        = vlSelfRef.cpu_top__DOT__exmm_mem_read;
    vlSelfRef.cpu_top__DOT__wb_stage__DOT__wmem2reg 
        = vlSelfRef.cpu_top__DOT__exmm_mem_read;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__pc = vlSelfRef.cpu_top__DOT__if_pc;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_rd 
        = vlSelfRef.cpu_top__DOT__exmm_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_rd 
        = vlSelfRef.cpu_top__DOT__exmm_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__w_en = vlSelfRef.cpu_top__DOT__mm_reg_write;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__epc4 = vlSelfRef.cpu_top__DOT__if_pc4;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__pc4 = vlSelfRef.cpu_top__DOT__if_pc4;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__interrupt 
        = vlSelfRef.cpu_top__DOT__interrupt;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__w_rd = vlSelfRef.cpu_top__DOT__mm_rd;
    vlSelfRef.cpu_top__DOT__wb_stage__DOT__wdata = vlSelfRef.cpu_top__DOT__wb_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__w_result 
        = vlSelfRef.cpu_top__DOT__wb_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_empty 
        = ((IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__upper_bit_equal) 
           & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__lower_bits_equal));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag 
        = ((~ (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__upper_bit_equal)) 
           & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__lower_bits_equal));
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__clk = vlSelfRef.cpu_top__DOT__clk;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__clk = vlSelfRef.cpu_top__DOT__clk;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__clk 
        = vlSelfRef.cpu_top__DOT__clk;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__clk = vlSelfRef.cpu_top__DOT__clk;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__clk = vlSelfRef.cpu_top__DOT__clk;
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__rst = vlSelfRef.cpu_top__DOT__reset;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rst = vlSelfRef.cpu_top__DOT__reset;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__rst 
        = vlSelfRef.cpu_top__DOT__reset;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__reset = vlSelfRef.cpu_top__DOT__reset;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__reset = vlSelfRef.cpu_top__DOT__reset;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__inst 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__gen_imme__DOT__inst 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst;
    vlSelfRef.cpu_top__DOT__id_bra_addr = (vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc 
                                           + vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__bra_offset);
    vlSelfRef.cpu_top__DOT__id_jal_addr = (vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc 
                                           + vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jal_offset);
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_file_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_file_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stall = vlSelfRef.cpu_top__DOT__global_stall;
    vlSelfRef.pipeline_stall = vlSelfRef.cpu_top__DOT__global_stall;
    vlSelfRef.cpu_top__DOT__pipeline_stall = vlSelfRef.cpu_top__DOT__global_stall;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__stall = vlSelfRef.cpu_top__DOT__global_stall;
    vlSelfRef.cpu_top__DOT__id_rs1 = (0x1fU & (vlSelfRef.cpu_top__DOT__if_inst 
                                               >> 0xfU));
    vlSelfRef.cpu_top__DOT__id_rs2 = (0x1fU & (vlSelfRef.cpu_top__DOT__if_inst 
                                               >> 0x14U));
    vlSelfRef.cpu_top__DOT__id_rd = (0x1fU & (vlSelfRef.cpu_top__DOT__if_inst 
                                              >> 7U));
    vlSelfRef.cpu_top__DOT__id_reg_write = 0U;
    vlSelfRef.cpu_top__DOT__id_mem_read = 0U;
    vlSelfRef.cpu_top__DOT__id_mem_write = 0U;
    vlSelfRef.cpu_top__DOT__id_alu_op = 0U;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_word 
        = vlSelfRef.cpu_top__DOT__if_inst;
    vlSelfRef.cpu_top__DOT__id_has_imm = 0U;
    vlSelfRef.cpu_top__DOT__id_is_load = 0U;
    vlSelfRef.cpu_top__DOT__id_imm_type = 0U;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro_rs 
        = vlSelfRef.cpu_top__DOT__mm_forward_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro_rs 
        = vlSelfRef.cpu_top__DOT__ex_forward_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem_rs 
        = vlSelfRef.cpu_top__DOT__mm_mem_forward_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel 
        = (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                      >> 0x14U)) == (IData)(vlSelfRef.cpu_top__DOT__ex_forward_rd))
            ? 1U : (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                               >> 0x14U)) == (IData)(vlSelfRef.cpu_top__DOT__mm_forward_rd))
                     ? 2U : (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                        >> 0x14U)) 
                              == (IData)(vlSelfRef.cpu_top__DOT__mm_mem_forward_rd))
                              ? 3U : 0U)));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel 
        = (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                      >> 0xfU)) == (IData)(vlSelfRef.cpu_top__DOT__ex_forward_rd))
            ? 1U : (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                               >> 0xfU)) == (IData)(vlSelfRef.cpu_top__DOT__mm_forward_rd))
                     ? 2U : (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                        >> 0xfU)) == (IData)(vlSelfRef.cpu_top__DOT__mm_mem_forward_rd))
                              ? 3U : 0U)));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro = vlSelfRef.cpu_top__DOT__mm_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options[2U] 
        = vlSelfRef.cpu_top__DOT__mm_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options[2U] 
        = vlSelfRef.cpu_top__DOT__mm_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem = vlSelfRef.cpu_top__DOT__mm_mem_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options[3U] 
        = vlSelfRef.cpu_top__DOT__mm_mem_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options[3U] 
        = vlSelfRef.cpu_top__DOT__mm_mem_forward_data;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__ea = vlSelfRef.cpu_top__DOT__idex_rs1_data;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__eb = vlSelfRef.cpu_top__DOT__idex_rs2_data;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_in 
        = vlSelfRef.cpu_top__DOT__idex_rs2_data;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealu = (
                                                   (0x10U 
                                                    & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                    ? 
                                                   ((8U 
                                                     & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                     ? 0ULL
                                                     : 
                                                    ((4U 
                                                      & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                      ? 0ULL
                                                      : 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 0ULL
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        - 1ULL))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (1ULL 
                                                        + vlSelfRef.cpu_top__DOT__idex_rs1_data)
                                                        : 
                                                       ((vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         != vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                         ? 1ULL
                                                         : 0ULL)))))
                                                    : 
                                                   ((8U 
                                                     & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                     ? 
                                                    ((4U 
                                                      & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                      ? 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       ((vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         == vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                         ? 1ULL
                                                         : 0ULL)
                                                        : 
                                                       (~ vlSelfRef.cpu_top__DOT__idex_rs1_data))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? vlSelfRef.cpu_top__DOT__idex_rs2_data
                                                        : vlSelfRef.cpu_top__DOT__idex_rs1_data))
                                                      : 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       ((vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         < vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                         ? 1ULL
                                                         : 0ULL)
                                                        : 
                                                       (VL_LTS_IQQ(64, vlSelfRef.cpu_top__DOT__idex_rs1_data, vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                         ? 1ULL
                                                         : 0ULL))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       VL_SHIFTRS_QQI(64,64,5, vlSelfRef.cpu_top__DOT__idex_rs1_data, 
                                                                      (0x1fU 
                                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_rs2_data)))
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        >> 
                                                        (0x1fU 
                                                         & (IData)(vlSelfRef.cpu_top__DOT__idex_rs2_data))))))
                                                     : 
                                                    ((4U 
                                                      & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                      ? 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        << 
                                                        (0x1fU 
                                                         & (IData)(vlSelfRef.cpu_top__DOT__idex_rs2_data)))
                                                        : 
                                                       (~ 
                                                        (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         & vlSelfRef.cpu_top__DOT__idex_rs2_data)))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (~ 
                                                        (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         | vlSelfRef.cpu_top__DOT__idex_rs2_data))
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        ^ vlSelfRef.cpu_top__DOT__idex_rs2_data)))
                                                      : 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        | vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        & vlSelfRef.cpu_top__DOT__idex_rs2_data))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        - vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        + vlSelfRef.cpu_top__DOT__idex_rs2_data))))));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__write_en 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_gpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__data_in 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_gpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__write_addr 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_gpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__read_addr 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_gpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__pc 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__pc;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__pc;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__load_rd 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__load_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_cpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__w_en;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__pc4;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__interrupt 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__interrupt;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_cpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__w_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_cpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__w_result;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__inst_buffer_empty 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_empty;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_empty 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_empty;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_empty_flag 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_empty;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__inst_buffer_full 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_full 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__clk 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__clk;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__clk 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__clk;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__clk 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__clk;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__reset 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__reset;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__reset 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__reset;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__reset 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__reset;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__bra_addr 
        = vlSelfRef.cpu_top__DOT__id_bra_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__bra_addr 
        = vlSelfRef.cpu_top__DOT__id_bra_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__bra_addr 
        = vlSelfRef.cpu_top__DOT__id_bra_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options[1U] 
        = vlSelfRef.cpu_top__DOT__id_bra_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__jal_addr 
        = vlSelfRef.cpu_top__DOT__id_jal_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__jal_addr 
        = vlSelfRef.cpu_top__DOT__id_jal_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jal_addr 
        = vlSelfRef.cpu_top__DOT__id_jal_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options[2U] 
        = vlSelfRef.cpu_top__DOT__id_jal_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__file_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_file_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_file_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__file_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_file_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_file_out;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__stall 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__stall;
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_in = vlSelfRef.cpu_top__DOT__id_rs1;
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_in = vlSelfRef.cpu_top__DOT__id_rs2;
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__rd_in = vlSelfRef.cpu_top__DOT__id_rd;
    if (((IData)(vlSelfRef.cpu_top__DOT__if_inst_valid) 
         & (~ (IData)(vlSelfRef.cpu_top__DOT__global_stall)))) {
        if ((0x40U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((0x20U & vlSelfRef.cpu_top__DOT__if_inst)) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 4U)))) {
                    if ((8U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((4U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                    vlSelfRef.cpu_top__DOT__id_reg_write = 1U;
                                }
                            }
                        }
                    } else if ((4U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                vlSelfRef.cpu_top__DOT__id_reg_write = 1U;
                            }
                        }
                    }
                    if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                  >> 3U)))) {
                        if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                      >> 2U)))) {
                            if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                    vlSelfRef.cpu_top__DOT__id_alu_op = 0xfU;
                                }
                            }
                        }
                    }
                }
            }
        } else if ((0x20U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((0x10U & vlSelfRef.cpu_top__DOT__if_inst)) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 3U)))) {
                    if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                  >> 2U)))) {
                        if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                vlSelfRef.cpu_top__DOT__id_reg_write = 1U;
                                vlSelfRef.cpu_top__DOT__id_alu_op 
                                    = ((0x10U & (vlSelfRef.cpu_top__DOT__if_inst 
                                                 >> 0x1aU)) 
                                       | (0xeU & (vlSelfRef.cpu_top__DOT__if_inst 
                                                  >> 0xbU)));
                            }
                        }
                    }
                }
            } else if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                 >> 3U)))) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 2U)))) {
                    if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            vlSelfRef.cpu_top__DOT__id_alu_op = 0U;
                        }
                    }
                }
            }
        } else if ((0x10U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 3U)))) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 2U)))) {
                    if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            vlSelfRef.cpu_top__DOT__id_reg_write = 1U;
                            vlSelfRef.cpu_top__DOT__id_alu_op 
                                = (0xeU & (vlSelfRef.cpu_top__DOT__if_inst 
                                           >> 0xbU));
                        }
                    }
                }
            }
        } else if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                             >> 3U)))) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 2U)))) {
                if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                    if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        vlSelfRef.cpu_top__DOT__id_reg_write = 1U;
                        vlSelfRef.cpu_top__DOT__id_alu_op = 0U;
                    }
                }
            }
        }
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__reg_write_in 
            = vlSelfRef.cpu_top__DOT__id_reg_write;
        if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                      >> 6U)))) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 5U)))) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 4U)))) {
                    if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                  >> 3U)))) {
                        if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                      >> 2U)))) {
                            if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                    vlSelfRef.cpu_top__DOT__id_mem_read = 1U;
                                }
                            }
                        }
                    }
                }
            }
            if ((0x20U & vlSelfRef.cpu_top__DOT__if_inst)) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 4U)))) {
                    if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                  >> 3U)))) {
                        if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                      >> 2U)))) {
                            if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                    vlSelfRef.cpu_top__DOT__id_mem_write = 1U;
                                }
                            }
                        }
                    }
                }
            }
        }
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_read_in 
            = vlSelfRef.cpu_top__DOT__id_mem_read;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_write_in 
            = vlSelfRef.cpu_top__DOT__id_mem_write;
    } else {
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__reg_write_in 
            = vlSelfRef.cpu_top__DOT__id_reg_write;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_read_in 
            = vlSelfRef.cpu_top__DOT__id_mem_read;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_write_in 
            = vlSelfRef.cpu_top__DOT__id_mem_write;
    }
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_in 
        = (0xfU & ((IData)(vlSelfRef.cpu_top__DOT__id_alu_op) 
                   >> 0U));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__inst 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_word;
    if (((IData)(vlSelfRef.cpu_top__DOT__if_inst_valid) 
         & (~ (IData)(vlSelfRef.cpu_top__DOT__global_stall)))) {
        if ((0x40U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((0x20U & vlSelfRef.cpu_top__DOT__if_inst)) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 4U)))) {
                    if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                  >> 3U)))) {
                        if ((4U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                    vlSelfRef.cpu_top__DOT__id_has_imm = 1U;
                                }
                            }
                        }
                    }
                }
            }
        } else if ((0x20U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 4U)))) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 3U)))) {
                    if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                  >> 2U)))) {
                        if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                vlSelfRef.cpu_top__DOT__id_has_imm = 1U;
                            }
                        }
                    }
                }
            }
        } else if ((0x10U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 3U)))) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 2U)))) {
                    if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            vlSelfRef.cpu_top__DOT__id_has_imm = 1U;
                        }
                    }
                }
            }
        } else if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                             >> 3U)))) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 2U)))) {
                if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                    if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        vlSelfRef.cpu_top__DOT__id_has_imm = 1U;
                    }
                }
            }
        }
        vlSelfRef.cpu_top__DOT__id_stage__DOT__has_imm 
            = vlSelfRef.cpu_top__DOT__id_has_imm;
        if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                      >> 6U)))) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 5U)))) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 4U)))) {
                    if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                  >> 3U)))) {
                        if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                      >> 2U)))) {
                            if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                    vlSelfRef.cpu_top__DOT__id_is_load = 1U;
                                }
                            }
                        }
                    }
                }
            }
        }
    } else {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__has_imm 
            = vlSelfRef.cpu_top__DOT__id_has_imm;
    }
    vlSelfRef.cpu_top__DOT__id_stage__DOT__is_load 
        = vlSelfRef.cpu_top__DOT__id_is_load;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall 
        = ((IData)(vlSelfRef.cpu_top__DOT__id_is_load) 
           & (((IData)(vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out) 
               == (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                            >> 0xfU))) | ((IData)(vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out) 
                                          == (0x1fU 
                                              & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                                 >> 0x14U)))));
    if (((IData)(vlSelfRef.cpu_top__DOT__if_inst_valid) 
         & (~ (IData)(vlSelfRef.cpu_top__DOT__global_stall)))) {
        if ((0x40U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((0x20U & vlSelfRef.cpu_top__DOT__if_inst)) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 4U)))) {
                    if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                  >> 3U)))) {
                        if ((4U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                    vlSelfRef.cpu_top__DOT__id_imm_type = 0U;
                                }
                            }
                        }
                    }
                }
            }
        } else if ((0x20U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 4U)))) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 3U)))) {
                    if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                                  >> 2U)))) {
                        if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                vlSelfRef.cpu_top__DOT__id_imm_type = 2U;
                            }
                        }
                    }
                }
            }
        } else if ((0x10U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 3U)))) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 2U)))) {
                    if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            vlSelfRef.cpu_top__DOT__id_imm_type = 0U;
                        }
                    }
                }
            }
        } else if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                             >> 3U)))) {
            if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                          >> 2U)))) {
                if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                    if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        vlSelfRef.cpu_top__DOT__id_imm_type = 0U;
                    }
                }
            }
        }
    }
    vlSelfRef.cpu_top__DOT__id_stage__DOT__imm_type 
        = vlSelfRef.cpu_top__DOT__id_imm_type;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__gen_imme__DOT__imm 
        = ((2U & (IData)(vlSelfRef.cpu_top__DOT__id_imm_type))
            ? ((1U & (IData)(vlSelfRef.cpu_top__DOT__id_imm_type))
                ? ((QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                    >> 0xcU))) << 0x2cU)
                : (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                        >> 0x1fU)))) 
                    << 0xbU) | (QData)((IData)(((0x7e0U 
                                                 & (vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                                    >> 0x14U)) 
                                                | (0x1fU 
                                                   & (vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                                      >> 7U)))))))
            : ((1U & (IData)(vlSelfRef.cpu_top__DOT__id_imm_type))
                ? (QData)((IData)((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                            >> 0x14U))))
                : (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                        >> 0x1fU)))) 
                    << 0xbU) | (QData)((IData)((0x7ffU 
                                                & (vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                                   >> 0x14U)))))));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_pro_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_pro_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__ex_pro_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__ex_pro_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_mem_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_mem_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__sel 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__sel 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_pro 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_pro 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_mem 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_mem 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__eal = vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealu;
    vlSelfRef.cpu_top__DOT__ex_alu_result = vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealu;
    vlSelfRef.cpu_top__DOT__ex_forward_data = vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__write_en 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_cpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__sel 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__interrupt;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__sel 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__interrupt;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__write_addr 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_cpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__write_addr 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_cpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__data_in 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_cpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__data_in 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_cpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__clk 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__clk;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__clk 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__clk;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__clk 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__clk;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__clk 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__clk;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__reset 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__reset;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__reset 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__reset;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__reset 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__reset;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__reset 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__reset;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__data_in 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__inst;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_mux__DOT__sel 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__has_imm;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__is_load 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__is_load;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__stall 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__reg_stall 
        = ((IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall) 
           | (IData)(vlSelfRef.cpu_top__DOT__global_stall));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__gen_imme__DOT__imm_type 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__imm_type;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__gen_imme__DOT__imm;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_in 
        = vlSelfRef.cpu_top__DOT__ex_alu_result;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro = vlSelfRef.cpu_top__DOT__ex_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options[1U] 
        = vlSelfRef.cpu_top__DOT__ex_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options[1U] 
        = vlSelfRef.cpu_top__DOT__ex_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__stall 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__reg_stall;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_en 
        = (1U & (~ (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__reg_stall)));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__ex_pro 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__ex_pro 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__rs_equality__DOT__data_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_in[2U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [2U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_in[3U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [3U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__read_out_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_in[2U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [2U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_in[3U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [3U];
    vlSelfRef.cpu_top__DOT__id_read_out_a = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_out = 
        vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_is_equal = (vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
                                           [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel] 
                                           == vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
                                           [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel]);
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__dest 
        = (vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
           [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel] 
           + vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jalr_offset);
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_mux__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_mux__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__read_out_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [vlSelfRef.cpu_top__DOT__id_has_imm];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_mux__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [vlSelfRef.cpu_top__DOT__id_has_imm];
    vlSelfRef.cpu_top__DOT__id_read_out_b = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [vlSelfRef.cpu_top__DOT__id_has_imm];
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_data_in 
        = vlSelfRef.cpu_top__DOT__id_read_out_a;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__rs_equality__DOT__data_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__data_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__is_equal 
        = vlSelfRef.cpu_top__DOT__id_is_equal;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__rs_equality__DOT__is_equal 
        = vlSelfRef.cpu_top__DOT__id_is_equal;
    vlSelfRef.cpu_top__DOT__id_pc_sel = 0U;
    if (((IData)(vlSelfRef.cpu_top__DOT__if_inst_valid) 
         & (~ (IData)(vlSelfRef.cpu_top__DOT__global_stall)))) {
        if ((0x40U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((0x20U & vlSelfRef.cpu_top__DOT__if_inst)) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 4U)))) {
                    if ((8U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((4U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                    vlSelfRef.cpu_top__DOT__id_pc_sel = 2U;
                                }
                            }
                        }
                    } else if ((4U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                vlSelfRef.cpu_top__DOT__id_pc_sel = 3U;
                            }
                        }
                    } else if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            vlSelfRef.cpu_top__DOT__id_pc_sel 
                                = ((IData)(vlSelfRef.cpu_top__DOT__id_is_equal)
                                    ? 1U : 0U);
                        }
                    }
                }
            }
        }
    }
    vlSelfRef.cpu_top__DOT__id_jar_addr = (0xfffffffffffffffeULL 
                                           & vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__dest);
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_data_in 
        = vlSelfRef.cpu_top__DOT__id_read_out_b;
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__imm_in = vlSelfRef.cpu_top__DOT__id_read_out_b;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_sel = vlSelfRef.cpu_top__DOT__id_pc_sel;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__jar_addr 
        = vlSelfRef.cpu_top__DOT__id_jar_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__jar_addr 
        = vlSelfRef.cpu_top__DOT__id_jar_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jalr_addr 
        = vlSelfRef.cpu_top__DOT__id_jar_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options[3U] 
        = vlSelfRef.cpu_top__DOT__id_jar_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__sel 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_sel;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M3__DOT__pc_sel 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_sel;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [vlSelfRef.cpu_top__DOT__id_pc_sel];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [0U];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [1U];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_in[2U] 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [2U];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_in[3U] 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [3U];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [vlSelfRef.cpu_top__DOT__id_pc_sel];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__pc_next 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next;
}

void Vtop___024root___eval_triggers__ico(Vtop___024root* vlSelf);

bool Vtop___024root___eval_phase__ico(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__ico\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VicoExecute;
    // Body
    Vtop___024root___eval_triggers__ico(vlSelf);
    __VicoExecute = vlSelfRef.__VicoTriggered.any();
    if (__VicoExecute) {
        Vtop___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void Vtop___024root___eval_act(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_act\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vtop___024root___nba_sequent__TOP__0(Vtop___024root* vlSelf);
void Vtop___024root___nba_sequent__TOP__1(Vtop___024root* vlSelf);
void Vtop___024root___nba_sequent__TOP__2(Vtop___024root* vlSelf);
void Vtop___024root___nba_comb__TOP__0(Vtop___024root* vlSelf);
void Vtop___024root___nba_comb__TOP__1(Vtop___024root* vlSelf);
void Vtop___024root___nba_comb__TOP__2(Vtop___024root* vlSelf);

void Vtop___024root___eval_nba(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_nba\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vtop___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vtop___024root___nba_sequent__TOP__1(vlSelf);
    }
    if ((5ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vtop___024root___nba_sequent__TOP__2(vlSelf);
    }
    if ((3ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vtop___024root___nba_comb__TOP__0(vlSelf);
    }
    if ((5ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vtop___024root___nba_comb__TOP__1(vlSelf);
    }
    if ((7ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vtop___024root___nba_comb__TOP__2(vlSelf);
    }
}

VL_INLINE_OPT void Vtop___024root___nba_sequent__TOP__0(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___nba_sequent__TOP__0\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*3:0*/ __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr;
    __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr = 0;
    CData/*3:0*/ __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr;
    __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr = 0;
    IData/*31:0*/ __VdlyVal__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0;
    __VdlyVal__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0 = 0;
    CData/*2:0*/ __VdlyDim0__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0;
    __VdlyDim0__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0 = 0;
    CData/*0:0*/ __VdlySet__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0;
    __VdlySet__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0 = 0;
    // Body
    __VdlySet__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0 = 0U;
    __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr;
    __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr;
    if (vlSelfRef.reset) {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4_reg = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc_reg = 0ULL;
        vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__pc_reg = 0ULL;
        __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr = 0U;
        __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr = 0U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr = 0U;
    } else {
        if (vlSelfRef.cpu_top__DOT__id_stage__DOT__reg_stall) {
            vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4_reg 
                = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4_reg;
            vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc_reg 
                = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc_reg;
        } else {
            vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4_reg 
                = vlSelfRef.cpu_top__DOT__if_pc4;
            vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc_reg 
                = vlSelfRef.cpu_top__DOT__if_pc;
        }
        vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__pc_reg 
            = ((IData)(vlSelfRef.cpu_top__DOT__global_stall)
                ? vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__pc_reg
                : vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next);
        if ((1U & ((~ (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__reg_stall)) 
                   & (~ (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag))))) {
            __VdlyVal__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0 
                = vlSelfRef.cpu_top__DOT__if_inst;
            __VdlyDim0__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0 
                = (7U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr));
            __VdlySet__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0 = 1U;
            __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr 
                = (0xfU & ((IData)(1U) + (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr)));
        }
        vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
            = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer
            [(7U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr))];
        __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr 
            = (0xfU & ((IData)(1U) + (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr)));
    }
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr 
        = __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr;
    if (__VdlySet__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0) {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer[__VdlyDim0__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0] 
            = __VdlyVal__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_buffer__v0;
    }
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr 
        = __Vdly__cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__d_pc4 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4_reg;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__d_pc4 = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc4_reg;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__d_pc 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc_reg;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__d_pc = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__pc_reg;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_curr 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__pc_reg;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options[0U] 
        = (4ULL + vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__pc_reg);
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__upper_bit_equal 
        = ((1U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr)) 
           == (1U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr)));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__lower_bits_equal 
        = ((7U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_ptr)) 
           == (7U & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__read_ptr)));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__rs1_addr 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0xfU));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__rs2_addr 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0x14U));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__file_out_rs 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0xfU));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__file_out_rs 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0x14U));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst_next 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__d_inst 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__d_inst_next 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_a 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0xfU));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_b 
        = (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                    >> 0x14U));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__bra_offset 
        = (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                >> 0x1fU)))) << 0xcU) 
           | (QData)((IData)(((0x800U & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                         << 4U)) | 
                              ((0x7e0U & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                          >> 0x14U)) 
                               | (0x1eU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                           >> 7U)))))));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jal_offset 
        = (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                >> 0x1fU)))) << 0x14U) 
           | (QData)((IData)((((0xff000U & vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr) 
                               | (0x800U & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                            >> 9U))) 
                              | (0x7feU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                           >> 0x14U))))));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jalr_offset 
        = (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                >> 0x1fU)))) << 0xbU) 
           | (QData)((IData)((0x7ffU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                        >> 0x14U)))));
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M3__DOT__pc 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_curr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_empty 
        = ((IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__upper_bit_equal) 
           & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__lower_bits_equal));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag 
        = ((~ (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__upper_bit_equal)) 
           & (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__lower_bits_equal));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__read_addr_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_a;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__read_addr_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_a;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__read_addr_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_b;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__read_addr_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__read_addr_b;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__inst 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__gen_imme__DOT__inst 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__gen_imme__DOT__imm 
        = ((2U & (IData)(vlSelfRef.cpu_top__DOT__id_imm_type))
            ? ((1U & (IData)(vlSelfRef.cpu_top__DOT__id_imm_type))
                ? ((QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                    >> 0xcU))) << 0x2cU)
                : (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                        >> 0x1fU)))) 
                    << 0xbU) | (QData)((IData)(((0x7e0U 
                                                 & (vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                                    >> 0x14U)) 
                                                | (0x1fU 
                                                   & (vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                                      >> 7U)))))))
            : ((1U & (IData)(vlSelfRef.cpu_top__DOT__id_imm_type))
                ? (QData)((IData)((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                            >> 0x14U))))
                : (((- (QData)((IData)((vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                        >> 0x1fU)))) 
                    << 0xbU) | (QData)((IData)((0x7ffU 
                                                & (vlSelfRef.cpu_top__DOT__id_stage__DOT__d_inst 
                                                   >> 0x14U)))))));
    vlSelfRef.cpu_top__DOT__id_bra_addr = (vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc 
                                           + vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__bra_offset);
    vlSelfRef.cpu_top__DOT__id_jal_addr = (vlSelfRef.cpu_top__DOT__if_stage__DOT__d_pc 
                                           + vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jal_offset);
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__inst_buffer_empty 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_empty;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_empty 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_empty;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_empty_flag 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_empty;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__inst_buffer_full 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__inst_buffer_full 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__is_full_flag;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__gen_imme__DOT__imm;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__bra_addr 
        = vlSelfRef.cpu_top__DOT__id_bra_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__bra_addr 
        = vlSelfRef.cpu_top__DOT__id_bra_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__bra_addr 
        = vlSelfRef.cpu_top__DOT__id_bra_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options[1U] 
        = vlSelfRef.cpu_top__DOT__id_bra_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__jal_addr 
        = vlSelfRef.cpu_top__DOT__id_jal_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__jal_addr 
        = vlSelfRef.cpu_top__DOT__id_jal_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jal_addr 
        = vlSelfRef.cpu_top__DOT__id_jal_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options[2U] 
        = vlSelfRef.cpu_top__DOT__id_jal_addr;
}

VL_INLINE_OPT void Vtop___024root___nba_sequent__TOP__1(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___nba_sequent__TOP__1\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v0;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v0 = 0;
    QData/*63:0*/ __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32;
    __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32 = 0;
    CData/*4:0*/ __VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32;
    __VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32 = 0;
    CData/*0:0*/ __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32 = 0;
    CData/*0:0*/ __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v0;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v0 = 0;
    QData/*63:0*/ __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32;
    __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32 = 0;
    CData/*4:0*/ __VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32;
    __VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32 = 0;
    CData/*0:0*/ __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32 = 0;
    CData/*0:0*/ __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v0;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v0 = 0;
    QData/*63:0*/ __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32;
    __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32 = 0;
    CData/*4:0*/ __VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32;
    __VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32 = 0;
    CData/*0:0*/ __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32 = 0;
    // Body
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v0 = 0U;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32 = 0U;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v0 = 0U;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32 = 0U;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v0 = 0U;
    __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32 = 0U;
    if (vlSelfRef.reset) {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 1U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 2U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 3U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 4U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 5U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 6U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 7U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 8U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 9U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0xaU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0xbU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0xcU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0xdU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0xeU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0xfU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x10U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x11U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x12U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x13U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x14U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x15U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x16U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x17U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x18U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x19U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x1aU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x1bU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x1cU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x1dU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x1eU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x1fU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__unnamedblk1__DOT__i = 0x20U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 1U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 2U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 3U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 4U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 5U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 6U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 7U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 8U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 9U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0xaU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0xbU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0xcU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0xdU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0xeU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0xfU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x10U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x11U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x12U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x13U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x14U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x15U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x16U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x17U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x18U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x19U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x1aU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x1bU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x1cU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x1dU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x1eU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x1fU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__unnamedblk1__DOT__i = 0x20U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 1U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 2U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 3U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 4U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 5U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 6U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 7U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 8U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 9U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0xaU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0xbU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0xcU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0xdU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0xeU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0xfU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x10U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x11U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x12U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x13U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x14U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x15U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x16U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x17U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x18U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x19U;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x1aU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x1bU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x1cU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x1dU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x1eU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x1fU;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__unnamedblk1__DOT__i = 0x20U;
        __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v0 = 1U;
        __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v0 = 1U;
        __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v0 = 1U;
    } else {
        if (((IData)(vlSelfRef.cpu_top__DOT__gpu_write_en) 
             & (0U != (IData)(vlSelfRef.cpu_top__DOT__gpu_write_addr)))) {
            __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32 
                = vlSelfRef.cpu_top__DOT__gpu_write_data;
            __VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32 
                = vlSelfRef.cpu_top__DOT__gpu_write_addr;
            __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32 = 1U;
        }
        if (((IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_main) 
             & (0U != (IData)(vlSelfRef.cpu_top__DOT__mm_rd)))) {
            __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32 
                = vlSelfRef.cpu_top__DOT__wb_data;
            __VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32 
                = vlSelfRef.cpu_top__DOT__mm_rd;
            __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32 = 1U;
        }
        if (((IData)(vlSelfRef.cpu_top__DOT__mm_reg_write) 
             & (0U != (IData)(vlSelfRef.cpu_top__DOT__mm_rd)))) {
            __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32 
                = vlSelfRef.cpu_top__DOT__wb_data;
            __VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32 
                = vlSelfRef.cpu_top__DOT__mm_rd;
            __VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32 = 1U;
        }
    }
    if (__VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v0) {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[1U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[2U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[3U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[4U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[5U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[6U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[7U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[8U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[9U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0xaU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0xbU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0xcU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0xdU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0xeU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0xfU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x10U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x11U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x12U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x13U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x14U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x15U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x16U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x17U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x18U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x19U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x1aU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x1bU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x1cU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x1dU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x1eU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[0x1fU] = 0ULL;
    }
    if (__VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32) {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers[__VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32] 
            = __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers__v32;
    }
    if (__VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v0) {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[1U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[2U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[3U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[4U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[5U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[6U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[7U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[8U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[9U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0xaU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0xbU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0xcU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0xdU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0xeU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0xfU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x10U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x11U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x12U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x13U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x14U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x15U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x16U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x17U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x18U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x19U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x1aU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x1bU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x1cU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x1dU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x1eU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[0x1fU] = 0ULL;
    }
    if (__VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32) {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers[__VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32] 
            = __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers__v32;
    }
    if (__VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v0) {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[1U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[2U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[3U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[4U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[5U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[6U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[7U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[8U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[9U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0xaU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0xbU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0xcU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0xdU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0xeU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0xfU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x10U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x11U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x12U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x13U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x14U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x15U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x16U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x17U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x18U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x19U] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x1aU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x1bU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x1cU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x1dU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x1eU] = 0ULL;
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[0x1fU] = 0ULL;
    }
    if (__VdlySet__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32) {
        vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers[__VdlyDim0__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32] 
            = __VdlyVal__cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers__v32;
    }
    vlSelfRef.cpu_top__DOT__id_stage__DOT__read_out_gpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers
        [vlSelfRef.cpu_top__DOT__gpu_read_addr];
    vlSelfRef.cpu_top__DOT__id_read_out_gpu = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers
        [vlSelfRef.cpu_top__DOT__gpu_read_addr];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_gpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers
        [vlSelfRef.cpu_top__DOT__gpu_read_addr];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__gpu__DOT__registers
        [vlSelfRef.cpu_top__DOT__gpu_read_addr];
}

VL_INLINE_OPT void Vtop___024root___nba_sequent__TOP__2(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___nba_sequent__TOP__2\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.reset) {
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_write_data = 0ULL;
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_addr = 0ULL;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_out = 0U;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_out = 0U;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__imm_out = 0ULL;
        vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_out = 0ULL;
        vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out = 0ULL;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rd_out = 0U;
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd = 0U;
        vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out = 0U;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_data_out = 0ULL;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out = 0U;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_data_out = 0ULL;
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result = 0ULL;
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data = 0ULL;
    } else {
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_write_data 
            = vlSelfRef.cpu_top__DOT__exmm_write_data;
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_addr 
            = vlSelfRef.cpu_top__DOT__exmm_alu_result;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_out 
            = vlSelfRef.cpu_top__DOT__id_rs1;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_out 
            = vlSelfRef.cpu_top__DOT__id_rs2;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__imm_out 
            = vlSelfRef.cpu_top__DOT__id_read_out_b;
        vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_out 
            = vlSelfRef.cpu_top__DOT__ex_alu_result;
        vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out 
            = vlSelfRef.cpu_top__DOT__idex_rs2_data;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rd_out 
            = vlSelfRef.cpu_top__DOT__id_rd;
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd 
            = vlSelfRef.cpu_top__DOT__exmm_rd;
        vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out 
            = vlSelfRef.cpu_top__DOT__idex_rd;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_data_out 
            = vlSelfRef.cpu_top__DOT__id_read_out_a;
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out 
            = (0xfU & (IData)(vlSelfRef.cpu_top__DOT__id_alu_op));
        vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_data_out 
            = vlSelfRef.cpu_top__DOT__id_read_out_b;
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result 
            = vlSelfRef.cpu_top__DOT__exmm_alu_result;
        vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data 
            = ((IData)(vlSelfRef.cpu_top__DOT__exmm_mem_read)
                ? vlSelfRef.dmem_read_data : 0ULL);
    }
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_write 
        = ((1U & (~ (IData)(vlSelfRef.reset))) && (IData)(vlSelfRef.cpu_top__DOT__exmm_mem_write));
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_read 
        = ((1U & (~ (IData)(vlSelfRef.reset))) && (IData)(vlSelfRef.cpu_top__DOT__exmm_mem_read));
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__reg_write_out 
        = ((1U & (~ (IData)(vlSelfRef.reset))) && (IData)(vlSelfRef.cpu_top__DOT__idex_reg_write));
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__reg_write_out 
        = ((1U & (~ (IData)(vlSelfRef.reset))) && (IData)(vlSelfRef.cpu_top__DOT__id_reg_write));
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_read_out 
        = ((1U & (~ (IData)(vlSelfRef.reset))) && (IData)(vlSelfRef.cpu_top__DOT__id_mem_read));
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_write_out 
        = ((1U & (~ (IData)(vlSelfRef.reset))) && (IData)(vlSelfRef.cpu_top__DOT__id_mem_write));
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_write_out 
        = ((1U & (~ (IData)(vlSelfRef.reset))) && (IData)(vlSelfRef.cpu_top__DOT__idex_mem_write));
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_reg_write 
        = ((1U & (~ (IData)(vlSelfRef.reset))) && (IData)(vlSelfRef.cpu_top__DOT__exmm_reg_write));
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_read_out 
        = ((1U & (~ (IData)(vlSelfRef.reset))) && (IData)(vlSelfRef.cpu_top__DOT__idex_mem_read));
    vlSelfRef.cpu_top__DOT__idex_rs1 = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_out;
    vlSelfRef.cpu_top__DOT__idex_rs2 = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_out;
    vlSelfRef.cpu_top__DOT__idex_imm = vlSelfRef.cpu_top__DOT__idex_reg__DOT__imm_out;
    vlSelfRef.cpu_top__DOT__exmm_reg_write = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__reg_write_out;
    vlSelfRef.cpu_top__DOT__idex_reg_write = vlSelfRef.cpu_top__DOT__idex_reg__DOT__reg_write_out;
    vlSelfRef.cpu_top__DOT__idex_mem_read = vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_read_out;
    vlSelfRef.cpu_top__DOT__idex_mem_write = vlSelfRef.cpu_top__DOT__idex_reg__DOT__mem_write_out;
    vlSelfRef.dmem_write = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_write_out;
    vlSelfRef.cpu_top__DOT__dmem_write = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_write_out;
    vlSelfRef.cpu_top__DOT__exmm_mem_write = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_write_out;
    vlSelfRef.dmem_addr = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_out;
    vlSelfRef.cpu_top__DOT__dmem_addr = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_out;
    vlSelfRef.cpu_top__DOT__exmm_alu_result = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_main 
        = ((~ (IData)(vlSelfRef.__SYM__interrupt)) 
           & (IData)(vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_reg_write));
    vlSelfRef.cpu_top__DOT__mm_reg_write = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_reg_write;
    if (vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_read_out) {
        vlSelfRef.dmem_read = 1U;
        vlSelfRef.cpu_top__DOT__dmem_read = 1U;
        vlSelfRef.cpu_top__DOT__exmm_mem_read = 1U;
        vlSelfRef.dmem_write_data = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out;
        vlSelfRef.cpu_top__DOT__dmem_write_data = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out;
        vlSelfRef.cpu_top__DOT__exmm_write_data = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out;
        vlSelfRef.cpu_top__DOT__idex_rd = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__ex_forward_rd = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__mm_rd = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd;
        vlSelfRef.cpu_top__DOT__mm_mem_forward_rd = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd;
        vlSelfRef.cpu_top__DOT__exmm_rd = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__mm_forward_rd = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__idex_rs1_data = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_data_out;
        vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealuc 
            = vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out;
        vlSelfRef.cpu_top__DOT__idex_alu_op = vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out;
        vlSelfRef.cpu_top__DOT__idex_rs2_data = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_data_out;
        vlSelfRef.cpu_top__DOT__mm_alu_result = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result;
        vlSelfRef.cpu_top__DOT__mm_forward_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result;
        vlSelfRef.cpu_top__DOT__mm_mem_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data;
        vlSelfRef.cpu_top__DOT__wb_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data;
    } else {
        vlSelfRef.dmem_read = 0U;
        vlSelfRef.cpu_top__DOT__dmem_read = 0U;
        vlSelfRef.cpu_top__DOT__exmm_mem_read = 0U;
        vlSelfRef.dmem_write_data = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out;
        vlSelfRef.cpu_top__DOT__dmem_write_data = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out;
        vlSelfRef.cpu_top__DOT__exmm_write_data = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_out;
        vlSelfRef.cpu_top__DOT__idex_rd = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__ex_forward_rd = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__mm_rd = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd;
        vlSelfRef.cpu_top__DOT__mm_mem_forward_rd = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_rd;
        vlSelfRef.cpu_top__DOT__exmm_rd = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__mm_forward_rd = vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out;
        vlSelfRef.cpu_top__DOT__idex_rs1_data = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_data_out;
        vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealuc 
            = vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out;
        vlSelfRef.cpu_top__DOT__idex_alu_op = vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out;
        vlSelfRef.cpu_top__DOT__idex_rs2_data = vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_data_out;
        vlSelfRef.cpu_top__DOT__mm_alu_result = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result;
        vlSelfRef.cpu_top__DOT__mm_forward_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result;
        vlSelfRef.cpu_top__DOT__mm_mem_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data;
        vlSelfRef.cpu_top__DOT__wb_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_alu_result;
    }
    vlSelfRef.cpu_top__DOT__mm_mem_forward_data = vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__mem_wb_mem_data;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_reg_write 
        = vlSelfRef.cpu_top__DOT__exmm_reg_write;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__reg_write_in 
        = vlSelfRef.cpu_top__DOT__idex_reg_write;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_read_in 
        = vlSelfRef.cpu_top__DOT__idex_mem_read;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__mem_write_in 
        = vlSelfRef.cpu_top__DOT__idex_mem_write;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_mem_write 
        = vlSelfRef.cpu_top__DOT__exmm_mem_write;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_alu_result 
        = vlSelfRef.cpu_top__DOT__exmm_alu_result;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__write_en 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_main;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__w_en = vlSelfRef.cpu_top__DOT__mm_reg_write;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_mem_read 
        = vlSelfRef.cpu_top__DOT__exmm_mem_read;
    vlSelfRef.cpu_top__DOT__wb_stage__DOT__wmem2reg 
        = vlSelfRef.cpu_top__DOT__exmm_mem_read;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_write_data 
        = vlSelfRef.cpu_top__DOT__exmm_write_data;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_in = vlSelfRef.cpu_top__DOT__idex_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro_rs 
        = vlSelfRef.cpu_top__DOT__ex_forward_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__w_rd = vlSelfRef.cpu_top__DOT__mm_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem_rs 
        = vlSelfRef.cpu_top__DOT__mm_mem_forward_rd;
    vlSelfRef.cpu_top__DOT__mm_stage_inst__DOT__ex_mem_rd 
        = vlSelfRef.cpu_top__DOT__exmm_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_rd 
        = vlSelfRef.cpu_top__DOT__exmm_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro_rs 
        = vlSelfRef.cpu_top__DOT__mm_forward_rd;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__ea = vlSelfRef.cpu_top__DOT__idex_rs1_data;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__eb = vlSelfRef.cpu_top__DOT__idex_rs2_data;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__write_data_in 
        = vlSelfRef.cpu_top__DOT__idex_rs2_data;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealu = (
                                                   (0x10U 
                                                    & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                    ? 
                                                   ((8U 
                                                     & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                     ? 0ULL
                                                     : 
                                                    ((4U 
                                                      & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                      ? 0ULL
                                                      : 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 0ULL
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        - 1ULL))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (1ULL 
                                                        + vlSelfRef.cpu_top__DOT__idex_rs1_data)
                                                        : 
                                                       ((vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         != vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                         ? 1ULL
                                                         : 0ULL)))))
                                                    : 
                                                   ((8U 
                                                     & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                     ? 
                                                    ((4U 
                                                      & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                      ? 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       ((vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         == vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                         ? 1ULL
                                                         : 0ULL)
                                                        : 
                                                       (~ vlSelfRef.cpu_top__DOT__idex_rs1_data))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? vlSelfRef.cpu_top__DOT__idex_rs2_data
                                                        : vlSelfRef.cpu_top__DOT__idex_rs1_data))
                                                      : 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       ((vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         < vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                         ? 1ULL
                                                         : 0ULL)
                                                        : 
                                                       (VL_LTS_IQQ(64, vlSelfRef.cpu_top__DOT__idex_rs1_data, vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                         ? 1ULL
                                                         : 0ULL))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       VL_SHIFTRS_QQI(64,64,5, vlSelfRef.cpu_top__DOT__idex_rs1_data, 
                                                                      (0x1fU 
                                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_rs2_data)))
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        >> 
                                                        (0x1fU 
                                                         & (IData)(vlSelfRef.cpu_top__DOT__idex_rs2_data))))))
                                                     : 
                                                    ((4U 
                                                      & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                      ? 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        << 
                                                        (0x1fU 
                                                         & (IData)(vlSelfRef.cpu_top__DOT__idex_rs2_data)))
                                                        : 
                                                       (~ 
                                                        (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         & vlSelfRef.cpu_top__DOT__idex_rs2_data)))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (~ 
                                                        (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                         | vlSelfRef.cpu_top__DOT__idex_rs2_data))
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        ^ vlSelfRef.cpu_top__DOT__idex_rs2_data)))
                                                      : 
                                                     ((2U 
                                                       & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                       ? 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        | vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        & vlSelfRef.cpu_top__DOT__idex_rs2_data))
                                                       : 
                                                      ((1U 
                                                        & (IData)(vlSelfRef.cpu_top__DOT__idex_reg__DOT__alu_op_out))
                                                        ? 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        - vlSelfRef.cpu_top__DOT__idex_rs2_data)
                                                        : 
                                                       (vlSelfRef.cpu_top__DOT__idex_rs1_data 
                                                        + vlSelfRef.cpu_top__DOT__idex_rs2_data))))));
    vlSelfRef.cpu_top__DOT__wb_stage__DOT__walu = vlSelfRef.cpu_top__DOT__mm_alu_result;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro = vlSelfRef.cpu_top__DOT__mm_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options[2U] 
        = vlSelfRef.cpu_top__DOT__mm_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options[2U] 
        = vlSelfRef.cpu_top__DOT__mm_forward_data;
    vlSelfRef.cpu_top__DOT__wb_stage__DOT__wmem = vlSelfRef.cpu_top__DOT__mm_mem_data;
    vlSelfRef.cpu_top__DOT__wb_stage__DOT__wdata = vlSelfRef.cpu_top__DOT__wb_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__w_result 
        = vlSelfRef.cpu_top__DOT__wb_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem = vlSelfRef.cpu_top__DOT__mm_mem_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options[3U] 
        = vlSelfRef.cpu_top__DOT__mm_mem_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options[3U] 
        = vlSelfRef.cpu_top__DOT__mm_mem_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_cpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__w_en;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__ex_pro_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__ex_pro_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_cpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__w_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_mem_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_mem_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__load_rd 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__load_rd;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_pro_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro_rs;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_pro_rs 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro_rs;
    vlSelfRef.cpu_top__DOT__ex_stage__DOT__eal = vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealu;
    vlSelfRef.cpu_top__DOT__ex_alu_result = vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealu;
    vlSelfRef.cpu_top__DOT__ex_forward_data = vlSelfRef.cpu_top__DOT__ex_stage__DOT__ealu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_pro 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_pro 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_pro;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_cpu 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__w_result;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__mm_mem 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__mm_mem 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__mm_mem;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__write_en 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_en_cpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__write_addr 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_cpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__write_addr 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__write_addr_cpu;
    vlSelfRef.cpu_top__DOT__exmm_reg__DOT__alu_result_in 
        = vlSelfRef.cpu_top__DOT__ex_alu_result;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro = vlSelfRef.cpu_top__DOT__ex_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options[1U] 
        = vlSelfRef.cpu_top__DOT__ex_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options[1U] 
        = vlSelfRef.cpu_top__DOT__ex_forward_data;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__data_in 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_cpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__data_in 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_in_cpu;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__ex_pro 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__ex_pro 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__ex_pro;
}

VL_INLINE_OPT void Vtop___024root___nba_comb__TOP__0(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___nba_comb__TOP__0\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__data_out_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0xfU))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__data_out_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0x14U))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0x14U))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__main__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0xfU))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__data_out_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0xfU))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__data_out_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0x14U))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0x14U))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__shadow__DOT__registers
        [(0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                   >> 0xfU))];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__b_out__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_file_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_b_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__a_out__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_file_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__register_file__DOT__data_out_a_options
        [vlSelfRef.__SYM__interrupt];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__file_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_file_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_file_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__file_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_file_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_file_out;
}

VL_INLINE_OPT void Vtop___024root___nba_comb__TOP__1(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___nba_comb__TOP__1\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall 
        = ((IData)(vlSelfRef.cpu_top__DOT__id_is_load) 
           & (((IData)(vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out) 
               == (0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                            >> 0xfU))) | ((IData)(vlSelfRef.cpu_top__DOT__exmm_reg__DOT__rd_out) 
                                          == (0x1fU 
                                              & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                                 >> 0x14U)))));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel 
        = (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                      >> 0x14U)) == (IData)(vlSelfRef.cpu_top__DOT__ex_forward_rd))
            ? 1U : (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                               >> 0x14U)) == (IData)(vlSelfRef.cpu_top__DOT__mm_forward_rd))
                     ? 2U : (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                        >> 0x14U)) 
                              == (IData)(vlSelfRef.cpu_top__DOT__mm_mem_forward_rd))
                              ? 3U : 0U)));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel 
        = (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                      >> 0xfU)) == (IData)(vlSelfRef.cpu_top__DOT__ex_forward_rd))
            ? 1U : (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                               >> 0xfU)) == (IData)(vlSelfRef.cpu_top__DOT__mm_forward_rd))
                     ? 2U : (((0x1fU & (vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__inst_curr 
                                        >> 0xfU)) == (IData)(vlSelfRef.cpu_top__DOT__mm_mem_forward_rd))
                              ? 3U : 0U)));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall_check__DOT__stall 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__reg_stall 
        = ((IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__load_stall) 
           | (IData)(vlSelfRef.cpu_top__DOT__global_stall));
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__sel 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__sel 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__stall 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__reg_stall;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__stage2__DOT__insts__DOT__write_en 
        = (1U & (~ (IData)(vlSelfRef.cpu_top__DOT__id_stage__DOT__reg_stall)));
}

VL_INLINE_OPT void Vtop___024root___nba_comb__TOP__2(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___nba_comb__TOP__2\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_in[2U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [2U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_in[3U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [3U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_in[2U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [2U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_in[3U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [3U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__rs_equality__DOT__data_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_selection__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__read_out_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_selection__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_read_out_a = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__a_out = 
        vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
        [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel];
    vlSelfRef.cpu_top__DOT__id_is_equal = (vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
                                           [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel] 
                                           == vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_options
                                           [vlSelfRef.cpu_top__DOT__id_stage__DOT__b_bypass__DOT__bypass_sel]);
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__dest 
        = (vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_options
           [vlSelfRef.cpu_top__DOT__id_stage__DOT__a_bypass__DOT__bypass_sel] 
           + vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jalr_offset);
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_mux__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [0U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_mux__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [1U];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__read_out_b 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [vlSelfRef.cpu_top__DOT__id_has_imm];
    vlSelfRef.cpu_top__DOT__id_stage__DOT__b_mux__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [vlSelfRef.cpu_top__DOT__id_has_imm];
    vlSelfRef.cpu_top__DOT__id_read_out_b = vlSelfRef.cpu_top__DOT__id_stage__DOT__b_out_options
        [vlSelfRef.cpu_top__DOT__id_has_imm];
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs1_data_in 
        = vlSelfRef.cpu_top__DOT__id_read_out_a;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__rs_equality__DOT__data_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__data_a 
        = vlSelfRef.cpu_top__DOT__id_stage__DOT__a_out;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__is_equal 
        = vlSelfRef.cpu_top__DOT__id_is_equal;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__rs_equality__DOT__is_equal 
        = vlSelfRef.cpu_top__DOT__id_is_equal;
    vlSelfRef.cpu_top__DOT__id_pc_sel = 0U;
    if (((IData)(vlSelfRef.cpu_top__DOT__if_inst_valid) 
         & (~ (IData)(vlSelfRef.cpu_top__DOT__global_stall)))) {
        if ((0x40U & vlSelfRef.cpu_top__DOT__if_inst)) {
            if ((0x20U & vlSelfRef.cpu_top__DOT__if_inst)) {
                if ((1U & (~ (vlSelfRef.cpu_top__DOT__if_inst 
                              >> 4U)))) {
                    if ((8U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((4U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                    vlSelfRef.cpu_top__DOT__id_pc_sel = 2U;
                                }
                            }
                        }
                    } else if ((4U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                                vlSelfRef.cpu_top__DOT__id_pc_sel = 3U;
                            }
                        }
                    } else if ((2U & vlSelfRef.cpu_top__DOT__if_inst)) {
                        if ((1U & vlSelfRef.cpu_top__DOT__if_inst)) {
                            vlSelfRef.cpu_top__DOT__id_pc_sel 
                                = ((IData)(vlSelfRef.cpu_top__DOT__id_is_equal)
                                    ? 1U : 0U);
                        }
                    }
                }
            }
        }
    }
    vlSelfRef.cpu_top__DOT__id_jar_addr = (0xfffffffffffffffeULL 
                                           & vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__dest);
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__rs2_data_in 
        = vlSelfRef.cpu_top__DOT__id_read_out_b;
    vlSelfRef.cpu_top__DOT__idex_reg__DOT__imm_in = vlSelfRef.cpu_top__DOT__id_read_out_b;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_sel = vlSelfRef.cpu_top__DOT__id_pc_sel;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__jar_addr 
        = vlSelfRef.cpu_top__DOT__id_jar_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__jar_addr 
        = vlSelfRef.cpu_top__DOT__id_jar_addr;
    vlSelfRef.cpu_top__DOT__id_stage__DOT__branch_addrs__DOT__jalr_addr 
        = vlSelfRef.cpu_top__DOT__id_jar_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options[3U] 
        = vlSelfRef.cpu_top__DOT__id_jar_addr;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__sel 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_sel;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M3__DOT__pc_sel 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_sel;
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_out 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [vlSelfRef.cpu_top__DOT__id_pc_sel];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_in[0U] 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [0U];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_in[1U] 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [1U];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_in[2U] 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [2U];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M1__DOT__data_in[3U] 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [3U];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next_options
        [vlSelfRef.cpu_top__DOT__id_pc_sel];
    vlSelfRef.cpu_top__DOT__if_stage__DOT__M2__DOT__pc_next 
        = vlSelfRef.cpu_top__DOT__if_stage__DOT__pc_next;
}

void Vtop___024root___eval_triggers__act(Vtop___024root* vlSelf);

bool Vtop___024root___eval_phase__act(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__act\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<3> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vtop___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vtop___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vtop___024root___eval_phase__nba(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__nba\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vtop___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__ico(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__nba(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__act(Vtop___024root* vlSelf);
#endif  // VL_DEBUG

void Vtop___024root___eval(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VicoIterCount;
    CData/*0:0*/ __VicoContinue;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VicoIterCount = 0U;
    vlSelfRef.__VicoFirstIteration = 1U;
    __VicoContinue = 1U;
    while (__VicoContinue) {
        if (VL_UNLIKELY(((0x64U < __VicoIterCount)))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__ico(vlSelf);
#endif
            VL_FATAL_MT("/home/jackn/Documents/GithubRepos/2025-AMDHardware-CPU/tb/../src/cpu_top.sv", 1, "", "Input combinational region did not converge.");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        __VicoContinue = 0U;
        if (Vtop___024root___eval_phase__ico(vlSelf)) {
            __VicoContinue = 1U;
        }
        vlSelfRef.__VicoFirstIteration = 0U;
    }
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY(((0x64U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("/home/jackn/Documents/GithubRepos/2025-AMDHardware-CPU/tb/../src/cpu_top.sv", 1, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY(((0x64U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vtop___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("/home/jackn/Documents/GithubRepos/2025-AMDHardware-CPU/tb/../src/cpu_top.sv", 1, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vtop___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vtop___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vtop___024root___eval_debug_assertions(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_debug_assertions\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clk & 0xfeU)))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY(((vlSelfRef.reset & 0xfeU)))) {
        Verilated::overWidthError("reset");}
    if (VL_UNLIKELY(((vlSelfRef.__SYM__interrupt & 0xfeU)))) {
        Verilated::overWidthError("__SYM__interrupt");}
    if (VL_UNLIKELY(((vlSelfRef.imem_ready & 0xfeU)))) {
        Verilated::overWidthError("imem_ready");}
    if (VL_UNLIKELY(((vlSelfRef.dmem_ready & 0xfeU)))) {
        Verilated::overWidthError("dmem_ready");}
}
#endif  // VL_DEBUG
