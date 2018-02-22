`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2018 05:22:16 PM
// Design Name: 
// Module Name: Memory
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


module RAM #(
    parameter LENGTH = 2400,
    parameter WIDTH = 8
)
(
    input wire clk,
    input wire we,
    input wire cs,
    input wire oe,
    input wire [ADDRESS_WIDTH-1:0] address,
    inout wire [WIDTH-1:0] data
);

// ==================================
//// Internal Parameter Field
// ==================================
parameter ADDRESS_WIDTH = $clog2(LENGTH);
// ==================================
//// Registers
// ==================================
reg [WIDTH-1:0] ram [0:LENGTH];
reg [WIDTH-1:0] data_out;
// ==================================
//// Wires
// ==================================
// ==================================
//// Wire Assignments
// ==================================
assign data = (cs && oe && !we) ? data_out : 8'bz;
// ==================================
//// Modules
// ==================================
// ==================================
//// Behavioral Block
// ==================================
always @(posedge clk)
begin
    if (cs && we)
    begin
       ram[address] = data;
    end
    else if (cs && oe && !we)
    begin
        data_out = ram[address];
    end
end

endmodule
