// ---------------------------------------------------------------------
// File name         : sccb_rom.sv
// Module name       : sccb_rom
// Created by        : kiiisy
// Module Description: registers of OV7670 camera module
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 13-May-2023 | kiiisy  |    initial
// --------------------------------------------------------------------
module sccb_rom(
clk_200k,
rst_n,
addr,
sreg 
);

input  wire         clk_200k;
input  wire         rst_n;
input  wire  [ 7:0] addr;
output wire  [15:0] sreg;

reg  [15:0] tmp_reg;

always @(negedge rst_n or posedge clk_200k) begin
    if(!rst_n) begin
        tmp_reg <= 16'h0;
    end else begin
        case(addr)
            //send num : data <= 16bit {address,data}
            000 :tmp_reg <= 16'h12_80; // COM7:All registers reset
            001 :tmp_reg <= 16'h12_80; // COM7:All registers reset
            002 :tmp_reg <= 16'h12_04; // COM7:RGB format
            003 :tmp_reg <= 16'h40_d0; // COM15:RGB565, full range
            004 :tmp_reg <= 16'h11_80; // CLKRC:
            005 :tmp_reg <= 16'h15_00; // COM10:default setting
            006 :tmp_reg <= 16'h8c_00; // RGB444:Disable
            007 :tmp_reg <= 16'h0c_00; // COM3:default setting
            008 :tmp_reg <= 16'h04_00; // COM1:default setting
            009 :tmp_reg <= 16'h3a_04; // TSLB:TSLB:set UV output
            010 :tmp_reg <= 16'h14_38; // COM9:AGC value x16
            011 :tmp_reg <= 16'h4f_b3; // MTX1:Matrix coefficient1
            012 :tmp_reg <= 16'h50_b3; // MTX2:Matrix coefficient2
            013 :tmp_reg <= 16'h51_00; // MTX3:Matrix coefficient3
            014 :tmp_reg <= 16'h52_3d; // MTX4:Matrix coefficient4
            015 :tmp_reg <= 16'h53_a7; // MTX5:Matrix coefficient5
            016 :tmp_reg <= 16'h54_e4; // MTX6:Matrix coefficient6
            017 :tmp_reg <= 16'h58_9e; // MTXS:Matrix coefficientS
            018 :tmp_reg <= 16'h3d_c0; // COM13: Gamma and UV Auto ajust
            019 :tmp_reg <= 16'h17_14; // HSTART:Start high 8 bits, may be 11?
            020 :tmp_reg <= 16'h18_02; // HSTOP:Stop high 8 bits, may be 61?
            021 :tmp_reg <= 16'h32_80; // HREF:hsync edge offset
            022 :tmp_reg <= 16'h19_03; // VSTART:Start high 8 bits
            023 :tmp_reg <= 16'h1a_7b; // VSTOP:Stop high 8 bits
            024 :tmp_reg <= 16'h03_0a; // VREF:vsync edge offset
            025 :tmp_reg <= 16'h0f_43; // COM6:reset timing
            026 :tmp_reg <= 16'h1e_00; // MVFP:Disable mirror and VFlip image
            027 :tmp_reg <= 16'h33_0b; // CHLF:
            028 :tmp_reg <= 16'h3c_78; // COM12:No HREF when VSYNC is low
            029 :tmp_reg <= 16'h69_00; // GFIX:fix gain control
            030 :tmp_reg <= 16'h74_00; // REG74:default setting
            031 :tmp_reg <= 16'hb0_84; // RSVD:
            032 :tmp_reg <= 16'hb1_0c; // ABLC1:
            033 :tmp_reg <= 16'hb2_0e; // RSVD:
            034 :tmp_reg <= 16'hb3_80; // THL_ST:
            //035 :tmp_reg <= 16'h42_08; // COM17:Enable color bar
            default : tmp_reg <= 16'hff_ff;
        endcase
    end
end

assign sreg = tmp_reg;

endmodule