`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2026 08:27:38 AM
// Design Name: 
// Module Name: mult64_wrapper
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


module mult64_wrapper(
    output reg [128:0] c,
    input clk,
    input rst,
    input [63:0] a,
    input [63:0] b
);
    
    mult64 mult_unic64x64(
        .c(c),
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b)
    );
    
endmodule  