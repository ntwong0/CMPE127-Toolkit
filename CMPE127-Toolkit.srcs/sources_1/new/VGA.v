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


// module VGA_Terminal_Control_Unit(
// 	input wire pclk,
// 	input wire rst,
// 	input wire vblank,
// 	input wire hblank,
// 	output wire [11:0] video_address,
// 	output wire [11:0] terminal_address,
// 	output wire [11:0] debug_address,
// 	output wire xy_count_select,
// 	output wire video_ram_rd,
// 	output wire video_ram_cs,
// 	output wire video_ram_oe,
// 	output wire terminal_ram_rd,
// 	output wire terminal_ram_cs,
// 	output wire terminal_ram_oe,
// 	output wire debug_ram_rd,
// 	output wire debug_ram_cs,
// 	output wire debug_ram_oe,
// 	output wire
// 	output wire
// 	output wire
// );


module VGA_Terminal(
	input wire clk,
	input wire rst,
	output wire hsync,
	output wire vsync,
	output wire [3:0] r,
	output wire [3:0] g,
	output wire [3:0] b,
	input wire [8:0] address,
	input wire [6:0] data,
	input wire cs
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

parameter VGA_RAM_ADDRESS_WIDTH = 12;
parameter PIXEL_WIDTH = 8;
parameter ASCII_WIDTH = 8;

wire pclk;

wire [31:0] hcount;
wire [31:0] vcount;

wire hblank;
wire vblank;

wire [VGA_RAM_ADDRESS_WIDTH-1:0] xyaddress;
 reg [VGA_RAM_ADDRESS_WIDTH-1:0] controlled_address;
 reg xy_select;

wire [PIXEL_WIDTH-1:0] pixels;
wire [ASCII_WIDTH-1:0] ascii_character;

wire enable_rgb;

reg terminal_ram_write;
reg terminal_ram_chip_select;
reg terminal_ram_output_enable;

reg [ASCII_WIDTH-1:0] data_in;

reg [31:0] count [0:10];

PixelClock pixel_clock_generator(
	.clk100Mhz(clk),
	.rst(rst),
	.pclk(pclk)
);

VGA vga_controller(
	.pclk(pclk),
	.rst(rst),
	.hsync(hsync),
	.vsync(vsync),
	.hcount(hcount),
	.vcount(vcount),
	.hblank(hblank),
	.vblank(vblank)
);

ConvertXYToAddress linearize(
	.hcount(hcount),
	.vcount(vcount),
	.address(xyaddress)
);

wire [11:0] terminal_ram_address;

VGA_MUX #(12,1,2) ram_address_mux (
	.select(xy_select),
	// INPUTS x WIDTH bit array
	.in({xyaddress, controlled_address}),
	.out(terminal_ram_address)
);

assign ascii_character = (terminal_ram_write) ? data_in : 8'bz;

wire ready;

VGA_RAM terminal_ram(
	.clk(pclk),
	.we(terminal_ram_write),
	.cs(terminal_ram_chip_select),
	.oe(terminal_ram_output_enable),
	.address(terminal_ram_address),
	.data(ascii_character)
);

// assign terminal_ram_write = 0;
// assign terminal_ram_chip_select = 1;
// assign terminal_ram_output_enable = 0;

FontROM rom(
	.ascii(ascii_character),
	.column(vcount[3:0]),
	.pixels(pixels)
);

assign enable_rgb = !(hblank | vblank);

PixelRender pixel_renderer (
	.pclk(pclk),
	.rst(rst),
	.enable(enable_rgb),
	.hcount(hcount),
	.pixels(pixels),
	.r(r),
	.g(g),
	.b(b)
);

integer i;
integer j;
reg init;

