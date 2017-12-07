`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/06/2017 09:00:36 PM
// Design Name:
// Module Name: GlueLogic
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

//////////////////////////////////
// Inverting Buffer
//////////////////////////////////

module NOT #(parameter WIDTH = 1)(
	input wire [WIDTH-1:0] in,
	output wire [WIDTH-1:0] out
);

assign out = ~in;

endmodule

//////////////////////////////////
// Non-Inverting Logic Functions
//////////////////////////////////

module AND #(parameter WIDTH = 2)(
	input wire [WIDTH-1:0] in,
	output wire out
);

assign out = &in;

endmodule

module OR #(parameter WIDTH = 2)(
	input wire [WIDTH-1:0] in,
	output wire out
);

assign out = |in;

endmodule

module XOR #(parameter WIDTH = 2)(
	input wire [WIDTH-1:0] in,
	output wire out
);

assign out = ^in;

endmodule

//////////////////////////////////
// Inverting Logic Functions
//////////////////////////////////

module NAND #(parameter WIDTH = 2)(
	input wire [WIDTH-1:0] in,
	output wire out
);

assign out = ~&in;

endmodule

module NOR #(parameter WIDTH = 2)(
	input wire [WIDTH-1:0] in,
	output wire out
);

assign out = ~|in;

endmodule

module XNOR #(parameter WIDTH = 2)(
	input wire [WIDTH-1:0] in,
	output wire out
);

assign out = ~^in;

endmodule

//////////////////////////////////
// Composition Modules
//////////////////////////////////

module RSLATCH (
	input wire rst,
	input wire R,
	input wire S,
	output reg Q
	output reg nQ
);

NOR set (
	.in({ S, Q }),
	.out(nQ)
);

NOR reset (
	.in({ R, nQ }),
	.out(Q)
);

endmodule

module DLATCH #(parameter WIDTH = 1)(
	input wire rst,
	input wire C,
	input wire [WIDTH-1:0] D,
	output reg [WIDTH-1:0] Q
);

always @(*)
begin
    if (rst)
    begin
    	Q <= 0;
    end
    else if (C)
    begin
        Q <= D;
    end
end

endmodule

module TRIDLATCH #(parameter WIDTH = 1)(
	input wire rst,
	input wire C,
	input wire oe,
	input wire [WIDTH-1:0] D,
	output reg [WIDTH-1:0] Q,
);

wire Q_int;

assign Q_int = (oe) ? Q : 'bZ;

DLATCH U0 #(WIDTH)(
	.rst(rst),
	.C(C),
	.D(D),
	.Q(Q)
)

endmodule