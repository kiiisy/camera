// ---------------------------------------------------------------------
// File name         : uart_rx.sv
// Module name       : uart_rx
// Created by        : kiiisy
// Module Description: uart recieve module
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 15-Jun-2023 | kiiisy  |    initial
// --------------------------------------------------------------------
module uart_rx(
input  wire         clk,
input  wire         rst_n,
output wire         ready,
input  wire         rxd,
output wire [ 7: 0] data
);

parameter  SPEED_MAX = 216; // 25MHz / 115.2 kbps - 1
localparam DATA_N    = 8;   // 8bit


typedef enum logic [ 7: 0] {
    IDLE           = 8'd0,
    START_BIT      = 8'd1,
    DATA_BIT       = 8'd2,
    STOP_BIT       = 8'd3
} state_t;

state_t       sts;
reg  [ 9: 0]  speed_cnt;
reg  [ 7: 0]  bit_cnt;
wire          start_bit_on;
wire          stop_bit_on;
reg  [ 3: 0]  data_cnt;
reg  [ 7: 0]  data_ff;


//////////////////////////////////////////////////////////////
// ステートマシン
// IDLE          :初期状態
// START_BIT     :スタートビット検出状態
// DATA_BIT      :データビット受信状態
// STOP_BIT      :ストップビット受信状態
//////////////////////////////////////////////////////////////
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        sts <= IDLE;
    end else begin
        case(sts)
        IDLE: begin
            sts <= START_BIT;
        end
        START_BIT: begin
            if(start_bit_on) begin
                sts <= DATA_BIT;
            end
        end
        DATA_BIT: begin
            if(data_cnt == DATA_N) begin
                sts <= STOP_BIT;
            end
        end
        STOP_BIT: begin
            if(stop_bit_on) begin
                sts <= IDLE;
            end
        end 
        default: begin
            sts <= IDLE;
        end
        endcase
    end
end

// 通信速度カウント
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        speed_cnt <= SPEED_MAX;
    end else begin
        // 初回は1周期半待ち
        if(start_bit_on) begin
            speed_cnt <= 10'd324;
        // 初回以外は1周期カウント
        end else if(speed_cnt == 10'd0) begin
            speed_cnt <= SPEED_MAX;
        end else begin
            speed_cnt <= speed_cnt - 10'd1;
        end
    end
end

// スタート/ストップビット検出
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        bit_cnt <= 8'b11111111;
    end else begin
        if(sts == START_BIT || sts == STOP_BIT) begin
            bit_cnt <= {bit_cnt[6:0], rxd};
        end
    end
end

assign start_bit_on = (sts == START_BIT && bit_cnt == 8'b00000000) ? 1'b1 : 1'b0;
assign stop_bit_on  = (sts == STOP_BIT && bit_cnt == 8'b11111111) ? 1'b1 : 1'b0;


//  データカウント(DATA_Nビット)
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        data_cnt <= 4'd0;
    end else begin
        if(sts != DATA_BIT) begin
            data_cnt <= 4'd0;
        end else if(sts == DATA_BIT && speed_cnt == 10'd0) begin
            data_cnt <= data_cnt + 4'd1;
        end else begin
            data_cnt <= data_cnt;
        end
    end
end

// シフトレジスタ
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        data_ff <= 8'd0;
    end else begin
        //if(data_cnt != DATA_N && speed_cnt == 10'd0) begin
        if(sts == DATA_BIT && speed_cnt == 10'd0) begin
            data_ff <= {data_ff[6:0], rxd};
        end
    end
end

assign data  = data_ff;
assign ready = (stop_bit_on) ? 1'd1 : 1'd0;

endmodule