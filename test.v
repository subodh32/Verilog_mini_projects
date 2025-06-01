`timescale 1ps/1ps
module test;
    reg clk;
    reg[4:0] count;

    wire clk2;
    clock_gen abc (
        .clk(clk2)
    );
    
    initial begin
        count = 0;
        clk = 0;
        forever #5 clk = ~clk; // Toggle clk every 5 time units
    end

    always @(posedge clk2) begin
        count <= count + 1; // Increment count on each clock edge
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test, clk2);
    end

    initial begin
        $monitor("At time %0t, clk = %b", $time, clk);
        #100 $finish; // Run simulation for 50 time units
    end
endmodule