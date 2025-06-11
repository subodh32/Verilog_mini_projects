`timescale 1ns/1ps

module ALU(
    input clk,
    input [7:0] instruction,
    output reg [7:0] instruction_adr,
    output wire power
);

reg [7:0] a;
reg [7:0] b;

reg [2:0] flags;
localparam fg_CARRY = 0;
localparam fg_ZERO = 1;

wire [3:0] data;
wire [3:0] inst;
wire [3:0] offset;

assign data = instruction[3:0];
assign inst = instruction[7:4];

assign out = a;
assign power = (inst == 4'b1111) ? 0 : 1;
assign offset = (inst == 4'b1000)
                ? data
                : 0;

initial
begin
    instruction_adr = 8'h00;
    a = 8'h00;
    b = 8'h00;
end

always @(posedge clk) begin

    instruction_adr <= instruction_adr + 1;

    if(inst == 4'b0000) // add
        a <= a + b;
    else if(inst == 4'b0001) // nand
        a <= ~ (a & b);
    else if(inst == 4'b0010) // mov a,data
        a <= data;
    else if(inst == 4'b0011) // swap
    begin
        a <= b;
        b <= a;
    end
    else if(inst == 4'b0100) // nop
        ;
end

endmodule


module test;
    reg clk;
    wire [7:0] out;

    reg [7:0] mem [0:128];
    reg [7:0] instruction;
    wire [7:0] instruction_adr;

    wire power;

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clk every 5 time units
    end

    initial begin
        instruction = {NOP,4'h0};
    end

    ALU alu(
        .clk(clk),
        .instruction_adr(instruction_adr),
        .instruction(instruction),
        .power(power)
    );

    always @(posedge clk ) begin
        instruction <= mem[instruction_adr];
    end

    localparam ADD  = 4'b0000;
    localparam NAND = 4'b0001;
    localparam MOV  = 4'b0010;
    localparam SWAP = 4'b0011;
    localparam NOP  = 4'b0100;
    localparam HLT  = 4'b1111;
    
    always @(posedge clk) begin
       if(power == 0)
       begin
        // #50;
        $finish;
       end
    end

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

        //subtraction (8 - 3)
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
            0000 add
            0001 nand
            0010 mov
            0011 swap

            1000 jmp {offset}
            1001 jc {offset}
            1010 jz {offset}

            1000 nop
            1111 hlt
        */

        mem[0] = {MOV,4'h3}; // mov a,3
        mem[1] = {SWAP,4'h0}; // swap
        mem[2] = {MOV,4'h0}; // mov a,0
        mem[3] = {ADD,4'h0}; // add b
        mem[4] = {NAND,4'h0}; // nand b
        mem[5] = {SWAP,4'h0}; // swap
        mem[6] = {MOV,4'h1}; // mov a,1
        mem[7] = {ADD,4'h0}; // add b
        mem[8] = {SWAP,4'h0}; // swap
        mem[9] = {MOV,4'h8}; // mov a,8
        mem[10] = {ADD,4'h0}; // add b
        mem[11] = {HLT,4'h0}; // hlt

        #1000; //incase hlt dosent occur
        $finish;

    end
endmodule