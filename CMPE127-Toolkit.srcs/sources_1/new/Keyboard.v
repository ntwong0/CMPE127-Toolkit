`timescale 1ns / 1ps
`default_nettype none

`define SCAN_CODE_LENGTH 11
`define SCAN_CODE_DATA_LENGTH 8
`define RGB_RESOLUTION  		 4
`define FREQ_IN 32'd100_000_000

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
module Keyboard(
    //// input 100 MHz clock
    input wire clk,
    input wire rst,
    //// ps2 
    input wire ps2_clk,
    input wire ps2_data,
    //// chip select for Keyboard module
    input wire cs,
    //// clear signal to clear 
    input wire clr,
    //// 8-bit data input bus 
    output wire [`SCAN_CODE_DATA_LENGTH-1:0] data,
    //// busy signal to tell CPU or other hardware that the VGA controller cannot be writen to.
    output wire ready
);

wire new_code;
wire ps2_clk_sync;
wire ps2_data_sync;
wire count_finished;
wire internal_clear;
wire [3:0] count_output;
wire [`SCAN_CODE_LENGTH-1:0] scan_code;
wire calculated_parity;
wire is_valid_scan_code;
wire scancode_based_clear;
wire ready;

assign internal_clear = (rst | clr  | scancode_based_clear);
// assign scancode_based_clear = (new_code && (scan_code[9:2] == 8'hF0 || scan_code[9:2] == 8'hE0));
assign count_finished = (count_output == `SCAN_CODE_LENGTH);
// assign ready = (new_code && scan_code[9:2] != 8'hF0 && scan_code[9:2] != 8'hE0);
assign ready = new_code;

Syncronizer #(.WIDTH(1)) sync_clk (
	.clk(clk),
	.rst(rst),
	.en(!ready),
	.in(ps2_clk),
	.sync_out(ps2_clk_sync)
);

Syncronizer #(.WIDTH(1)) sync_data (
	.clk(clk),
	.rst(rst),
	.en(!ready),
	.in(ps2_data),
	.sync_out(ps2_data_sync)
);

SHIFTREGISTER #(.WIDTH(`SCAN_CODE_LENGTH)) scan_code_register (
	.rst(internal_clear),
	.clk(!ps2_clk_sync),
	.en(!ready),
	.in(ps2_data_sync),
	.Q({
        scan_code[0],
        scan_code[1],
        scan_code[2],
        scan_code[3],
        scan_code[4],
        scan_code[5],
        scan_code[6],
        scan_code[7],
        scan_code[8],
        scan_code[9],
        scan_code[10]
    })
);

COUNTER #(.WIDTH(4)) counter_ps2_clks (
	.rst(internal_clear),
	.clk(!ps2_clk_sync),
	.load(0),
	.increment(1),
	.enable(!count_finished),
	.D(0),
	.Q(count_output)
);

XNOR #(.WIDTH(8)) parity_checker (
	.in(scan_code[8:1]),
	.out(calculated_parity)
);

XNOR #(.WIDTH(2)) parity_matcher (
	.in({ scan_code[9], calculated_parity} ),
	.out(is_valid_scan_code)
);

AND #(.WIDTH(2)) new_signal (
    .in({ is_valid_scan_code, count_finished }),
    .out(new_code)
);

TRIBUFFER #(.WIDTH(8)) scan_code_buffer (
	.oe(cs),
	.in(scan_code[8:1]),
	.out(data)
);

endmodule

module KeyboardToASCIIROM(
    input wire [7:0] scan_code,
    output reg [7:0] ascii
);

always @(scan_code) begin
    case (scan_code)
        8'h1C: ascii = "A";
        8'h32: ascii = "B";
        8'h21: ascii = "C";
        8'h23: ascii = "D";
        8'h24: ascii = "E";
        8'h2B: ascii = "F";
        8'h34: ascii = "G";
        8'h33: ascii = "H";
        8'h43: ascii = "I";
        8'h3B: ascii = "J";
        8'h42: ascii = "K";
        8'h4B: ascii = "L";
        8'h3A: ascii = "M";
        8'h31: ascii = "N";
        8'h44: ascii = "O";
        8'h4D: ascii = "P";
        8'h15: ascii = "Q";
        8'h2D: ascii = "R";
        8'h1B: ascii = "S";
        8'h2C: ascii = "T";
        8'h3C: ascii = "U";
        8'h2A: ascii = "V";
        8'h1D: ascii = "W";
        8'h22: ascii = "X";
        8'h35: ascii = "Y";
        8'h1A: ascii = "Z";
        8'h45: ascii = "0";
        8'h16: ascii = "1";
        8'h1E: ascii = "2";
        8'h26: ascii = "3";
        8'h25: ascii = "4";
        8'h2E: ascii = "5";
        8'h36: ascii = "6";
        8'h3D: ascii = "7";
        8'h3E: ascii = "8";
        8'h46: ascii = "9";
        8'h0E: ascii = "`";	
        8'h4E: ascii = "-";	
        8'h55: ascii = "=";	
        8'h5D: ascii = "\\";
        8'h29: ascii = " ";
        8'h76: ascii = 8'h03; //// escape
        8'h5B: ascii = "]";
        8'h4C: ascii = ";";
        8'h52: ascii = "'";
        8'h41: ascii = ",";
        8'h49: ascii = ".";
        8'h4A: ascii = "/";
        8'h66: ascii = 8'h7F; // backspace
      default: ascii = 8'hFF;
    endcase
