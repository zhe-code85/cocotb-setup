import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def test_counter_counts_when_enabled(dut):
    """Reset the counter, then verify increment and hold behavior."""

    dut.rst_n.value = 0
    dut.en.value = 0

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start(start_high=False))

    for _ in range(2):
        await RisingEdge(dut.clk)
        await Timer(1, unit="step")

    assert int(dut.count.value) == 0

    dut.rst_n.value = 1
    dut.en.value = 1

    for expected in range(1, 5):
        await RisingEdge(dut.clk)
        await Timer(1, unit="step")
        assert int(dut.count.value) == expected

    dut.en.value = 0

    for _ in range(2):
        await RisingEdge(dut.clk)
        await Timer(1, unit="step")
        assert int(dut.count.value) == 4
