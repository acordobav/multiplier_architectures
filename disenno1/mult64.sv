`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2026 08:14:36 AM
// Design Name: 
// Module Name: mult64
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




module mult64(
    output logic [127:0] c,
    input logic clk,
    input logic rst,
    input logic [63:0] a,
    input logic [63:0] b
);

logic [127:0] c_reg;

always_ff @(posedge clk) begin
    if(rst)
        c <= 128'd0;
    else 
    c <= a * b;
end     
    
assign c = c_reg;

endmodule

