`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02/12/2018 01:18:09 PM
// Design Name:
// Module Name: Test_VGA
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


module Test_VGA;

reg clk;
reg rst;
wire hsync;
wire vsync;
wire [3:0] r;
wire [3:0] g;
wire [3:0] b;
wire [11:0] address;
wire [8:0] data;
wire cs;

assign address = 0;
assign data = 0;
assign cs = 0;

VGA_Terminal test(
	.clk(clk),
	.rst(rst),
	.hsync(hsync),
	.vsync(vsync),
	.values({
            32'h11111111,
            32'h22222222,
            32'h33333333,
            32'h44444444,
            32'h55555555,
            32'h66666666,
            32'h77777777,
            32'h88888888,
            32'h99999999,
            32'h9ABCDEF0,
            32'h12345678,
            32'h12345678,
            32'h22222222,
            32'h33333333,
            32'h44444444,
            32'h55555555,
            32'h66666666,
            32'h77777777,
            32'h88888888,
            32'hDEADBEEF
     }),
	.r(r),
	.g(g),
	.b(b),
	.address(address),
	.data(data),
	.cs(cs)
);

task RESET;
begin
    rst = 0;
    clk = 0;
    #5
    rst = 1;
    #5
    rst = 0;
end
endtask;

task CLOCK;
	input [31:0] count;
	integer k;
begin
	for (k=0; k < count; k = k+1)
	begin
		#5
		clk = 1;
		#5
		clk = 0;
	end
end
endtask

parameter FULL_CYCLE = 32'd10_000_000;

initial begin
    #10
    #10
	RESET;
	CLOCK(FULL_CYCLE);

    #10 $stop;
    #5 $finish;
end

endmodule

