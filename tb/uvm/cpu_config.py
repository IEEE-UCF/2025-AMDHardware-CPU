"""
Configuration file for UVM-style CPU testbench
"""

# Test configuration
TEST_CONFIG = {
    # Number of instructions for each test type
    'sanity_instructions': 50,
    'load_store_instructions': 100,
    'branch_instructions': 75,
    'jump_instructions': 50,
    'multiply_instructions': 100,
    'atomic_instructions': 50,
    'stress_instructions': 500,
    'regression_instructions': 1000,
    
    # Clock period in nanoseconds (100MHz = 10ns)
    'clock_period_ns': 10,
    
    # Reset duration in clock cycles
    'reset_cycles': 5,
    
    # Memory configuration
    'imem_size': 32768,  # 32KB instruction memory
    'dmem_size': 32768,  # 32KB data memory
    'memory_base': 0x0000,
    
    # Register file configuration
    'num_registers': 32,
    
    # Pipeline configuration
    'pipeline_stages': 5,  # IF, ID, EX, MEM, WB
    
    # Extension support
    'enable_m_extension': True,  # Multiply/Divide
    'enable_a_extension': True,  # Atomic operations
    
    # Test weights for random instruction generation
    'instruction_weights': {
        'alu': 0.3,
        'load': 0.15,
        'store': 0.15,
        'branch': 0.15,
        'jump': 0.1,
        'multiply': 0.1,
        'atomic': 0.05
    },
    
    # Hazard detection settings
    'enable_hazard_detection': True,
    'enable_forwarding': True,
    
    # Debug settings
    'enable_logging': True,
    'log_level': 'INFO',  # DEBUG, INFO, WARNING, ERROR
    'enable_waveforms': True,
    'enable_coverage': True,
    
    # Performance expectations
    'max_cpi': 2.0,  # Maximum cycles per instruction
    'min_frequency_mhz': 100,  # Minimum operating frequency
    
    # Test timeouts (in simulation cycles)
    'test_timeout_cycles': 10000,
    'instruction_timeout_cycles': 100,
    
    # Randomization seeds for reproducible tests
    'random_seed': 42,
    
    # Verification settings
    'enable_scoreboard': True,
    'enable_functional_coverage': True,
    'check_register_writes': True,
    'check_memory_accesses': True,
    'check_pc_progression': True,
}

# Instruction opcodes for reference
OPCODES = {
    'LUI': 0x37,
    'AUIPC': 0x17,
    'JAL': 0x6F,
    'JALR': 0x67,
    'BRANCH': 0x63,
    'LOAD': 0x03,
    'STORE': 0x23,
    'OP_IMM': 0x13,
    'OP': 0x33,
    'MISC_MEM': 0x0F,
    'SYSTEM': 0x73,
    'AMO': 0x2F,
}

# ALU function codes
ALU_FUNCT3 = {
    'ADD_SUB': 0,
    'SLL': 1,
    'SLT': 2,
    'SLTU': 3,
    'XOR': 4,
    'SRL_SRA': 5,
    'OR': 6,
    'AND': 7,
}

# Branch function codes
BRANCH_FUNCT3 = {
    'BEQ': 0,
    'BNE': 1,
    'BLT': 4,
    'BGE': 5,
    'BLTU': 6,
    'BGEU': 7,
}

# Load function codes
LOAD_FUNCT3 = {
    'LB': 0,
    'LH': 1,
    'LW': 2,
    'LBU': 4,
    'LHU': 5,
}

# Store function codes
STORE_FUNCT3 = {
    'SB': 0,
    'SH': 1,
    'SW': 2,
}

# M extension function codes
M_FUNCT3 = {
    'MUL': 0,
    'MULH': 1,
    'MULHSU': 2,
    'MULHU': 3,
    'DIV': 4,
    'DIVU': 5,
    'REM': 6,
    'REMU': 7,
}

# A extension function codes (funct5)
A_FUNCT5 = {
    'LR': 2,
    'SC': 3,
    'AMOSWAP': 1,
    'AMOADD': 0,
    'AMOXOR': 4,
    'AMOAND': 12,
    'AMOOR': 8,
    'AMOMIN': 16,
    'AMOMAX': 20,
    'AMOMINU': 24,
    'AMOMAXU': 28,
}

# Coverage bins for functional coverage
COVERAGE_BINS = {
    'opcodes': list(OPCODES.values()),
    'registers': list(range(32)),
    'immediates': [-2048, -1, 0, 1, 2047],
    'memory_addresses': [0x0, 0x1000, 0x2000, 0x4000, 0x7FFF],
    'alu_operations': list(ALU_FUNCT3.values()),
    'branch_conditions': list(BRANCH_FUNCT3.values()),
}

# Expected results for corner cases
CORNER_CASE_EXPECTED = {
    'nop': {'pc_increment': 4, 'reg_change': False},
    'x0_write': {'x0_value': 0, 'reg_change': False},
    'max_positive_imm': {'result_sign': 'positive'},
    'max_negative_imm': {'result_sign': 'negative'},
}

def get_config(key: str, default=None):
    """Get configuration value with optional default"""
    return TEST_CONFIG.get(key, default)

def update_config(**kwargs):
    """Update configuration values"""
    TEST_CONFIG.update(kwargs)
