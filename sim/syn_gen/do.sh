# RTL directory
TOP_MODULE=syn_gen_sim
OUT_FILE=scenario.out

# compile
iverilog -g2012  \
    -o ${OUT_FILE} \
    -s ${TOP_MODULE} ./scenario.sv ../../src/syn_gen.v

# simulation
vvp ${OUT_FILE}