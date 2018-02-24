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

module FIFO #(
    parameter LENGTH = 16,
    parameter WIDTH = 8
)
(
    input wire clk,
    input wire rst,
    input wire wr_cs,
    input wire wr_en,
    input wire rd_cs,
    input wire rd_en,
    output wire full,
    output wire empty,
    output reg [WIDTH-1:0] out,
    input wire [WIDTH-1:0] in
);
// ==================================
//// Internal Parameter Field
// ==================================
parameter ADDRESS_WIDTH = $clog2(LENGTH);
// ==================================
//// Registers
// ==================================
reg [ADDRESS_WIDTH-1:0] write_position;
reg [ADDRESS_WIDTH-1:0] read_position;
reg [ADDRESS_WIDTH:0] status_count;
reg [WIDTH-1:0] mem [0:LENGTH-1];
// ==================================
//// Wires
// ==================================
// ==================================
//// Wire Assignments
// ==================================
assign full  = (status_count == (LENGTH));
assign empty = (status_count == 0);
// ==================================
//// Modules
// ==================================
// ==================================
//// Behavioral Block
// ==================================
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        write_position = 0;
        read_position = 0;
        status_count = 0;
    end
    else 
    begin
        if (wr_cs && wr_en && !full)
        begin
            mem[write_position] = in;
            if(write_position == LENGTH-1)
            begin
                write_position = 0;
            end
            else
            begin
                write_position = write_position + 1;
            end
            status_count = status_count + 1;
        end
        if (rd_cs && rd_en && !empty)
        begin
            out = mem[read_position];
            if(read_position == LENGTH-1)
            begin
                read_position = 0;
            end
            else
            begin
                read_position = read_position + 1;
            end
            status_count = status_count - 1;
        end
    end
end

endmodule