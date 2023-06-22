// ---------------------------------------------------------------------
// File name         : uart_top.sv
// Module name       : uart_top
// Created by        : kiiisy
// Module Description: uart top module
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 15-Jun-2023 | kiiisy  |    initial
// --------------------------------------------------------------------
module uart_top(
input  wire         clk,
input  wire         rst_n,
input  wire         rxd,
output wire         txd,
output wire [15: 0] data,
output wire         uart_is_ready
);

wire           wr_en;
reg            rx_ready;
reg   [ 1: 0]  ready_cnt;
reg   [ 7: 0]  data_from_rx;
reg   [15: 0]  data_2byte;
wire  [ 7: 0]  data_to_tx;


assign data           = data_2byte;
assign uart_is_ready  = (ready_cnt == 2'd2) ? 1'd1 : 1'd0;
// debuggモード(PC to FPGA)
assign wr_en          = rx_ready;
assign data_to_tx     = data_from_rx;

uart_rx U_uart_rx(
    .clk      ( clk          ),
    .rst_n    ( rst_n        ),
    .ready    ( rx_ready     ),
    .rxd      ( rxd          ),
    .data     ( data_from_rx )
);

// 2byteカウンター
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        ready_cnt  <= 2'd0;
    end else begin
        if(ready_cnt == 2'd2) begin
            ready_cnt <= 2'd0;
        end else if(rx_ready) begin
            ready_cnt <= ready_cnt + 2'd1;
        end
    end
end

// シフトレジスタ
always @(*) begin
    if(rx_ready) begin
        data_2byte <= {data_2byte[7:0],data_from_rx};
    end
end

uart_tx U_uart_tx(
    .clk      ( clk          ),
    .rst_n    ( rst_n        ),
    .wr_en    ( wr_en        ),
    .data     ( data_to_tx   ),
    .txd      ( txd          )
);

endmodule