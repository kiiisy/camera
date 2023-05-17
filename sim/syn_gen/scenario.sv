//////////////////////////////////////////////////////////////
// モジュール :syn_gen_sim
// 概要      :シナリオトップ
// 内容      :シナリオトップ
// 変更履歴   :2023/5/13 kiiisy 新規作成
/////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module syn_gen_sim;

// Create clock
parameter CLK_25MHz_PERIOD = 40; // ns


// Iputs, Outputs
logic       clk;
logic       rst_n;
logic       sioc;
logic       siod;

syn_gen syn_gen_inst(                                   
    .I_pxl_clk          ( clk             ), // in
    .I_rst_n            ( rst_n           ), // in
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
    .O_rden             (                 ), // out
    .O_de               (                 ), // out
    .O_hs               (                 ), // out
    .O_vs               (                 )  // out
);

initial begin
    clk   = 'b0;
    rst_n = 'b0;
    #10;
    rst_n = 'b1;
end

// clock
always #(CLK_25MHz_PERIOD/2) begin
    clk <= ~clk;
end

///////////////////////////////////////////////////
// Test case
///////////////////////////////////////////////////
initial begin

$dumpfile("scenario.vcd");
$dumpvars(0, syn_gen_sim);

$display("start sim");

#1000001000; // 1秒以上確保

$finish;

end

endmodule
