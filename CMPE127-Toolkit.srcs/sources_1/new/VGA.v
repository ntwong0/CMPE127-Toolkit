`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02/11/2018 05:02:44 PM
// Design Name:
// Module Name: VGA
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


module VGA_TOP(
	input wire clk,
	input wire rst,
	output wire hsync,
	output wire vsync,
	output wire [3:0] R,
	output wire [3:0] G,
	output wire [3:0] B
);

wire pclk, rst, hsync, vsync;
wire [32:0] hcount, vcount;

PixelClock U0(
	.clk100Mhz(clk),
	.rst(rst),
	.pclk(pclk)
);

VGA U1(
	.pclk(pclk),
	.rst(rst),
	.hsync(hsync),
	.vsync(vsync),
	.hcount(hcount),
	.vcount(vcount)
);

ColorModule U2(
	.pclk(pclk),
	.hcount(hcount),
	.vcount(vcount),
	.r(R),
	.g(G),
	.b(B)
);

endmodule


module TextModule(
	input wire pclk,
	input wire [32:0] hcount,
	input wire [32:0] vcount,
	output wire [3:0] r,
	output wire [3:0] g,
	output wire [3:0] b
);

wire [7:0] character_ram [0:80] [0:30];
wire [7:0] out;

assign character_ram[0][0] = "H";
assign character_ram[0][1] = "E";
assign character_ram[0][2] = "L";
assign character_ram[0][3] = "L";
assign character_ram[0][4] = "O";

assign character_ram[1][3] = "W";
assign character_ram[1][4] = "O";
assign character_ram[1][5] = "R";
assign character_ram[1][6] = "L";
assign character_ram[1][7] = "D";
assign character_ram[1][8] = "!";

FontROM rom(
	.ascii(character_ram[vcount >> 4][hcount >> 3]),
	.column(vcount % 16),
	.pixels()
);

// assign r = (out[vcount % 16][7-hcount % 8] && vcount < 480 && hcount < 640) ? 4'hF : 0;
// assign g = (out[vcount % 16][7-hcount % 8] && vcount < 480 && hcount < 640) ? 4'hF : 0;
// assign b = (out[vcount % 16][7-hcount % 8] && vcount < 480 && hcount < 640) ? 4'hF : 0;

assign r = (out[7-hcount % 8] && vcount < 480 && hcount < 640) ? 4'hF : 0;
assign g = (out[7-hcount % 8] && vcount < 480 && hcount < 640) ? 4'hF : 0;
assign b = (out[7-hcount % 8] && vcount < 480 && hcount < 640) ? 4'hF : 0;


endmodule

module ColorModule(
	input wire pclk,
	input wire [32:0] hcount,
	input wire [32:0] vcount,
	output wire [3:0] r,
	output wire [3:0] g,
	output wire [3:0] b
);

assign r = (  0 < vcount && vcount <= 200 && hcount < 640) ? 4'hF : 0;
assign g = (200 < vcount && vcount <= 400 && hcount < 640) ? 4'hF : 0;
assign b = (400 < vcount && vcount <= 480 && hcount < 640) ? 4'hF : 0;

endmodule

module PixelClock(
	input wire clk100Mhz,
	input wire rst,
	output reg pclk
);

parameter FREQ_IN  = 32'd100_000_000;
parameter FREQ_OUT = 32'd25_000_000;

parameter HOLD_TICK_COUNT = (FREQ_IN/FREQ_OUT)/2;

reg [15:0] count;

always @(posedge clk100Mhz or posedge rst) begin
	if(rst) begin
		count = 0;
		pclk  = 0;
	end else begin
	   count = count + 1;
	   if(count == HOLD_TICK_COUNT)
	   begin
	      count = 0;
	      pclk = !pclk;
	   end
	end
end
endmodule

module VGA(
	input wire pclk,
	input wire rst,
	output reg hsync,
	output reg vsync,
	// Pixel Number (row number)
	output reg [32:0] hcount,
	// Line Number
	output reg [32:0] vcount
);

parameter DISPLAY_WIDTH  = 640-1;
parameter DISPLAY_HEIGHT = 480-1;

reg hblank;
reg vblank;

wire hsyncon, hsyncoff, hreset, hblankon;
wire vsyncon, vsyncoff, vreset, vblankon;

parameter HORIZONTAL_FRONT_PORCH = 16;
parameter HORIZONTAL_SYNC_PULSE = 96;
parameter HORIZONTAL_BACK_PORCH = 48;

parameter VERTICAL_FRONT_PORCH = 11;
parameter VERTICAL_SYNC_PULSE = 2;
parameter VERTICAL_BACK_PORCH = 31;

assign hblankon = (hcount == DISPLAY_WIDTH);
assign hsyncon  = (hcount == DISPLAY_WIDTH+HORIZONTAL_FRONT_PORCH);
assign hsyncoff = (hcount == DISPLAY_WIDTH+HORIZONTAL_FRONT_PORCH+HORIZONTAL_SYNC_PULSE);
assign hreset   = (hcount == DISPLAY_WIDTH+HORIZONTAL_FRONT_PORCH+HORIZONTAL_SYNC_PULSE+HORIZONTAL_BACK_PORCH);

assign vblankon = (hreset & (vcount == DISPLAY_HEIGHT));
assign vsyncon  = (hreset & (vcount == DISPLAY_HEIGHT+VERTICAL_FRONT_PORCH));
assign vsyncoff = (hreset & (vcount == DISPLAY_HEIGHT+VERTICAL_FRONT_PORCH+VERTICAL_SYNC_PULSE));
assign vreset   = (hreset & (vcount == DISPLAY_HEIGHT+VERTICAL_FRONT_PORCH+VERTICAL_SYNC_PULSE+VERTICAL_BACK_PORCH));

always @(posedge pclk or posedge rst) begin
	if (rst) begin
		hcount <= 0;
		vcount <= 0;
		hcount <= 0;
		hblank <= 0;
		hsync  <= 0;
		vcount <= 0;
		vblank <= 0;
		vsync  <= 0;
	end
	else begin
		hcount <= hreset  ? 0 :  hcount   + 1;
		hblank <= hreset  ? 0 : (hblankon ? 1 : hblank);
		hsync  <= hsyncon ? 0 : (hsyncoff ? 1 : hsync);

		vcount <= hreset  ? (vreset ? 0 : vcount + 1) : vcount;
		vblank <= vreset  ? 0 : (vblankon ? 1 : vblank);
		vsync  <= vsyncon ? 0 : (vsyncoff ? 1 : vsync);
	end
end

endmodule

