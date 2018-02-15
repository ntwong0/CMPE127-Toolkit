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

//PULLDOWN i0 (.O(R[0]));
//PULLDOWN i1 (.O(R[1]));
//PULLDOWN i2 (.O(R[2]));
//PULLDOWN i3 (.O(R[3]));

//PULLDOWN i4 (.O(G[0]));
//PULLDOWN i5 (.O(G[1]));
//PULLDOWN i6 (.O(G[2]));
//PULLDOWN i7 (.O(G[3]));

//PULLDOWN i8 (.O(B[0]));
//PULLDOWN i9 (.O(B[1]));
//PULLDOWN iA (.O(B[2]));
//PULLDOWN iB (.O(B[3]));

wire pclk;
wire [31:0] hcount, vcount;

reg [31:0] count [0:10];

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

TerminalModule term(
	.pclk(pclk),
	.rst(rst),
	.cs(0),
	.address(0),
	.data("A"),
	.strings({
		"  DEBUG10",
		"   DEBUG9",
		"   DEBUG8",
		"   DEBUG7",
		"   DEBUG6",
		"   DEBUG5",
		"   DEBUG4",
		"   DEBUG3",
		"   DEBUG2",
		"   DEBUG1",
		"   DEBUG0",
		"   CP0$14",
		"   CP0$13",
		"   CP0$12",
		"  WR DATA",
		"  RD DATA",
		"  REGOUT2",
		"  REGOUT1",
		"   ALUOUT",
		"       PC"
	}),
	.values({
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF,
		32'h55ABCDEF
	}),
	.hcount(hcount),
	.vcount(vcount),
	.r(R),
	.g(G),
	.b(B)
);

always @(posedge pclk)
begin
     count[0] <=   count[0] + 1;
     count[1] <=  (count[1-1][0] == 0) ?  count[1] + 1 : count[1];
     count[2] <=  (count[2-1][0] == 0) ?  count[2] + 1 : count[2];
     count[3] <=  (count[3-1][0] == 0) ?  count[3] + 1 : count[3];
     count[4] <=  (count[4-1][0] == 0) ?  count[4] + 1 : count[4];
     count[5] <=  (count[5-1][0] == 0) ?  count[5] + 1 : count[5];
     count[6] <=  (count[6-1][0] == 0) ?  count[6] + 1 : count[6];
     count[7] <=  (count[7-1][0] == 0) ?  count[7] + 1 : count[7];
     count[8] <=  (count[8-1][0] == 0) ?  count[8] + 1 : count[8];
     count[9] <=  (count[9-1][0] == 0) ?  count[9] + 1 : count[9];
    count[10] <= (count[10-1][0] == 0) ? count[10] + 1 : count[10];
end

endmodule

module HEXToASCII(
	input wire [3:0] hex,
	output reg [7:0] ascii
);

always @(*) begin
	case(hex)
		4'h0: ascii = "0";
		4'h1: ascii = "1";
		4'h2: ascii = "2";
		4'h3: ascii = "3";
		4'h4: ascii = "4";
		4'h5: ascii = "5";
		4'h6: ascii = "6";
		4'h7: ascii = "7";
		4'h8: ascii = "8";
		4'h9: ascii = "9";
		4'hA: ascii = "A";
		4'hB: ascii = "B";
		4'hC: ascii = "C";
		4'hD: ascii = "D";
		4'hE: ascii = "E";
		4'hF: ascii = "F";
	endcase
end

endmodule

module TextValueMemoryAssign(
	input wire [(DEBUG_STRING_LENGTH*ASCII)-1:0] string,
	input wire [31:0] value,
	output wire [(MESSAGE_LENGTH*ASCII)-1:0] character_ram
);

parameter DEBUG_STRING_LENGTH = 9;
parameter MESSAGE_LENGTH = 20;
parameter ASCII = 8;

assign character_ram[(ASCII*1)-1:(ASCII)*0] = string[71:64];
assign character_ram[(ASCII*2)-1:(ASCII)*1] = string[63:56];
assign character_ram[(ASCII*3)-1:(ASCII)*2] = string[55:48];
assign character_ram[(ASCII*4)-1:(ASCII)*3] = string[47:40];
assign character_ram[(ASCII*5)-1:(ASCII)*4] = string[39:32];
assign character_ram[(ASCII*6)-1:(ASCII)*5] = string[31:24];
assign character_ram[(ASCII*7)-1:(ASCII)*6] = string[23:16];
assign character_ram[(ASCII*8)-1:(ASCII)*7] = string[15:8];
assign character_ram[(ASCII*9)-1:(ASCII)*8] = string[7:0];
assign character_ram[(ASCII*10)-1:(ASCII)*9] = ":";
assign character_ram[(ASCII*11)-1:(ASCII)*10] = "0";
assign character_ram[(ASCII*12)-1:(ASCII)*11] = "x";

