//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.09 Education
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Tue May  2 08:51:34 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    rPLL1 your_instance_name(
        .clkout(clkout_o), //output clkout
        .lock(lock_o), //output lock
        .reset(reset_i), //input reset
        .clkin(clkin_i) //input clkin
    );

//--------Copy end-------------------
