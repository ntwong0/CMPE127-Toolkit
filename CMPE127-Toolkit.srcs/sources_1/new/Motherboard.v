`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/25/2017 05:38:31 PM
// Design Name:
// Module Name: Motherboard
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module Motherboard(
	input wire clk,
	input wire rst,
	input wire ext_phase_a_switch,
	input wire ext_phase_b_switch,
	input wire ext_phase_a_real,
	input wire ext_phase_b_real,
	input wire real_encoder,
	input wire output_enable,
	output wire [15:0] leds
);

PULLDOWN i0 (.O(ext_phase_a_real));
PULLDOWN i1 (.O(ext_phase_b_real));

wire [31:0] data;
wire oe;
wire we;
wire ext_phase_a;
wire ext_phase_b;

assign oe = output_enable;
assign we = 0;
assign leds[14:0] = (oe) ? data[14:0] : 0;
assign ext_phase_a = (real_encoder) ? ext_phase_a_real : ext_phase_a_switch;
assign ext_phase_b = (real_encoder) ? ext_phase_b_real : ext_phase_b_switch;

QuadratureDecoder U0 (
    .clk(clk),
    .rst(rst),
    .oe(oe),
    .we(we),
    .ext_phase_a(ext_phase_a),
    .ext_phase_b(ext_phase_b),
    .direction(leds[15]),
    .data(data)
);

endmodule
