//////////////////////////////////////////////////////////////////////////////////
// Company: Tecnologico de Costa Rica
// Engineer: Victor Sanchez
// 
// Create Date: 02/13/2026 07:02:58 AM
// Design Name: 
// Module Name: mult_8x8
// Project Name: 
// Target Devices: AMD Kria KV260
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

module mult_8x8(
    input  [7:0]  in_a,
    input  [7:0]  in_b,
    output [15:0] out_8x8
    );
    assign out_8x8 = in_a * in_b;
endmodule