always @(posedge pclk or posedge rst)
begin
	if(rst)
	begin
		init = 1;
		xy_select = 0;
		controlled_address = 0;
		terminal_ram_write = 0;
        terminal_ram_chip_select = 0;
        terminal_ram_output_enable = 0;
		j = 0;
	    i = 0;
		count[0]  = 0;
		count[1]  = 0;
		count[2]  = 0;
		count[3]  = 0;
		count[4]  = 0;
		count[5]  = 0;
		count[6]  = 0;
		count[7]  = 0;
		count[8]  = 0;
		count[9]  = 0;
	    count[10] = 0;
	end
	else begin
		if(init)
		begin
			if(i < 80)
			begin
				terminal_ram_write = 1;
				terminal_ram_chip_select = 1;
				terminal_ram_output_enable = 0;
				data_in = "K";
				xy_select = 0;
				controlled_address = i;
				i = i + 1;
			end
			else begin
				init = 0;
				xy_select = 0;
				terminal_ram_write = 0;
				terminal_ram_chip_select = 1;
				terminal_ram_output_enable = 1;
				data_in = "A";
				xy_select = 1;
				controlled_address = 0;
			end
		end
		else begin
			i = i + 1;
			j = j + 1;
			if(i > 32'd500_000)
			begin
				i = 0;
				count[0]  = count[0] + 1;
				count[1]  = count[1] + 2;
				count[2]  = count[2] + 3;
				count[8]  = count[8] - 4;
				count[9]  = count[9] - 5;
			    count[10] = count[10] + 7;
			end
			if(j > 32'd1_200_000)
			begin
			     j = 0;
	             count[3]  = count[3] + 4;
	             count[4]  = count[4] + 5;
	             count[5]  = count[5] - 1;
	             count[6]  = count[6] - 2;
	             count[7]  = count[7] - 3;
			end
		end
	end
end

endmodule


module VGA_MUX #(
	parameter WIDTH  = 1,
	parameter SELECT = 1,
	parameter INPUTS = 2
)(
	input wire [SELECT-1:0] select,
	// INPUTS x WIDTH bit array
	input wire [(WIDTH*INPUTS)-1:0] in,
	output wire [WIDTH-1:0] out
);

assign out = (in >> (select*WIDTH));

endmodule

module VGA_RAM #(
	parameter LENGTH = 2400,
	parameter WIDTH = 8
)
(
	input wire clk,
	input wire we,
	input wire cs,
	input wire oe,
	input wire [11:0] address,
	inout wire [WIDTH-1:0] data
);

reg [WIDTH-1:0] ram [0:LENGTH];
reg [WIDTH-1:0] data_out;

reg oe_r;
assign data = (cs && oe && !we) ? data_out : 8'bz;

always @(posedge clk)
begin
    if (cs && we)
	begin
       ram[address] = data;
	end
	else if (cs && !we && oe)
	begin
		data_out = ram[address];
		oe_r = 1;
	end
	else
	begin
		oe_r = 0;
	end
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

module ConvertXYToAddress #(
	parameter COLUMNS = 80
)
(
	input wire [31:0] hcount,
	input wire [31:0] vcount,
	output wire [11:0] address
);

// (y*COLUMNS) + x
assign address = (vcount[31:4] * COLUMNS) + hcount[31:3];

endmodule

module PixelRender#(
	parameter PIXEL_WIDTH = 8,
	parameter RGB_RESOLUTION = 4
)
(
	input wire  pclk,
	input wire  rst,
	input wire  enable,
	input wire  [31:0] hcount,
	input wire  [PIXEL_WIDTH-1:0] pixels,
	output wire [RGB_RESOLUTION-1:0] r,
	output wire [RGB_RESOLUTION-1:0] g,
	output wire [RGB_RESOLUTION-1:0] b
);

assign r = (pixels[8-hcount[2:0]] && enable) ? 0 : 0;
assign g = (pixels[8-hcount[2:0]] && enable) ? 4'hF : 0;
assign b = (pixels[8-hcount[2:0]] && enable) ? 0 : 0;

endmodule

// module TerminalModule(
// 	input wire  pclk,
// 	input wire  rst,
// 	input wire  cs,
// 	input wire  [11:0] address,
// 	input wire  [ 8:0] data,
// 	input wire  [(DEBUG_MESSAGES*STRING_BITS)-1:0] strings,
// 	input wire  [(DEBUG_MESSAGES*VALUE_BITS)-1:0] values,
// 	input wire  [31:0] hcount,
// 	input wire  [31:0] vcount,
// 	output wire [3:0] r,
// 	output wire [3:0] g,
// 	output wire [3:0] b
// );

// parameter DEBUG_STRING_LENGTH = 9;
// parameter ASCII 			  = 8;
// parameter DEBUG_MESSAGES 	  = 20;
// parameter DEBUG_MESSAGES_LENGTH = 20;
// parameter STRING_BITS 		  = DEBUG_STRING_LENGTH*8;
// parameter VALUE_BITS 		  = 32;
// parameter CHARACTER_SECTION   = DEBUG_MESSAGES_LENGTH*8;

// wire [(8*80)-1:0] message = "----------------------------------DEBUG MONITOR---------------------------------";
// wire [(8*3)-1:0] colon_string = ":0x";

// wire [7:0] character_ram [0:4] [0:79];
//  reg [7:0] terminal_ram [0:26] [0:79];
// wire [(ASCII*DEBUG_STRING_LENGTH)-1:0] string_array [0:20];
// wire [VALUE_BITS-1:0] value_array [0:20];
// wire [7:0] ascii_character;
// wire [7:0] pixels;

