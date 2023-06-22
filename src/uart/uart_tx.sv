// ---------------------------------------------------------------------
// File name         : uart_rx.sv
// Module name       : uart_rx
// Created by        : kiiisy
// Module Description: uart send module
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 15-Jun-2023 | kiiisy  |    initial
// --------------------------------------------------------------------
module uart_tx(
input  wire         clk,
input  wire         rst_n,
input  wire         wr_en,
input  wire [ 7: 0] data,
output wire         txd
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
reg  [ 3: 0]  data_cnt;
reg           data_ff;
reg  [ 7: 0]  data_r;


//////////////////////////////////////////////////////////////
// ステートマシン
// IDLE          :初期状態
// START_BIT     :スタートビット送信状態
// DATA_BIT      :データビット送信状態
// STOP_BIT      :ストップビット送信状態
//////////////////////////////////////////////////////////////
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        sts <= IDLE;
    end else begin
        case(sts)
        IDLE: begin
            if(wr_en) begin
                sts <= START_BIT;
            end
        end
        START_BIT: begin
            if(speed_cnt == 10'd0) begin
                sts <= DATA_BIT;
            end
        end
        DATA_BIT: begin
            if(data_cnt == 4'd0) begin
                sts <= STOP_BIT;
            end
        end
        STOP_BIT: begin
            if(speed_cnt == 10'd0) begin
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
        speed_cnt <= 10'd0;
    end else begin
        if(wr_en) begin
            speed_cnt <= SPEED_MAX;
        end else if(speed_cnt == 10'd0) begin
            speed_cnt <= SPEED_MAX;
        end else begin
            speed_cnt <= speed_cnt - 10'd1;
        end 
    end
end

//  データカウント(DATA_Nビット)
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        data_cnt <= DATA_N;
    end else begin
        if(data_cnt == 4'd0) begin
            data_cnt <= DATA_N;
        end else if(sts == DATA_BIT && speed_cnt == 10'd0) begin
            data_cnt <= data_cnt - 4'd1;
        end
    end
end

// シフトレジスタ
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        data_ff <= 1'd1;
    end else begin
        if(sts == START_BIT) begin
            if(speed_cnt != 10'd0) begin
                data_ff <= 1'd0;
            end
        end else if(sts == DATA_BIT) begin
            if(speed_cnt != 10'd0 && data_cnt != 4'd0) begin
                data_ff <= data_r[data_cnt-1];
            end
        end else begin
            data_ff <= 1'd1;
        end
    end
end

always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        data_r <= 8'd1;
    end else begin
        if(wr_en) begin
            data_r <= data;
        end
    end
end

assign txd   = data_ff;

endmodule