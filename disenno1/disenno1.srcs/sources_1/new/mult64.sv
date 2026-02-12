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
    output reg [128:0] c,
    input clk,
    input rst,
    input [63:0] a,
    input [63:0] b
);

    always @(posedge clk) begin
        if(rst)
            c <= 128'd0;
        else 
            c <= a * b;
    end     
    
    
endmodule
