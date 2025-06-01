//another clock
`timescale 1ps/1ps
module clock_gen(
    output reg clk
);
    initial clk = 0;
    always #10 clk = ~clk; // 10ps period clock (100GHz)
endmodule