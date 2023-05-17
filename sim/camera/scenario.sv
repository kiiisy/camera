//////////////////////////////////////////////////////////////
// モジュール :camera_sim
// 概要      :シナリオトップ
// 内容      :シナリオトップ
// 変更履歴   :2023/5/13 kiiisy 新規作成
/////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module camera_sim;

// Create clock
parameter CLK_25MHz_PERIOD = 40; // ns


// Iputs, Outputs
logic       pclk;
logic       xclk;
logic       rst_n;
logic       sioc;
logic       siod;
logic       vsync;
logic       href;
logic [ 7:0]pixdata;

localparam VMAX = 5;
localparam HMAX = 10;

camera_top #(
    .DUMMY_MODE         ( 1'b0            ) // 0:real camera, 1:dummy camera
)U_camera_top(
    .clk                ( pclk            ), // in
    .xclk               ( xclk            ), // in
    .rst_n              ( rst_n           ), // in
    .vsync              ( vsync           ), // in
    .href               ( href            ), // in
    .data_i             ( pixdata         ), // in
    .vfb_clk            ( vfb_clk         ), // out
    .vfb_vs_n           ( vfb_vs_n        ), // out
    .vfb_de             ( vfb_de          ), // out
    .vfb_data           ( vfb_data        )  // out
);

//dummy_camera U_dummy_camera(
//    .pclk               ( pclk            ),
//    .rst_n              ( rst_n           ),
//    .vsync              ( VSYNC           ),
//    .href               ( HREF            ),
//    .data               ( PIXDATA         )
//);

initial begin
    pclk  = 'b0;
    xclk  = 'b0;
    rst_n = 'b0;
    #10;
    rst_n = 'b1;
end

// clock
always #(CLK_25MHz_PERIOD/2) begin
    pclk <= ~pclk;
    xclk <= ~xclk;
end

///////////////////////////////////////////////////
// Test case
///////////////////////////////////////////////////
initial begin

$dumpfile("scenario.vcd");
$dumpvars(0, camera_sim);

$display("start sim");

vsync    <= 1'b0;
href     <= 1'b0;
pixdata  <= 8'd0;

repeat(5) @(posedge pclk);

$display("start");

for (int i=0; i<VMAX; ++i) begin
    vsync <= 1'b1;
    repeat(1) @(posedge pclk);
    for (int j=0; j<HMAX; ++j) begin
        href <= 1'b1;
        pixdata <= j;
        repeat(1) @(posedge pclk);
    end
    href <= 1'b0;
    repeat(1) @(posedge pclk);
    vsync <= 1'b0;
    repeat(5) @(posedge pclk);
end

$display("end");

#100000;

$finish;

end

endmodule
