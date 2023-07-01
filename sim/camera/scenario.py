import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

# define
HMAX = 10
VMAX = 5
RESET_TIME_NS = 20


# Init Function
async def init(_dut, duration_time):
    _dut.rst_n.value = 0
    _dut.vsync.value = 0
    _dut.href.value = 0
    _dut.data_i.value = 0
    await Timer(duration_time, units="ns")
    _dut.rst_n.value = 1


# Generate pixdata Function
async def generate_pixdata(hmax):
    # Generate 0 to 9 array data
    pixdata = [data for data in range(hmax)]
    return pixdata


# TestBench
@cocotb.test()
async def tb_scenario(dut):
    _dut = dut
    # Wait 20ns
    await init(_dut, RESET_TIME_NS)

    # Generate clock 25MHz
    clk = Clock(dut.clk, 40, units="ns")

    # Start scenario
    cocotb.start_soon(clk.start(start_high=False))

    # Wait 10us
    await Timer(10, units="us")

    pixdata = await generate_pixdata(HMAX)

    for _ in range(VMAX):
        await RisingEdge(dut.clk)

        # Enable Vsync
        dut.vsync.value = 1
        await RisingEdge(dut.clk)

        # Insert TestBench-data into dut module
        for data in pixdata:
            # Enable Href
            dut.href.value = 1
            dut.data_i.value = data
            await RisingEdge(dut.clk)
            dut._log.info("vfb_data: 0x%x", dut.vfb_data.value)

        # Disable Href and data
        dut.href.value = 0
        await RisingEdge(dut.clk)
        # Disable Vsync
        dut.vsync.value = 0
