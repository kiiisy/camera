# RTL directory
TOP_MODULE=uart_top_sim
OUT_FILE=scenario.out

# compile
iverilog -g2012  \
    -o ${OUT_FILE} \
    -s ${TOP_MODULE} ./scenario.sv ../../src/uart/uart_top.sv ../../src/uart/uart_rx.sv ../../src/uart/uart_tx.sv

# simulation
vvp ${OUT_FILE}