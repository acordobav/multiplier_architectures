`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2026 08:43:05 AM
// Design Name: 
// Module Name: tb_mult_64x64
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


module tb_mult_64x64;

    reg clk;
    reg rst;
    reg start;
    reg [63:0] in_a;
    reg [63:0] in_b;

    wire [127:0] result;
    wire done;

    // DUT
    mult_64x64_seg dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .in_a(in_a),
        .in_b(in_b),
        .result(result),
        .done(done)
    );

    always #5 clk = ~clk;
    
    task run_test;
        input [63:0] a;
        input [63:0] b;
        reg   [127:0] expected;
        begin
            @(posedge clk);
            in_a  <= a;
            in_b  <= b;
            start <= 1;
    
            // START signal ON just 1 cycle
            @(posedge clk);
            start <= 0;
    
            // Wait for done signal to perform comp
            wait(done == 1);
    
            expected = a * b;
            
            // Results
            if (result !== expected) begin
                $display("ERROR: a=%0d b=%0d result=%0d expected=%0d",
                         a, b, result, expected);
            end else begin
                $display("PASSED: a=%0d b=%0d result=%0d expected=%0d",
                         a, b, result, expected);
            end
        end
    endtask

    integer i;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        in_a = 0;
        in_b = 0;

        // WAIT to disable RST signal
        #20;
        rst = 0;

        //-------------------------
        // MAX MIN VALUES TESTS
        //-------------------------
        run_test(0, 0);

        run_test(64'sh7FFFFFFFFFFFFFFF, 1);
        run_test(-64'sh8000000000000000, 1);

        run_test(64'sh7FFFFFFFFFFFFFFF, 64'sh7FFFFFFFFFFFFFFF);

        //-------------------------
        // PARTIAL PRODUCT PATTERNS TESTS
        //-------------------------
        run_test(64'h00000000000000FF, 64'h00000000000000FF);
        run_test(64'h000000000000FF00, 64'h00000000000000FF);
        run_test(64'h00000000FF000000, 64'h00000000000000FF);
        run_test(64'hFF00000000000000, 64'h00000000000000FF);

        run_test(64'h0101010101010101, 64'h0101010101010101);
        run_test(64'h8080808080808080, 64'h0101010101010101);

        //-------------------------
        // RANDOM TESTS
        //-------------------------
        for (i = 0; i < 50; i = i + 1) begin
            run_test($random, $random);
        end

        $display("END OF SIM");
        $stop;
    end

endmodule
