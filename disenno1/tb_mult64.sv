`timescale 1ns / 1ps

module tb_mult64;
    // DUT signals
    logic clk = 0;
    logic rst;
    logic [63:0] a, b;
    logic [127:0] c;
    logic [127:0] golden;

    // DUT
    mult64 DUT(
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .c(c)
    );

    always #1.6667 clk = ~clk; // Clock 300 MHz

    // Variables
    int errors = 0;
    int seed = 12345; // seed for random tests

    initial begin
        rst = 1;
        a = 64'd0;
        b = 64'd0;  
        golden = 128'd0; // for comparison

        // reset for 2 cycles
        repeat(2) @(posedge clk);
        rst = 0;

        $display("\n==== Test 1: Small values ====");
        test_case(64'd0, 64'd0);
        test_case(64'd1, 64'd1);
        test_case(64'd2, 64'd3);
        test_case(64'd5, 64'd7);
        test_case(64'd10, 64'd15);

        $display("\n==== Test 2: Medium and Large values ====");
        test_case(64'h0123456789ABCDEF, 64'hFEDCBA9876543210);
        test_case(64'h0F0F0F0F0F0F0F0F, 64'hF0F0F0F0F0F0F0F0);
        test_case(64'h1234567890ABCDEF, 64'h0FEDCBA987654321);

        $display("\n==== Test 3: Extreme cases using all 128 bits ====");
        test_case(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF);
        test_case(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555);
        test_case(64'h8000000000000000, 64'h8000000000000000);

        $display("\n==== Test 4: Random but reproducible values ====");
        for(int i = 0; i < 5; i++) begin
            test_case($urandom(seed), $urandom(seed));
            seed = seed + 1; // modify numbers according to the seed used.
        end

        $display("\n===========Report===========");
        if(errors == 0)
            $display(">>> Single cycle multiplier 64x64 works correctly <<<");
        else
            $display(">>> Failures detected: %0d <<<", errors);

        $finish;
    end

    // Testing 
    task test_case(input [63:0] ta, input [63:0] tb);
        begin
            a <= ta;
            b <= tb;

            @(posedge clk);          
            golden = a * b;          // golden model of 128 bits
            @(posedge clk);          // wait for DUT FF

            $display("a      = %h", a);
            $display("b      = %h", b);
            $display("HW c   = %h", c);
            $display("Golden = %h", golden);

            if(c !== golden) begin
                $display("ERROR: c != golden");
                errors++;
            end
            else begin
                $display("OK!");
            end

            $display("------------------------------\n");
        end
    endtask

endmodule
