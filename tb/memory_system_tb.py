import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def reset_dut(dut):
    """Reset DUT and initialize all inputs"""
    dut.rst_n.value = 0
    dut.imem_addr.value = 0
    dut.imem_read.value = 0
    dut.dmem_addr.value = 0
    dut.dmem_write_data.value = 0
    dut.dmem_read.value = 0
    dut.dmem_write.value = 0
    dut.dmem_byte_enable.value = 0
    dut.cache_flush.value = 0
    dut.cache_invalidate.value = 0

    for _ in range(2):
        await RisingEdge(dut.clk)

    dut.rst_n.value = 1
    await RisingEdge(dut.clk)


# Helper routines ---------------------------------------------------------


async def imem_fetch(dut, addr):
    dut.imem_addr.value = addr
    dut.imem_read.value = 1
    await RisingEdge(dut.clk)
    assert dut.imem_ready.value.integer == 1
    data = dut.imem_read_data.value.integer
    dut.imem_read.value = 0
    await RisingEdge(dut.clk)
    return data


async def dmem_write(dut, addr, data, byte_en):
    dut.dmem_addr.value = addr
    dut.dmem_write_data.value = data
    dut.dmem_byte_enable.value = byte_en
    dut.dmem_write.value = 1
    await RisingEdge(dut.clk)
    assert dut.dmem_ready.value.integer == 1
    dut.dmem_write.value = 0
    dut.dmem_byte_enable.value = 0
    await RisingEdge(dut.clk)


async def dmem_read(dut, addr):
    dut.dmem_addr.value = addr
    dut.dmem_read.value = 1
    await RisingEdge(dut.clk)
    assert dut.dmem_ready.value.integer == 1
    data = dut.dmem_read_data.value.integer
    dut.dmem_read.value = 0
    await RisingEdge(dut.clk)
    return data


async def flush_caches(dut, invalidate=False):
    if invalidate:
        dut.cache_invalidate.value = 1
    else:
        dut.cache_flush.value = 1
    await RisingEdge(dut.clk)
    dut.cache_invalidate.value = 0
    dut.cache_flush.value = 0
    await RisingEdge(dut.clk)


# Testcases ---------------------------------------------------------------


@cocotb.test()
async def test_instruction_cache_behavior(dut):
    """Exercise instruction cache including flush/invalidate and counters"""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # Preload instruction memory
    dut.inst_mem[0].value = 0x00000013  # NOP
    dut.inst_mem[1].value = 0x00100093  # ADDI x1, x0, 1
    dut.inst_mem[2].value = 0x00200113  # ADDI x2, x0, 2

    # Fetch sequence to generate hits and misses
    assert await imem_fetch(dut, 0) == 0x00000013  # miss
    assert dut.cache_hit_count.value.integer == 0
    assert await imem_fetch(dut, 0) == 0x00000013  # hit
    assert dut.cache_hit_count.value.integer == 1

    assert await imem_fetch(dut, 4) == 0x00100093  # miss (new tag)
    assert dut.cache_hit_count.value.integer == 1
    assert await imem_fetch(dut, 4) == 0x00100093  # hit
    assert dut.cache_hit_count.value.integer == 2

    # Invalidate cache and refetch
    await flush_caches(dut, invalidate=True)
    assert await imem_fetch(dut, 0) == 0x00000013  # miss after invalidate
    assert dut.cache_hit_count.value.integer == 2
    assert await imem_fetch(dut, 0) == 0x00000013  # hit again
    assert dut.cache_hit_count.value.integer == 3

    # Performance counter check
    assert dut.imem_access_count.value.integer == 6


@cocotb.test()
async def test_data_memory_operations(dut):
    """Verify byte enables, cache behaviour and counter for data memory"""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # Preload data memory and read back twice (second read hits cache)
    dut.data_mem[0].value = 0x89ABCDEF
    assert await dmem_read(dut, 0) == 0x89ABCDEF
    assert await dmem_read(dut, 0) == 0x89ABCDEF

    # Full word write and verify
    await dmem_write(dut, 4, 0xDEADBEEF, 0xF)
    assert await dmem_read(dut, 4) == 0xDEADBEEF

    # Byte write (SB) to middle byte
    await dmem_write(dut, 4, 0x0000CC00, 0b0010)
    assert await dmem_read(dut, 4) == 0xDEADCCEF

    # Halfword write (SH) to lower half
    await dmem_write(dut, 4, 0x000055AA, 0b0011)
    assert await dmem_read(dut, 4) == 0xDEAD55AA

    # Verify data access counter
    assert dut.dmem_access_count.value.integer == 8


@cocotb.test()
async def test_cache_flush_and_concurrent_ports(dut):
    """Issue concurrent instruction/data ops and exercise flush control"""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # Preload instruction and data memories
    dut.inst_mem[0].value = 0x00000013
    dut.inst_mem[1].value = 0x00100093
    dut.data_mem[0].value = 0x12345678

    async def instr_task():
        assert await imem_fetch(dut, 0) == 0x00000013
        await flush_caches(dut)  # flush via cache_flush
        assert await imem_fetch(dut, 0) == 0x00000013

    async def data_task():
        assert await dmem_read(dut, 0) == 0x12345678
        await dmem_write(dut, 0, 0x87654321, 0xF)
        assert await dmem_read(dut, 0) == 0x87654321

    # Run tasks concurrently to stress dual ports
    await cocotb.start(instr_task())
    await cocotb.start(data_task())

    # After flush, cache should have been invalidated causing miss then hit
    assert dut.cache_hit_count.value.integer == 1
    assert dut.imem_access_count.value.integer == 2
    assert dut.dmem_access_count.value.integer == 3


@cocotb.test()
async def test_out_of_range_access(dut):
    """Ensure out-of-range accesses return RV32I defaults"""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    assert await imem_fetch(dut, 0x8000) == 0x00000013
    assert await dmem_read(dut, 0x8000) == 0
