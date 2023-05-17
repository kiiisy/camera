// ---------------------------------------------------------------------
// File name         : sccb_if.sv
// Module name       : sccb_if
// Created by        : kiiisy
// Module Description: sccb I/F module
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 13-May-2023 | kiiisy  |    initial
// --------------------------------------------------------------------
module sccb_if(
clk_25m,
rst_n,
sda,
scl,
init_done,
clk_200k,
addr_rom,
sreg
);

input  wire        clk_25m;
input  wire        rst_n;
output wire        sda;
output wire        scl;
output wire        init_done;
output wire        clk_200k;
output wire [ 7:0] addr_rom;
input  wire [15:0] sreg;


localparam ID_ADDR             = 8'h42;
localparam ADDR_DONE           = 8'hff;
// タイマー関連
localparam TIMER_ON            = 1'b1;
localparam TIMER_OFF           = 1'b0;
localparam WAIT_POWER_ON_TIMER = 8'd98;
localparam DATA_SEND_TIMER     = 8'd28;
localparam WAIT_TIMER          = 8'h40;
localparam TIMER_CNT_MAX       = 8'hff;

typedef enum logic [ 7:0] {
    START           = 8'd0,
    WAIT_POWER_ON   = 8'd1,
    DATA_SET        = 8'd2,
    DATA_SEND       = 8'd3,
    ADDR_ADD        = 8'd4,
    WAIT            = 8'd5,
    FINISH          = 8'd6
} state_t;

state_t      state;
reg          timer;
reg  [ 9:0]  div_clk;
reg  [ 7:0]  timer_cnt;
reg  [29:0]  shift_reg;
reg  [ 7:0]  addr;
wire [29:0]  send_data;


//////////////////////////////////////////////////////////////
// SCLクロック生成(200KHz)
//////////////////////////////////////////////////////////////
always @(negedge rst_n or posedge clk_25m) begin
    if(!rst_n) begin
        div_clk <= 10'h0;
    end else begin
        div_clk <= div_clk + 10'h1;
    end
end

assign clk_200k = div_clk[7];

//////////////////////////////////////////////////////////////
// ステートマシン
// START          :初期状態
// WAIT_POWER_ON  :起動待ち状態
// DATA_SET       :データ設定状態
// DATA_SEND      :データ送信状態
// ADDR_ADD       :次アドレス設定状態
// WAIT           :待ち状態(1コマンド送信待ち)
// FINISH         :設定完了状態
//////////////////////////////////////////////////////////////
always @(negedge rst_n or posedge clk_200k) begin
    if(!rst_n) begin
        state <= START;
        timer <= TIMER_OFF;
    end else begin
        case(state)
        START: begin
            state <= WAIT_POWER_ON;
            timer <= TIMER_ON;
        end
        WAIT_POWER_ON: begin
            if(timer_cnt == WAIT_POWER_ON_TIMER) begin
                state <= DATA_SET;
            end else begin
                timer <= TIMER_OFF;
            end
        end
        DATA_SET: begin
            state <= DATA_SEND;
            timer <= TIMER_ON;
        end
        DATA_SEND: begin
            if(timer_cnt== DATA_SEND_TIMER) begin
                state <= ADDR_ADD;
            end else begin
                timer <= TIMER_OFF;
            end
        end
        ADDR_ADD: begin
            if(addr > 8'd36) begin
                state <= FINISH;
            end else begin
                state <= WAIT;
                timer <= TIMER_ON;
            end
        end
        WAIT: begin
            if(timer_cnt == WAIT_TIMER) begin
                state <= DATA_SET;
            end else begin
                timer <= TIMER_OFF;
            end
        end
        FINISH: begin
            if(addr == 8'd0) begin
                state <= DATA_SET;
            end
        end
        endcase
    end
end

//////////////////////////////////////////////////////////////
// タイマー
//////////////////////////////////////////////////////////////
always @(negedge rst_n or posedge clk_200k) begin
    if(!rst_n) begin
        timer_cnt <= 8'h0;
    end else begin
        if(timer == TIMER_ON) begin
            timer_cnt <= 8'h0;
        end else if(timer_cnt == TIMER_CNT_MAX) begin
            timer_cnt <= timer_cnt;
        end else begin
            timer_cnt <= timer_cnt + 8'h1;
        end
    end
end

//////////////////////////////////////////////////////////////
// データセット
//////////////////////////////////////////////////////////////
always @(negedge rst_n or posedge clk_200k) begin
    if(!rst_n) begin
        shift_reg <= 29'h0;
    end else begin
        if(state == DATA_SET) begin
            shift_reg <= send_data;
        end else if(state == DATA_SEND)begin
            shift_reg <= {shift_reg[28:0],1'b0};
        end
    end
end

//////////////////////////////////////////////////////////////
// アドレスカウンタ
//////////////////////////////////////////////////////////////
always @(negedge rst_n or posedge clk_200k) begin
    if(!rst_n) begin
        addr <= 8'h0;
    end else begin
        if(addr == ADDR_DONE) begin
            addr <= addr;
        end else if(state == ADDR_ADD) begin
            addr <= addr + 8'h1;
        end
    end
end


assign sda       = (state == DATA_SEND && (timer_cnt < 8'd30)) ? shift_reg[29] : 1'b1;
assign scl       = (state == DATA_SEND && (8'd1 <= timer_cnt) && (timer_cnt < 8'd29)) ? ~clk_200k : 1'b1;
assign init_done = (addr > 8'd36) ? 1'd1 : 1'd0;
assign send_data = {2'b0,ID_ADDR,1'b1,sreg[15:8],1'b1,sreg[7:0],1'b1,1'b0};
assign addr_rom  = addr;

endmodule
