`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2018 07:26:06 PM
// Design Name: 
// Module Name: Test_Keyboard
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


module Test_VGA_Keyboard;

reg clk, rst;
reg ps2_clk, ps2_data;
wire ready, hsync, vsync;
wire [3:0] r, g, b;

Keyboard_DEMO demo(
    .clk(clk),
    .rst(rst),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .ready(ready),
    .hsync(hsync),
    .vsync(vsync),
    .r(r),
    .g(g),
    .b(b)
);

task RESET;
begin
    rst = 0;
    clk = 0;
    ps2_clk = 0;
    ps2_data = 0;
    #5
    rst = 1;
    #5
    rst = 0;
end
endtask

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

parameter FULL_CYCLE = 32'd1000;

initial begin
    #10
    #10
	RESET;
    CLOCK(FULL_CYCLE);
    #10 $stop;
    #5 $finish;
end

endmodule
