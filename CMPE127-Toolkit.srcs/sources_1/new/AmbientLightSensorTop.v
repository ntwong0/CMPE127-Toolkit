`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/04/2017 12:18:11 AM
// Design Name:
// Module Name: AmbientLightSensorTop
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


module AmbientLightSensorTop(
	input wire clk,
	input wire rst,
	input wire oe,
	input wire trigger,
	input wire sdata,
	output wire cs,
	output wire sclk,
	output wire done
);

wire [31:0] data;
wire not_oe;
wire not_trigger;

assign not_oe = ~oe;
assign not_trigger = ~trigger;

AmbientLightSensor U0(
    .clk(clk),
    .rst(rst),
    .oe(not_oe),
    .trigger(not_trigger),
    .sdata(sdata),
    .sclk(sclk),
    .cs(cs),
    .done(done),
    .data(data)
);

endmodule
