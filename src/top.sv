// ---------------------------------------------------------------------
// File name         : top.sv
// Module name       : top
// Created by        : kiiisy
// Module Description: top module
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 13-May-2023 | kiiisy  |    initial
// --------------------------------------------------------------------
module top(
CLK_27M,
RST_N,
LED,
UART_RX,
UART_TX,
XCLK,
PCLK,
SCL,
SDA,
VSYNC,
HREF,
PIXDATA,
O_tmds_clk_p,
O_tmds_clk_n,
O_tmds_data_p,
O_tmds_data_n,
O_psram_ck,   
O_psram_ck_n,
IO_psram_dq, 
IO_psram_rwds,
O_psram_cs_n,
O_psram_reset_n
);

input    wire          CLK_27M;
input    wire          RST_N;
output   wire  [ 5: 0] LED;
// UART
input    wire          UART_RX;
output   wire          UART_TX;
// OV7060 Interface
output   wire          XCLK;
input    wire          PCLK;
output   wire          SCL;
output   wire          SDA;
input    wire          VSYNC;
input    wire          HREF;
input    wire  [ 7: 0] PIXDATA;
// DVI Interface
output   wire          O_tmds_clk_p;
output   wire          O_tmds_clk_n;
output   wire  [ 2: 0] O_tmds_data_p;
output   wire  [ 2: 0] O_tmds_data_n;
// PSRAM Interface
output   wire  [ 1: 0] O_psram_ck;   
output   wire  [ 1: 0] O_psram_ck_n;
inout    wire  [15: 0] IO_psram_dq;
inout    wire  [ 1: 0] IO_psram_rwds;
output   wire  [ 1: 0] O_psram_cs_n;
output   wire  [ 1: 0] O_psram_reset_n;

localparam N = 2; //delay N clocks

wire                   pll_rst;
wire                   clk_25m;
wire                   clk_126m;
wire                   clk_168m;
wire                   clk_84m;
reg                    lock_en_1;
reg                    lock_en_2;
// sccb
reg                    init_done;
// frame buffer in
wire                   vfb_clk;
wire                   vfb_vs_n;
wire                   vfb_de;
wire  [15:0]           vfb_data;
// PSRAM(User I/F)
wire                   init_calib;
wire                   cmd;
wire  [20: 0]          addr;
wire                   cmd_en;
wire                   rd_data_valid;
wire  [63: 0]          wr_data;
wire  [63: 0]          rd_data;
wire  [ 7: 0]          data_mask;
// syn_code
wire                   out_de;
wire                   syn_off0_re;
wire                   syn_off0_vs;
wire                   syn_off0_hs;
wire                   off0_syn_de;
wire  [15: 0]          off0_syn_data;

reg   [N-1: 0]         Pout_hs_dn;
reg   [N-1: 0]         Pout_vs_dn;
reg   [N-1: 0]         Pout_de_dn;
// rgb data
wire                   rgb_vs;
wire                   rgb_hs;
wire                   rgb_de;
wire  [23: 0]          rgb_data;
// UART data
reg   [ 8: 0]          uart_data;
wire                   uart_is_ready;


// DVI(serial) clock
rPLL1 U_rPLL1(
     .clkout             ( clk_126m        ), // out
     .lock               ( lock_en_1       ), // out
     .reset              ( ~RST_N          ), // in
     .clkin              ( CLK_27M         )  // in
);

// PSRAM clock
rPLL2 U_rPLL2(
     .clkout             ( clk_168m        ), // out
     .lock               ( lock_en_2       ), // out
     .clkoutd3           (                 ), // out
     .reset              ( ~RST_N          ), // in
     .clkin              ( CLK_27M         )  // in
);

// Camera Clock(div5)
clkdiv1 U_clkdiv1(
    .clkout              ( clk_25m         ), // out
    .hclkin              ( clk_126m        ), // in
    .resetn              ( RST_N           )  // in
);

assign pll_rst = RST_N & ~lock_en_1 & ~lock_en_2;
assign XCLK    = clk_25m;

// simでの動作確認済み(実機は未)
//uart_top U_uart_top(
//    .clk                ( XCLK            ), // in
//    .rst_n              ( ~pll_rst        ), // in
//    .rxd                ( UART_RX         ), // in
//    .txd                ( UART_TX         ), // out
//    .data               ( uart_data       ), // out
//    .uart_is_ready      ( uart_is_ready   )  // out
//);

sccb_top U_sccb_top(
    .clk_25m            ( XCLK            ), // in
    .rst_n              ( ~pll_rst        ), // in
    .sda                ( SDA             ), // out
    .scl                ( SCL             ), // out
    .init_done          ( init_done       )  // out
);

