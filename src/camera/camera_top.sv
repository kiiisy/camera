// ---------------------------------------------------------------------
// File name         : camera_top.sv
// Module name       : camera_top
// Created by        : kiiisy
// Module Description: camera top module
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 13-May-2023 | kiiisy  |    initial
// --------------------------------------------------------------------
module camera_top(
clk,
xclk,
rst_n,
vsync,
href,
data_i,
vfb_clk,
vfb_vs_n,
vfb_de,
vfb_data
);

parameter DUMMY_MODE = 1'd0;

input    wire         clk;
input    wire         xclk;
input    wire         rst_n;
input    wire         vsync;
input    wire         href;
input    wire  [ 7:0] data_i;
output   wire         vfb_clk;
output   wire         vfb_vs_n;
output   wire         vfb_de;
output   wire  [15:0] vfb_data;

// Real Camera
wire                  pclk;
wire  [15:0]          data_o;
// Pattern Generater
wire                  pg_vs;
wire                  pg_hs;
wire                  pg_de;
wire   [ 7:0]         pg_data_r;
wire   [ 7:0]         pg_data_g;
wire   [ 7:0]         pg_data_b;



camera_if U_camera_if(
    .clk             ( clk               ), // in
    .rst_n           ( rst_n             ), // in
    .href            ( href              ), // in
    .data_i          ( data_i            ), // in
    .pclk            ( pclk              ), // out
    .data_o          ( data_o            )  // out
);

camera_pg U_camera_pg(
    .I_pxl_clk       (xclk               ), // in
    .I_rst_n         (rst_n              ), // in
    .I_single_r      (8'd0               ), // in
    .I_single_g      (8'd255             ), // in
    .I_single_b      (8'd0               ), // in
    .I_h_total       (12'd800            ), // in
    .I_h_sync        (12'd96             ), // in
    .I_h_bporch      (12'd48             ), // in
    .I_h_res         (12'd640            ), // in
    .I_v_total       (12'd525            ), // in
    .I_v_sync        (12'd2              ), // in
    .I_v_bporch      (12'd33             ), // in
    .I_v_res         (12'd480            ), // in
    .I_hs_pol        (1'b1               ), // in
    .I_vs_pol        (1'b1               ), // in
    .O_de            (pg_de              ), // out
    .O_hs            (pg_hs              ), // out
    .O_vs            (pg_vs              ), // out
    .O_data_r        (pg_data_r          ), // out
    .O_data_g        (pg_data_g          ), // out
    .O_data_b        (pg_data_b          )  // out
);

assign vfb_clk  = DUMMY_MODE ? xclk : pclk;
assign vfb_vs_n = DUMMY_MODE ? ~pg_vs : ~vsync;
assign vfb_de   = DUMMY_MODE ? pg_de : href;
assign vfb_data = DUMMY_MODE ? {pg_data_r[7:3],pg_data_g[7:2],pg_data_b[7:3]} : data_o;

endmodule