`timescale 1ns/1ps

module tb_booth_multiplier;

    localparam int N = 64;

    logic clk;
    logic rst;
    logic start;
    logic signed [N-1:0] multiplicand;
    logic signed [N-1:0] multiplier;
    logic signed [(2*N)-1:0] product;
    logic done;

    // Reference result
    logic signed [(2*N)-1:0] expected;

    // DUT
    booth_multiplier #(.N(N)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .done(done)
    );

    // Clock generation: 100 MHz
    always #5 clk = ~clk;

    // Task to run one test
    task automatic run_test(
        input logic signed [N-1:0] a,
        input logic signed [N-1:0] b
    );
        begin
            @(negedge clk);
            multiplicand = a;
            multiplier   = b;
            expected     = a * b;
            start        = 1'b1;

            @(negedge clk);
            start = 1'b0;

            // Wait for done
            wait (done == 1'b1);
            @(posedge clk);

            if (product !== expected) begin
                $error("FAIL: a=%0d b=%0d | expected=%0d got=%0d",
                        a, b, expected, product);
                $fatal;
            end
            else begin
                $display("PASS: a=%0d b=%0d | result=%0d", a, b, product);
            end
        end
    endtask

    initial begin
        // Init
        clk = 0;
        rst = 1;
        start = 0;
        multiplicand = 0;
        multiplier = 0;

        // Reset
        repeat (5) @(posedge clk);
        rst = 0;

        // -------------------------
        // Directed test cases
        // -------------------------
        run_test(64'sd11,  64'sd14);
        run_test(64'sd0,  64'sd0);
        run_test(-64'sd1, 64'sd1);
        run_test(64'sd1, -64'sd1);
        run_test(-64'sd1, -64'sd1);

        run_test(64'sd12345, -64'sd6789);
        run_test(-64'sd987654321, 64'sd123456789);

        // Max / Min edge cases
        run_test(64'sh7FFF_FFFF_FFFF_FFFF, 64'sd1);
        run_test(64'sh8000_0000_0000_0000, 64'sd1);
        run_test(64'sh7FFF_FFFF_FFFF_FFFF, -64'sd1);
        run_test(64'sh8000_0000_0000_0000, -64'sd1);

        // -------------------------
        // Random tests
        // -------------------------
        repeat (100) begin
            run_test(
                $signed($urandom()),
                $signed($urandom())
            );
        end

        $display("\n✅ ALL TESTS PASSED SUCCESSFULLY ✅\n");
        $finish;
    end

endmodule