end

endmodule

module Keyboard_DEMO(
    //// input 100 MHz clock
    input wire clk,
    input wire rst,
    input wire ps2_clk,
    input wire ps2_data,
    // input wire clr,
    output wire ready,
    //// Horizontal sync pulse for VGA controller
    output wire hsync,
    //// Vertical sync pulse for VGA controller
    output wire vsync,
    //// RGB 4-bit singal that go to a DAC (range 0V <-> 0.7V) to generate a color intensity
    output wire [`RGB_RESOLUTION-1:0] r,
    output wire [`RGB_RESOLUTION-1:0] g,
    output wire [`RGB_RESOLUTION-1:0] b
);

wire [7:0] ascii;
wire [7:0] scan_code;

Keyboard keyboard(
    //// input 100 MHz clock
    .clk(clk),
    .rst(rst),
    //// ps2 
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    //// 8-bit data input bus 
    .data(scan_code),
    //// chip select for Keyboard module
    .cs(1),
    //// clear signal to clear 
    .clr(clr),
    //// busy signal to tell CPU or other hardware that the VGA controller cannot be writen to.
    .ready(ready)
);

KeyboardToASCIIROM rom(
    .scan_code(scan_code),
    .ascii(ascii)
);

VGA_Terminal vga_term(
    .clk(clk),
    .rst(rst),
    .hsync(hsync),
    .vsync(vsync),
    .r(r),
    .g(g),
    .b(b),
    .values({
        32'h0,
        32'h0,
        {24'h0, scan_code},
        {24'h0, scan_code_reg},

        32'h0,
        32'h0,
        {24'h0, ascii},
        {24'h0, ascii_reg},
        
        32'h0,
        32'h0,
        {31'h0, ready},
        32'h0,
        
        32'h0,
        32'h0,
        {31'h0, clr},
        {20'h0, address},
        
        32'h0,
        32'h0,
        {31'h0, vga_cs},
        { {(32-STATE_WIDTH){1'b0}}, state }
    }),
    .address(address),
    .data(ascii),
    .cs(ready),
    .busy()
);

// ==================================
//// Behavioral Block
// ==================================
reg [11:0] address;
reg [STATE_WIDTH-1:0] state;
reg [7:0] ascii_reg;
reg [7:0] scan_code_reg;
reg [31:0] counter;
reg clr;
reg vga_cs;

parameter IDLE = 0;
parameter KEY_PRESS_SCANCODE_DETECTED = 1;
parameter CLEAR_SCANCODE = 2;
parameter WAIT_FOR_KEY_RELEASE_SIGNAL = 3;
parameter CLEAR_RELEASE_SCANCODE = 4;
parameter WAIT_FOR_FINAL_SCANCODE = 5;
parameter CLEAR_FINAL_SCANCODE = 6;
parameter INCREMENT_ADDRESS = 7;
parameter STATE_WIDTH = $clog2(INCREMENT_ADDRESS);

always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state = IDLE;
        address = 0;
        ascii_reg = 0;
        clr = 0;
        counter = 0;
        vga_cs = 0;
    end
    else
    begin
        case(state)
            IDLE: begin
                clr     = 0;
                vga_cs  = 0;
                if(ready)
                begin
                    scan_code_reg = scan_code;
                    vga_cs = 1;
                    ascii_reg = ascii;
                    state  = KEY_PRESS_SCANCODE_DETECTED;
                end
            end
            KEY_PRESS_SCANCODE_DETECTED: begin
                clr    = 0;
                vga_cs = 1;
                state = CLEAR_SCANCODE;
            end
            CLEAR_SCANCODE: begin
                clr    = 1;
                vga_cs = 0;
                state = WAIT_FOR_KEY_RELEASE_SIGNAL;
            end
            WAIT_FOR_KEY_RELEASE_SIGNAL: begin
                clr    = 0;
                vga_cs = 0;
                if(ready)
                begin
                    scan_code_reg = scan_code;
                    if(scan_code == 8'hF0)
                    begin
                        state = WAIT_FOR_FINAL_SCANCODE;
                    end
                    vga_cs = 0;
                    clr    = 1;
                end
            end
            // CLEAR_RELEASE_SCANCODE: begin
            //     clr    = 1;
            //     vga_cs = 0;
            //     state = WAIT_FOR_FINAL_SCANCODE;
            // end
            WAIT_FOR_FINAL_SCANCODE: begin
                clr    = 0;
                vga_cs = 0;
                if(ready)
                begin
                    clr    = 1;
                    address = address + 1;
                    state = IDLE;
                end
            end
            // CLEAR_FINAL_SCANCODE: begin
            //     clr    = 1;
            //     vga_cs = 0;
            //     state = INCREMENT_ADDRESS;
            // end
            // INCREMENT_ADDRESS: begin
            //     clr    = 0;
            //     vga_cs = 0;
            //     address = address + 1;
            //     state = IDLE;
            // end
            default: begin
                clr    = 1;
                vga_cs = 0;
                state = IDLE;  
            end
        endcase
    end
end
endmodule
