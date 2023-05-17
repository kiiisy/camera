// ---------------------------------------------------------------------
// File name         : sccb_top.sv
// Module name       : sccb_top
// Created by        : kiiisy
// Module Description: sccb top module
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 13-May-2023 | kiiisy  |    initial
// --------------------------------------------------------------------
module sccb_top(
clk_25m,
rst_n,
sda,
scl,
init_done
);

input  wire  clk_25m;
input  wire  rst_n;
output wire  sda;
output wire  scl;
output wire  init_done;

reg          clk_200k;
wire  [ 7:0] addr_rom;
wire  [15:0] sreg;


sccb_if U_sccb_if(
    .clk_25m   ( clk_25m   ), // in
    .rst_n     ( rst_n     ), // in
    .sda       ( sda       ), // out
    .scl       ( scl       ), // out
    .init_done ( init_done ), // out
    .clk_200k  ( clk_200k  ), // out
    .addr_rom  ( addr_rom  ), // out
    .sreg      ( sreg      )  // in
);

sccb_rom U_sccb_rom(
    .clk_200k  ( clk_200k  ), // in
    .rst_n     ( rst_n     ), // in
    .addr      ( addr_rom  ), // in
    .sreg      ( sreg      )  // out
);

endmodule