generate
	genvar i;
	for (i = 0; i < 8; i = i + 1)
	begin:htoa
		HEXToASCII htoa_i(
			.hex(value[(i*4)-1:i*4]),
			.ascii(character_ram[19-i])
		);
	end
endgenerate

// HEXToASCII htoa1(
// 	.hex(value[31:28]),
// 	.ascii(character_ram[12])
// );

// HEXToASCII htoa2(
// 	.hex(value[28:25]),
// 	.ascii(character_ram[13])
// );

// HEXToASCII htoa3(
// 	.hex(value[24:20]),
// 	.ascii(character_ram[14])
// );

// HEXToASCII htoa4(
// 	.hex(value[19:16]),
// 	.ascii(character_ram[15])
// );

// HEXToASCII htoa5(
// 	.hex(value[15:12]),
// 	.ascii(character_ram[16])
// );

// HEXToASCII htoa6(
// 	.hex(value[11:8]),
// 	.ascii(character_ram[17])
// );

// HEXToASCII htoa7(
// 	.hex(value[7:4]),
// 	.ascii(character_ram[18])
// );

// HEXToASCII htoa8(
// 	.hex(value[3:0]),
// 	.ascii(character_ram[19])
// );

endmodule

module TerminalModule(
	input wire  pclk,
	input wire  rst,
	input wire  cs,
	input wire  [11:0] address,
	input wire  [ 8:0] data,
	input wire  [(DEBUG_MESSAGES*STRING_BITS)-1:0] strings,
	input wire  [(DEBUG_MESSAGES*VALUE_BITS)-1:0] values,
	input wire  [31:0] hcount,
	input wire  [31:0] vcount,
	output wire [3:0] r,
	output wire [3:0] g,
	output wire [3:0] b
);

parameter DEBUG_STRING_LENGTH = 9;
parameter ASCII 			  = 8;
parameter DEBUG_MESSAGES 	  = 20;
parameter DEBUG_MESSAGES_LENGTH = 20;
parameter STRING_BITS 		  = DEBUG_STRING_LENGTH*8;
parameter VALUE_BITS 		  = 32;
parameter CHARACTER_SECTION   = DEBUG_MESSAGES_LENGTH*8;

reg  [7:0] character_ram [0:30] [0:79];
wire [(ASCII*DEBUG_STRING_LENGTH)-1:0] string_array [0:20];

generate
	genvar t;
	for (t = 0; t < 20; t = t + 1)
	begin:string_array_assignments
		assign string_array[t] = (strings >> (ASCII*DEBUG_STRING_LENGTH)*t);
	end
endgenerate

generate
	genvar j;
	for (j = 0; j < 20; j = j + 1)
	begin:htoa

	end
endgenerate

wire [7:0] pixels;
wire [7:0] ascii_character;
assign ascii_character = character_ram[vcount[10:4]][hcount[9:3]];

FontROM rom(
	.pclk(pclk),
	.ascii(ascii_character),
	.column(vcount[3:0]),
	.pixels(pixels)
);

assign r = (pixels[8-hcount[2:0]] && vcount < 480 && hcount < 640) ? 0 : 0;
assign g = (pixels[8-hcount[2:0]] && vcount < 480 && hcount < 640) ? 4'hF : 0;
assign b = (pixels[8-hcount[2:0]] && vcount < 480 && hcount < 640) ? 0 : 0;

wire [(8*80)-1:0] message = "------------------------------------DEBUG MONITOR-------------------------------------";
wire [(8*3)-1:0] colon_string = ":0x";
integer i;
reg [3:0] state;

parameter INIT_DEBUG_ROW = 0;
parameter INIT_STRINGS   = 1;
parameter INIT_COLONS    = 2;

reg initalize;

