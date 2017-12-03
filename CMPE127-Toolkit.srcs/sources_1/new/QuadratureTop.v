`default_nettype none

module QuadratureTop(
	input wire clk,
	input wire rst,
	input wire ext_phase_a,
	input wire ext_phase_b,
	input wire off_led,
	input wire output_enable,
	output wire [15:0] leds
);

wire [31:0] data;
wire oe;
wire we;

assign oe = output_enable;
assign we = 0;
assign leds[14:0] = (oe && off_led) ? data[14:0] : 0;

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