`timescale 1ps/1ps

module Adder4bit(
    input [3:0] a,
    input [3:0] b,
    output [4:0] sum
);
    assign sum = a + b; // 4-bit adder
endmodule

module clock_gen(
    output reg clk
);
    initial clk = 0;
    always #10 clk = ~clk; // 10ps period clock (100GHz)
endmodule

module test;
    wire clk;
    reg [3:0] a, b;
    wire [4:0] sum;

    clock_gen clk_gen (
        .clk(clk)
    );

    Adder4bit adder (
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial begin
        a = 4'b0000; // Initialize a to 0
        b = 4'b0000; // Initialize b to 0
    end

    always @(posedge clk) begin
        a <= a + 1; // Increment a on each clock edge
        b <= b + 1; // Increment b on each clock edge
    end

    initial begin
        $dumpfile("Adder.vcd");
        $dumpvars(0, test, clk, a, b, sum);
    end

    initial begin
        $monitor("At time %0t, clk = %b, a = %b, b = %b, sum = %b", $time, clk, a, b, sum);
        #100 $finish; // Run simulation for 100 time units
    end
endmodule