always @(posedge pclk or posedge rst) begin
	if (rst) begin
		state = INIT_DEBUG_ROW;
		initalize = 1;
		i = 0;
	end
	else
	begin
		if(cs)
		begin
			//// TODO: This should be latched before changing character ram.
			////       This will probably cause VGA graphical glitches.
			// character_ram[address / 80][address % 80] = data;
		end
		else if(initalize)
		begin
			case(state)
				INIT_DEBUG_ROW:
				begin
					if(i < 80)
					begin
						character_ram[5][i] = ((message >> (((80-1)*8)-(8*i))) & 8'hFF);
						i = i + 1;
					end
					else begin
						i = 0;
						state = INIT_COLONS;
					end
				end
				INIT_COLONS:
				begin
					if(i < 80)
					begin
						if(i < 9)
						begin
							character_ram[0][i+00] = ((string_array[0] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[0][i+20] = ((string_array[1] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[0][i+40] = ((string_array[2] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[0][i+60] = ((string_array[3] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[1][i+00] = ((string_array[4] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[1][i+20] = ((string_array[5] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[1][i+40] = ((string_array[6] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[1][i+60] = ((string_array[7] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[2][i+00] = ((string_array[8] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[2][i+20] = ((string_array[9] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[2][i+40] = ((string_array[10] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[2][i+60] = ((string_array[11] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[3][i+00] = ((string_array[12] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[3][i+20] = ((string_array[13] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[3][i+40] = ((string_array[14] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[3][i+60] = ((string_array[15] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[4][i+00] = ((string_array[16] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[4][i+20] = ((string_array[17] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[4][i+40] = ((string_array[18] >> ((8*8)-(8*i))) & 8'hFF);
							character_ram[4][i+60] = ((string_array[19] >> ((8*8)-(8*i))) & 8'hFF);
						end
						if(9 <= i && i < 12)
						begin
							character_ram[0][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[0][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[0][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[0][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[1][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[1][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[1][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[1][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[2][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[2][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[2][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[2][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[3][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[3][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[3][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[3][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[4][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[4][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[4][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
							character_ram[4][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
						end
						i = i + 1;
					end
					else begin
						initalize = 0;
						i = 0;
						state = INIT_STRINGS;
					end
				end
			endcase
		end
		else
		begin
			character_ram[0][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[0][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[0][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[0][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[1][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[1][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[1][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[1][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[2][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[2][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[2][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[2][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[3][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[3][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[3][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[3][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[4][i+00] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[4][i+20] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[4][i+40] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
			character_ram[4][i+60] = (colon_string >> ((2*8)-(8*(i-9))) & 8'hFF);
		end
	end
end

endmodule

module TextModule #(
	parameter ROW = 0,
	parameter COLUMN = 0
)
(
	input wire  pclk,
	input wire  [31:0] hcount,
	input wire  [31:0] vcount,
	input wire  [(8*7)-1:0] string,
	input wire  [31:0] value,
	input wire  [7:0] pixelsIn,
	output wire [7:0] asciiOut,
	output wire [3:0] columnOut,
	output wire [3:0] r,
	output wire [3:0] g,
	output wire [3:0] b
);

parameter LENGTH = 17;

wire [7:0] character_ram [0:LENGTH];

// assign  asciiOut = () ? character_ram[] : 8'hZ;
// assign columnOut = () ? character_ram[] : 8'hZ;

assign character_ram[0] = string[55:48];
assign character_ram[1] = string[47:40];
assign character_ram[2] = string[39:32];
assign character_ram[3] = string[31:24];
assign character_ram[4] = string[23:16];
assign character_ram[5] = string[15:8];
assign character_ram[6] = string[7:0];
assign character_ram[7] = ":";
assign character_ram[8] = "0";
assign character_ram[9] = "x";

HEXToASCII htoa1(
	.hex(value[31:28]),
	.ascii(character_ram[10])
);

HEXToASCII htoa2(
	.hex(value[28:25]),
	.ascii(character_ram[11])
);

HEXToASCII htoa3(
	.hex(value[24:20]),
	.ascii(character_ram[12])
);

HEXToASCII htoa4(
	.hex(value[19:16]),
	.ascii(character_ram[13])
);

HEXToASCII htoa5(
	.hex(value[15:12]),
	.ascii(character_ram[14])
);

HEXToASCII htoa6(
	.hex(value[11:8]),
	.ascii(character_ram[15])
);

HEXToASCII htoa7(
	.hex(value[7:4]),
	.ascii(character_ram[16])
);

HEXToASCII htoa8(
	.hex(value[3:0]),
	.ascii(character_ram[17])
);

assign r = (columnOut[8-(hcount % 8)] && ((ROW) <= vcount[31:4] && vcount[31:4] < ROW+1) && ((COLUMN) <= hcount[31:3] && hcount[31:3] < (((COLUMN+LENGTH))+1))) ? 4'h0 : 4'hZ;
assign g = (columnOut[8-(hcount % 8)] && ((ROW) <= vcount[31:4] && vcount[31:4] < ROW+1) && ((COLUMN) <= hcount[31:3] && hcount[31:3] < (((COLUMN+LENGTH))+1))) ? 4'hF : 4'hZ;
assign b = (columnOut[8-(hcount % 8)] && ((ROW) <= vcount[31:4] && vcount[31:4] < ROW+1) && ((COLUMN) <= hcount[31:3] && hcount[31:3] < (((COLUMN+LENGTH))+1))) ? 4'h0 : 4'hZ;

endmodule

module ColorModule(
	input wire pclk,
	input wire [31:0] hcount,
	input wire [31:0] vcount,
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
	output reg [31:0] hcount,
	// Line Number
	output reg [31:0] vcount
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