// assign ascii_character = (vcount[10:4] < 5) ?
// 							character_ram[vcount[10:4]][hcount[9:3]] :
// 							terminal_ram[vcount[10:4]-5][hcount[9:3]];

// generate
// 	genvar t;
// 	genvar j;
//     genvar k;
//     genvar hold;
// 	for (t = 0; t < 20; t = t + 1)
// 	begin
// 		assign string_array[t] = (strings >> (ASCII*DEBUG_STRING_LENGTH)*t);
// 		assign  value_array[t] = (values  >> (VALUE_BITS)*t);
// 	end

// 	for (j = 0; j < 4; j = j + 1)
// 	begin
// 		for (t = 0; t < 9; t = t + 1)
// 		begin
// 			assign character_ram[j][t+00] = ((string_array[(j*4)+0] >> ((8*8)-(8*t))) & 8'hFF);
// 			assign character_ram[j][t+20] = ((string_array[(j*4)+1] >> ((8*8)-(8*t))) & 8'hFF);
// 			assign character_ram[j][t+40] = ((string_array[(j*4)+2] >> ((8*8)-(8*t))) & 8'hFF);
// 			assign character_ram[j][t+60] = ((string_array[(j*4)+3] >> ((8*8)-(8*t))) & 8'hFF);
// 		end
// 	end

// 	for (j = 0; j < 4; j = j + 1)
// 	begin
// 		for (t = 0; t < 3; t = t + 1)
// 		begin
// 			assign character_ram[j][t+09] = ((colon_string >> ((2*8)-(8*t))) & 8'hFF);
// 			assign character_ram[j][t+29] = ((colon_string >> ((2*8)-(8*t))) & 8'hFF);
// 			assign character_ram[j][t+49] = ((colon_string >> ((2*8)-(8*t))) & 8'hFF);
// 			assign character_ram[j][t+69] = ((colon_string >> ((2*8)-(8*t))) & 8'hFF);
// 		end
// 	end

// 	for (t = 0; t < 80; t = t + 1)
// 	begin
// 		assign character_ram[4][t] = ((message >> (((80-1)*ASCII)-(8*t))) & 8'hFF);
// 		// assign character_ram[4][t] = ((message >> (8*t)) & 8'hFF);
// 	end

// 	for (j = 0; j < 4; j = j + 1)
// 	begin
// 		for (k = 0; k < 4; k = k + 1)
// 		begin
// 			// assign character_ram[j][12+0+(k*20)] =
// 			// 		(value_array[(j*4)+k][31:28] > 9) ?
// 			// 			"7"+(value_array[(j*4)+k][31:28]):
// 			// 			"0"+(value_array[(j*4)+k][31:28]);

// 			// assign character_ram[j][12+1+(k*20)] =
// 			// 		(value_array[(j*4)+k][27:24] > 9) ?
// 			// 			"7"+value_array[(j*4)+k][27:24]:
// 			// 			"0"+value_array[(j*4)+k][27:24];

// 			// assign character_ram[j][12+2+(k*20)] =
// 			// 		(value_array[(j*4)+k][23:20] > 9) ?
// 			// 			"7"+value_array[(j*4)+k][23:20]:
// 			// 			"0"+value_array[(j*4)+k][23:20];

// 			// assign character_ram[j][12+3+(k*20)] =
// 			// 		(value_array[(j*4)+k][19:16] > 9) ?
// 			// 			"7"+value_array[(j*4)+k][19:16]:
// 			// 			"0"+value_array[(j*4)+k][19:16];

// 			// assign character_ram[j][12+4+(k*20)] =
// 			// 		(value_array[(j*4)+k][15:12] > 9) ?
// 			// 			"7"+value_array[(j*4)+k][15:12]:
// 			// 			"0"+value_array[(j*4)+k][15:12];

// 			// assign character_ram[j][12+5+(k*20)] =
// 			// 		(value_array[(j*4)+k][11:8] > 9) ?
// 			// 			"7"+value_array[(j*4)+k][11:8]:
// 			// 			"0"+value_array[(j*4)+k][11:8];

// 			// assign character_ram[j][12+6+(k*20)] =
// 			// 		(value_array[(j*4)+k][7:4] > 9) ?
// 			// 			"7"+value_array[(j*4)+k][7:4]:
// 			// 			"0"+value_array[(j*4)+k][7:4];

