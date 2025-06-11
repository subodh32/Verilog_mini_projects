`timescale 1ns/1ps

module Multiplier (
    input [7:0] a,
    input [7:0] b,
    output wire [15:0] c
);

wire [15:0] p0 = (b[0] == 1) ? a : 0;
wire [15:0] p1 = (b[1] == 1) ? (a << 1) : 0;
wire [15:0] p2 = (b[2] == 1) ? (a << 2) : 0;
wire [15:0] p3 = (b[3] == 1) ? (a << 3) : 0;
wire [15:0] p4 = (b[4] == 1) ? (a << 4) : 0;
wire [15:0] p5 = (b[5] == 1) ? (a << 5) : 0;
wire [15:0] p6 = (b[6] == 1) ? (a << 6) : 0;
wire [15:0] p7 = (b[7] == 1) ? (a << 7) : 0;

assign c = p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7;

endmodule

module test;
    reg clk;
    reg [3:0] a, b;
    wire [15:0] product;

    Multiplier multiplier (
        .a(a),
        .b(b),
        .c(product)
    );

    initial begin
        a = 4'b0000; // Initialize a to 0
        b = 4'b0000; // Initialize b to 0
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clk every 5 time units
    end

    always @(posedge clk) begin
        a <= a + 1; // Increment a on each clock edge
        b <= b + 1; // Increment b on each clock edge
    end

    initial begin
        $dumpfile("Multiplier.vcd");
        $dumpvars(0,test);
    end

    initial begin
        // $monitor("At time %0t, clk = %b, a = %b, b = %b, prod = %product", $time, clk, a, b, product);
        #100 $finish;
    end
endmodule