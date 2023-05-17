//////////////////////////////////////////////////////////////
// モジュール :sccb_top_sim
// 概要      :シナリオトップ
// 内容      :シナリオトップ
// 変更履歴   :2023/5/13 kiiisy 新規作成
/////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module sccb_top_sim;

// Create clock
//parameter CLK_25MHz_PERIOD = 40; // ns
parameter CLK_25MHz_PERIOD = 10; // ns


// Iputs, Outputs
logic       clk;
logic       rst;
logic       sioc;
logic       siod;

// Device under test
//sccb_top dut(
//  .clk              ( clk    ),
//  .resend           ( rst    ),
//  .config_finished  (        ), // nouse
//  .sioc             ( sioc   ),
//  .siod             ( siod   ),
//  .reset            (        ), // nouse
//  .pwdn             (        )  // nouse
//);

sccb_if dut(
  .clk_25 (clk),
  .rst    (rst),
  .sda    (siod),
  .scl    (sioc),
  .init_done()
);

initial begin
  clk = 'b0;
  rst = 'b1;
  #10;
  rst = 'b0;
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
  $dumpvars(0, sccb_top_sim);

  $display("start sim");

  #100000000;
  //#100000;

  $finish;

end

endmodule
