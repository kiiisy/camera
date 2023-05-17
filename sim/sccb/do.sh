# RTL directory
TOP_MODULE=sccb_top_sim
OUT_FILE=scenario.out

# compile
iverilog -g2012  \
    -o ${OUT_FILE} \
    -s ${TOP_MODULE} ./scenario.sv ../src/sccb/sccb_if.v ../src/sccb/sccb_rom.v

# simulation
vvp ${OUT_FILE}