// レジスタ設定完了用(LEDは負論理)
assign LED = {5'b11111,~init_done};

camera_top #(
    .DUMMY_MODE         ( 1'b0            ) // 0:real camera, 1:dummy camera
)U_camera_top(
    .clk                ( PCLK            ), // in
    .xclk               ( XCLK            ), // in
    .rst_n              ( ~pll_rst        ), // in
    .vsync              ( VSYNC           ), // in
    .href               ( HREF            ), // in
    .data_i             ( PIXDATA         ), // in
    .vfb_clk            ( vfb_clk         ), // out
    .vfb_vs_n           ( vfb_vs_n        ), // out
    .vfb_de             ( vfb_de          ), // out
    .vfb_data           ( vfb_data        )  // out
);

Video_Frame_Buffer_Top U_Video_Frame_Buffer_Top(
	.I_rst_n            ( ~pll_rst        ), // in
	.I_dma_clk          ( clk_84m         ), // in
	.I_wr_halt          ( 1'd0            ), // in
	.I_rd_halt          ( 1'd0            ), // in
    // Video input
	.I_vin0_clk         ( vfb_clk         ), // in
	.I_vin0_vs_n        ( vfb_vs_n        ), // in
	.I_vin0_de          ( vfb_de          ), // in
	.I_vin0_data        ( vfb_data        ), // in
	.O_vin0_fifo_full   ( /* no use */    ), // out
    // Video output
	.I_vout0_clk        ( XCLK            ), // in
	.I_vout0_vs_n       ( ~syn_off0_vs    ), // in
	.I_vout0_de         ( syn_off0_re     ), // in
	.O_vout0_den        ( off0_syn_de     ), // out
	.O_vout0_data       ( off0_syn_data   ), // out
	.O_vout0_fifo_empty ( /* no use */    ), // out
    // PSRAM Interface
	.O_cmd              ( cmd             ), // out
	.O_cmd_en           ( cmd_en          ), // out
	.O_addr             ( addr            ), // out
	.O_wr_data          ( wr_data         ), // out
	.O_data_mask        ( data_mask       ), // out
	.I_rd_data_valid    ( rd_data_valid   ), // in
	.I_rd_data          ( rd_data         ), // in
	.I_init_calib       ( init_calib      )  // in
);
    
always@(posedge pll_rst or posedge XCLK) begin
    if(pll_rst) begin
        Pout_hs_dn  <= {N{1'b1}};
        Pout_vs_dn  <= {N{1'b1}};
        Pout_de_dn  <= {N{1'b0}};
    end else begin
        Pout_hs_dn  <= {Pout_hs_dn[N-2:0],syn_off0_hs};
        Pout_vs_dn  <= {Pout_vs_dn[N-2:0],syn_off0_vs};
        Pout_de_dn  <= {Pout_de_dn[N-2:0],out_de};
    end
end
    
PSRAM_Memory_Interface_HS_Top U_PSRAM_Memory_Interface_HS_Top(
	.clk                ( CLK_27M         ), // in
	.memory_clk         ( clk_168m        ), // in
	.pll_lock           ( lock_en_2       ), // in
	.rst_n              ( ~pll_rst        ), // in
    // User Interface
	.wr_data            ( wr_data         ), // in
	.rd_data            ( rd_data         ), // out
	.rd_data_valid      ( rd_data_valid   ), // out
	.addr               ( addr            ), // in
	.cmd                ( cmd             ), // in
	.cmd_en             ( cmd_en          ), // in
	.init_calib         ( init_calib      ), // out
	.clk_out            ( clk_84m         ), // out
	.data_mask          ( data_mask       ), // in
    // PSRAM Interface
	.O_psram_ck         ( O_psram_ck      ), // out
	.O_psram_ck_n       ( O_psram_ck_n    ), // out
	.IO_psram_dq        ( IO_psram_dq     ), // inout
	.IO_psram_rwds      ( IO_psram_rwds   ), // inout
	.O_psram_cs_n       ( O_psram_cs_n    ), // out
	.O_psram_reset_n    ( O_psram_reset_n )  // out
);

syn_gen U_syn_gen(                                   
    .I_pxl_clk          ( XCLK            ), // in
    .I_rst_n            ( ~pll_rst        ), // in
    .I_h_total          ( 16'd800         ), // in
    .I_h_sync           ( 16'd96          ), // in
    .I_h_bporch         ( 16'd48          ), // in
    .I_h_res            ( 16'd640         ), // in
    .I_v_total          ( 16'd525         ), // in
    .I_v_sync           ( 16'd2           ), // in
    .I_v_bporch         ( 16'd33          ), // in
    .I_v_res            ( 16'd480         ), // in
    .I_rd_hres          ( 16'd640         ), // in
    .I_rd_vres          ( 16'd480         ), // in
    .I_hs_pol           ( 1'b1            ), // in HS polarity , 0:負極性，1：正極性
    .I_vs_pol           ( 1'b1            ), // in VS polarity , 0:負極性，1：正極性
    .O_rden             ( syn_off0_re     ), // out
    .O_de               ( out_de          ), // out
    .O_hs               ( syn_off0_hs     ), // out
    .O_vs               ( syn_off0_vs     )  // out
);

//==============================================================================
//TMDS TX
assign rgb_data    = off0_syn_de ? {off0_syn_data[15:11],3'd0,off0_syn_data[10:5],2'd0,off0_syn_data[4:0],3'd0} : 24'h0000ff;
assign rgb_vs      = Pout_vs_dn[N-1];
assign rgb_hs      = Pout_hs_dn[N-1];
assign rgb_de      = Pout_de_dn[N-1];

DVI_TX_Top U_DVI_TX_Top(
	.I_rst_n            ( ~pll_rst        ), // in
    .I_serial_clk       ( clk_126m        ), // in
	.I_rgb_clk          ( XCLK            ), // in
	.I_rgb_vs           ( rgb_vs          ), // in
	.I_rgb_hs           ( rgb_hs          ), // in
	.I_rgb_de           ( rgb_de          ), // in
	.I_rgb_r            ( rgb_data[23:16] ), // in
	.I_rgb_g            ( rgb_data[15: 8] ), // in
	.I_rgb_b            ( rgb_data[ 7: 0] ), // in
	.O_tmds_clk_p       ( O_tmds_clk_p    ), // out
	.O_tmds_clk_n       ( O_tmds_clk_n    ), // out
	.O_tmds_data_p      ( O_tmds_data_p   ), // out
	.O_tmds_data_n      ( O_tmds_data_n   )  // out
);

endmodule