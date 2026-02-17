`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: Tecnologico de Costa Rica
// Engineer: Victor Sanchez
// 
// Create Date: 02/13/2026 07:22:58 AM
// Design Name: 
// Module Name: mult_64x64_seg
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

module mult_64x64_seg (
    input clk,
    input rst,
    input start,
    
    input [63:0] in_a,
    input [63:0] in_b,
    
    output reg [127:0] result,
    output reg done
    );
    
    //------------------------------
    // DATA PATH
    //------------------------------    
    
    // -----------------------------
    // Step 1. Input Registers.
    // -----------------------------
    reg [63:0] a_reg, b_reg; // In registers
    
    always @(posedge clk or posedge rst) begin
        // Reset inputs, clear all data
        if (rst) begin
            a_reg <= 0;
            b_reg <= 0;
        end
        // Pass data to main multiplier when starting
        else if (start) begin
            a_reg <= in_a;
            b_reg <= in_b;
        end
    end
    
    // -----------------------------
    // Stage 2. Bank of Mult 8x8.
    // -----------------------------
    
    // Generating the required Mult 8x8
    // For a 64x64, 64 8x8 are required
    wire [15:0] partial_wire [7:0][7:0];
    reg  [15:0] partial_reg  [7:0][7:0];
    
    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : row
            for (j = 0; j < 8; j = j + 1) begin : col

                mult_8x8 u_mult (
                    .in_a(a_reg[i*8 +: 8]),
                    .in_b(b_reg[j*8 +: 8]),
                    .out_8x8(partial_wire[i][j])
                );

                // Registering partial product
                always @(posedge clk) begin
                    partial_reg[i][j] <= partial_wire[i][j];
                end
            end
        end
    endgenerate
    
    // -----------------------------
    // Stage 3. Sum by rows.
    // -----------------------------
    
    // By doing this, we are reducing from 64 to 8 sums ("rows")
    // This, and the following stages, are meant to reduce the critical paths
    // For a 300MHz cycle, it is a must for this arch
    
    reg [127:0] row_sum [7:0];
    reg [127:0] row_sum_next [7:0];
    integer x, y;
    
    always @(*) begin
        for (x = 0; x < 8; x = x + 1) begin
            row_sum_next[x] = 0;
            for (y = 0; y < 8; y = y + 1) begin
                row_sum_next[x] = row_sum_next[x] +
                    (partial_reg[x][y] << ((x+y)*8));
            end
        end
    end
    
    always @(posedge clk) begin
        for (x = 0; x < 8; x = x + 1) begin
            row_sum[x] <= row_sum_next[x];
        end
    end
    
    // Here we have the full data, now process it through a reduction tree
    
    // -----------------------------
    // Stage 4. Reduce sums 8 to 4.
    // -----------------------------
    
    reg [127:0] sum4 [3:0];
    always @(posedge clk) begin
        sum4[0] <= row_sum[0] + row_sum[1];
        sum4[1] <= row_sum[2] + row_sum[3];
        sum4[2] <= row_sum[4] + row_sum[5];
        sum4[3] <= row_sum[6] + row_sum[7];
    end
    
    // -----------------------------
    // Stage 5. Reduce sums 4 to 2.
    // -----------------------------
    
    reg [127:0] sum2 [1:0];

    always @(posedge clk) begin
        sum2[0] <= sum4[0] + sum4[1];
        sum2[1] <= sum4[2] + sum4[3];
    end
    
    // -----------------------------
    // Stage 6: Final result
    // -----------------------------
    reg [127:0] final_sum;
    
    always @(posedge clk) begin
        final_sum <= sum2[0] + sum2[1];
    end
    
    //--------------------------------------------------
    // CONTROL PATH
    //-------------------------------------------------- 
    
    // 6 stages are required to have a full valid result
    reg [5:0] valid_pipe;

    always @(posedge clk or posedge rst) begin
        // Init control path
        if (rst)
            valid_pipe <= 0;
        // Shifting the "start bit" all the way
        else
            valid_pipe <= {valid_pipe[4:0], start};
    end
    
    always @(posedge clk or posedge rst) begin
        // Reset signals for control and output
        if (rst) begin
            done   <= 0;
            result <= 0;
        end else begin
            // Determine if result is valid
            done <= valid_pipe[5];
            if (valid_pipe[5])
                result <= final_sum;
        end
    end


endmodule
