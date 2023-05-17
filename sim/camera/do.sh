# RTL directory
TOP_MODULE=camera_sim
OUT_FILE=scenario.out

# compile
iverilog -g2012  \
    -o ${OUT_FILE} \
    -s ${TOP_MODULE} ./scenario.sv ../../src/camera/camera_top.sv  ../../src/camera/camera_if.sv ../../src/camera/camera_pg.sv

# simulation
vvp ${OUT_FILE}