// 			// assign character_ram[j][12+7+(k*20)] =
// 			// 		(value_array[(j*4)+k][3:0] > 9) ?
// 			// 			"7"+value_array[(j*4)+k][3:0]:
// 			// 			"0"+value_array[(j*4)+k][3:0];

// 			HEXToASCII htoa_j_t0(
// 				.hex(value_array[(j*4)+k][31:28]),
// 				.ascii(character_ram[j][12+0+(k*20)])
// 			);
// 			HEXToASCII htoa_j_t1(
// 				.hex(value_array[(j*4)+k][27:24]),
// 				.ascii(character_ram[j][12+1+(k*20)])
// 			);
// 			HEXToASCII htoa_j_t2(
// 				.hex(value_array[(j*4)+k][23:20]),
// 				.ascii(character_ram[j][12+2+(k*20)])
// 			);
// 			HEXToASCII htoa_j_t3(
// 				.hex(value_array[(j*4)+k][19:16]),
// 				.ascii(character_ram[j][12+3+(k*20)])
// 			);
// 			HEXToASCII htoa_j_t4(
// 				.hex(value_array[(j*4)+k][15:12]),
// 				.ascii(character_ram[j][12+4+(k*20)])
// 			);
// 			HEXToASCII htoa_j_t5(
// 				.hex(value_array[(j*4)+k][11:8]),
// 				.ascii(character_ram[j][12+5+(k*20)])
// 			);
// 			HEXToASCII htoa_j_t6(
// 				.hex(value_array[(j*4)+k][7:4]),
// 				.ascii(character_ram[j][12+6+(k*20)])
// 			);
// 			HEXToASCII htoa_j_t7(
// 				.hex(value_array[(j*4)+k][3:0]),
// 				.ascii(character_ram[j][12+7+(k*20)])
// 			);
// 		end
// 	end

// endgenerate

// FontROM rom(
// 	.ascii(ascii_character),
// 	.column(vcount[3:0]),
// 	.pixels(pixels)
// );

// assign r = (pixels[8-hcount[2:0]] && vcount < 480 && hcount < 640) ? 0 : 0;
// assign g = (pixels[8-hcount[2:0]] && vcount < 480 && hcount < 640) ? 4'hF : 0;
// assign b = (pixels[8-hcount[2:0]] && vcount < 480 && hcount < 640) ? 0 : 0;

// integer i;
// reg [3:0] state;

// parameter INIT_DEBUG_ROW = 0;
// parameter INIT_STRINGS   = 1;
// parameter INIT_COLONS    = 2;

// reg initalize;
// reg [12:0] initalize_address;

// always @(posedge pclk or posedge rst) begin
// 	if (rst) begin
// 		state = INIT_DEBUG_ROW;
// 		initalize = 1;
// 		initalize_address = 0;
// 		i = 0;
// 		// terminal_ram = 0;

// 	end
// 	else
// 	begin
// 		if(initalize)
// 		begin
// 			terminal_ram[initalize_address / 80][initalize_address % 80] = 0;
// 			if(initalize_address > 27*80)
// 			begin
// 				initalize = 0;
// 			end
// 			initalize_address = initalize_address + 1;
// 		end
// 		else if(cs)
// 		begin
// 			//// TODO: This should be latched before changing character ram.
// 			////       This will probably cause VGA graphical glitches.
// 			terminal_ram[address / 80][address % 80] = data;
// 		end
// 	end
// end

// endmodule

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

always @(posedge clk100Mhz or posedge rst)
begin
	if(rst)
	begin
		count = 0;
		pclk  = 0;
	end
	else
	begin
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
	output reg [31:0] hcount,
	output reg [31:0] vcount,
	output reg hblank,
	output reg vblank
);

parameter DISPLAY_WIDTH  = 640-1;
parameter DISPLAY_HEIGHT = 480-1;


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

always @(posedge pclk or posedge rst)
begin
	if (rst)
	begin
		hcount = 0;
		vcount = 0;
		hcount = 0;
		hblank = 0;
		hsync  = 0;
		vcount = 0;
		vblank = 0;
		vsync  = 0;
	end
	else
	begin
		hcount = hreset  ? 0 :  hcount   + 1;
		hblank = hreset  ? 0 : (hblankon ? 1 : hblank);
		hsync  = hsyncon ? 0 : (hsyncoff ? 1 : hsync);

		vcount = hreset  ? (vreset ? 0 : vcount + 1) : vcount;
		vblank = vreset  ? 0 : (vblankon ? 1 : vblank);
		vsync  = vsyncon ? 0 : (vsyncoff ? 1 : vsync);
	end
end

endmodule

