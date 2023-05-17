// ---------------------------------------------------------------------
// File name         : camera_if.sv
// Module name       : camera_if
// Created by        : kiiisy
// Module Description: module of camera I/F
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 13-May-2023 | kiiisy  |    initial
// --------------------------------------------------------------------
module camera_if(
clk,
rst_n,
href,
data_i,
pclk,
data_o
);

input    wire         clk; // 25MHz
input    wire         rst_n;
input    wire         href;
input    wire  [ 7:0] data_i;
output   wire         pclk;
output   wire  [15:0] data_o;

reg          div_clk;
reg  [15:0]  data;

//////////////////////////////////////////////////////////////
// クロック生成(2クロックで1画素のため)
//////////////////////////////////////////////////////////////
always @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        div_clk <= 1'b0;
    end else begin
        if(!href) begin
            div_clk <= 1'b0;
        end else begin
            div_clk <= ~div_clk;
        end
    end
end

always @(posedge clk) begin
    if(href) begin
        if(pclk == 1'b0) begin
            data[15:8] <= data_i;
        end else if(pclk == 1'b1) begin
            data[ 7:0] <= data_i;
        end
    end
end

assign pclk   = div_clk;
assign data_o = data;

endmodule