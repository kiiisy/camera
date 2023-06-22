//////////////////////////////////////////////////////////////
// モジュール :uart_top_sim
// 概要      :シナリオトップ
// 内容      :シナリオトップ
// 変更履歴   :2023/5/13 kiiisy 新規作成
/////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module uart_top_sim;

// Create clock
parameter CLK_25MHz_PERIOD = 40; // ns


// Iputs, Outputs
logic       clk;
logic       rst_n;
logic       rxd;
logic       txd;

uart_top U_uart_top(
  .clk      (clk  ),
  .rst_n    (rst_n),
  .rxd      (rxd  ),
  .txd      (txd  )
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
  $dumpvars(0, uart_top_sim);

  $display("start sim");

  rxd = 1'd1;
  repeat (216) @(posedge clk);

  // start bit
  rxd = 1'd0;
  repeat (216) @(posedge clk);

  // 以下のデータビット(0b10101010 = 0xAA)を送信
  rxd = 1;
  repeat (216) @(posedge clk);
  rxd = 0;
  repeat (216) @(posedge clk);
  rxd = 1;
  repeat (216) @(posedge clk);
  rxd = 0;
  repeat (216) @(posedge clk);
  rxd = 1;
  repeat (216) @(posedge clk);
  rxd = 0;
  repeat (216) @(posedge clk);
  rxd = 1;
  repeat (216) @(posedge clk);
  rxd = 0;
  repeat (216) @(posedge clk);

  // stop bit
  rxd = 1;
  repeat (216) @(posedge clk);

  #100000;

  // start bit
  rxd = 1'd0;
  repeat (216) @(posedge clk);

  // 以下のデータビット(0b01010101 = 0x55)を送信
  rxd = 0;
  repeat (216) @(posedge clk);
  rxd = 1;
  repeat (216) @(posedge clk);
  rxd = 0;
  repeat (216) @(posedge clk);
  rxd = 1;
  repeat (216) @(posedge clk);
  rxd = 0;
  repeat (216) @(posedge clk);
  rxd = 1;
  repeat (216) @(posedge clk);
  rxd = 0;
  repeat (216) @(posedge clk);
  rxd = 1;
  repeat (216) @(posedge clk);

  // stop bit
  rxd = 1;
  repeat (216) @(posedge clk);

  #100000;

  $finish;

end

endmodule
