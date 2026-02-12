`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tecnologico de Costa Rica
// Engineer: Arturo Cordoba
// 
// Create Date: 02/10/2026 08:02:58 PM
// Design Name: 
// Module Name: booth_multiplier
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


module booth_multiplier #(
    parameter int N = 64
)(
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    start,
    input  logic signed [N-1:0]     multiplicand,
    input  logic signed [N-1:0]     multiplier,
    output logic signed [(2*N)-1:0] product,
    output logic                    done
);

    // Registers
    logic signed [N:0]   A;        // Accumulator
    logic signed [N-1:0] Q;        // Multiplier register
    logic                Q_1;      // Q(-1)
    logic signed [N:0]   M;        // Multiplicand (sign-extended)
    logic signed [N:0]   M_comp;   // -M
    logic [$clog2(N):0]  count;

    // Temporary combinational value
    logic signed [N:0]   A_temp;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            A       <= '0;
            Q       <= '0;
            Q_1     <= 1'b0;
            M       <= '0;
            M_comp  <= '0;
            count   <= '0;
            done    <= 1'b0;
            product <= '0;
        end
        else begin

            // -----------------------------
            // Initialization
            // -----------------------------
            if (start) begin
                A      <= '0;
                Q      <= multiplier;
                Q_1    <= 1'b0;
                M      <= {multiplicand[N-1], multiplicand};  // sign extend
                M_comp <= -{multiplicand[N-1], multiplicand};
                count  <= N;
                done   <= 1'b0;
            end

            // -----------------------------
            // Iterative Booth Step
            // -----------------------------
            else if (count != 0) begin
                // Booth's decisions
                case ({Q[0], Q_1})
                    2'b01: A_temp = A + M;
                    2'b10: A_temp = A + M_comp;
                    default: A_temp = A;
                endcase

                // Arithmetic right shift of {A, Q, Q_1}
                {A, Q, Q_1} <= {A_temp[N], A_temp, Q};

                count <= count - 1;
            end

            // -----------------------------
            // End Condition
            // -----------------------------
            else if (!done) begin
                product <= {A[N-1:0], Q};
                done    <= 1'b1;
            end
        end
    end

endmodule