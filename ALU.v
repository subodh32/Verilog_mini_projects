`timescale 1ns/1ps

module ALU(
    input [7:0] instruction,
    input clk,
    output wire [7:0] out
);

reg [7:0] a;
reg [7:0] b;


wire [3:0] data;
wire [1:0] inst;
assign data = instruction[3:0];
assign inst = instruction[7:6];
assign out = a;

initial
begin
    a = 8'h00;
    b = 8'h00;
end

always @(posedge clk) begin
    if(inst == 2'b00) // add
        a <= a + b;
    else if(inst == 2'b01) // nand
        a <= ~ (a & b);
    else if(inst == 2'b10) // mov a,data
        a <= data;
    else if(inst == 2'b11) // swap
    begin
        a <= b;
        b <= a;
    end
end

endmodule


module test;
    reg clk;
    wire [7:0] out;
    reg [7:0] instruction;

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clk every 5 time units
    end

    ALU alu(
        .instruction(instruction),
        .clk(clk),
        .out(out)
    );
    
    initial begin
        $dumpfile("ALU.vcd");
        $dumpvars(0, test);
    end

    initial begin
        //testting all instructions
        // instruction = 8'b10110011; // mov a,3
        // #10;
        // instruction = 8'b11000000; // swap a,b
        // #10;
        // instruction = 8'b10110010; // mov a,2
        // #10;
        // instruction = 8'b00111111; // add b
        // #10;
        // instruction = 8'b01000000; // nand b
        // // expected ~(101^011) = 11111110 (FEH)
        // #10;

        //subtraction (16 - 3)
        /*
            mov a,3    # num1 = 3
            swap
            mov a,0     #copy num1
            add b       #back to a
            nand b      #complement num1
            swap
            mov a,1
            add b       #add 1 to num1 i.e take its twos complement
            swap
            mov a,8
            add b

            # expected output: 8-3 = 5 (0000 0101)
        */

        /*
            00 add
            01 nand
            10 mov
            11 swap
        */

        instruction = {2'b10,2'b00,4'h3}; #10; // mov a,3
        instruction = {2'b11,2'b00,4'h0}; #10; // swap
        instruction = {2'b10,2'b00,4'h0}; #10; // mov a,0
        instruction = {2'b00,2'b00,4'h0}; #10; // add b
        instruction = {2'b01,2'b00,4'h0}; #10; // nand b
        instruction = {2'b11,2'b00,4'h0}; #10; // swap
        instruction = {2'b10,2'b00,4'h1}; #10; // mov a,1
        instruction = {2'b00,2'b00,4'h0}; #10; // add b
        instruction = {2'b11,2'b00,4'h0}; #10; // swap
        instruction = {2'b10,2'b00,4'h8}; #10; // mov a,8
        instruction = {2'b00,2'b00,4'h5}; #10; // add b

        $finish;
    end
endmodule