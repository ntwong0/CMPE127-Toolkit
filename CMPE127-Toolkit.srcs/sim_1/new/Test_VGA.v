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
wire [3:0] R;
wire [3:0] G;
wire [3:0] B;

VGA_TOP test(
	.clk(clk),
	.rst(rst),
	.hsync(hsync),
	.vsync(vsync),
	.R(R),
	.G(G),
	.B(B)
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

