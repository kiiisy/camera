//Copyright (C)2014-2021 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.7.02 Beta
//Created Time: 2021-06-01 10:34:02

//create_clock
create_clock -name CLK_27M -period 37.037 -waveform {0 18.518} [get_ports {CLK_27M}] -add
create_clock -name PCLK -period 40 -waveform {0 20} [get_ports {PCLK}] -add

create_clock -name clk_126m -period 7.936 -waveform {0 3.968} [get_nets {clk_126m}] -add
create_clock -name clk_168m -period 5.952 -waveform {0 2.976} [get_nets {clk_168m}] -add

create_generated_clock -name XCLK -source [get_nets {clk_126m}] -divide_by 5 [get_ports {XCLK}] -add
create_generated_clock -name clk_84m -source [get_nets {clk_168m}] -divide_by 2 [get_nets {clk_84m}] -add

//false_path
set_false_path -from [get_clocks {CLK_27M}] -to [get_clocks {clk_84m}]
set_false_path -from [get_clocks {CLK_27M}] -to [get_clocks {clk_168m}]