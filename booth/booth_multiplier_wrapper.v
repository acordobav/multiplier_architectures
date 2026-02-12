 
module booth_multiplier_wrapper (
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [63:0]  multiplicand,
    input  wire [63:0]  multiplier,
    output wire [127:0] product,
    output wire         done
);

booth_multiplier #(.N(64)) u0 (
    .clk(clk),
    .rst(rst),
    .start(start),
    .multiplicand(multiplicand),
    .multiplier(multiplier),
    .product(product),
    .done(done)
);

endmodule
