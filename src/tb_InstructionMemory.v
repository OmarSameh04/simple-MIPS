`timescale 1ns / 1ps

module tb_instruction_memory;

    // Parameters
    parameter ADDR_WIDTH = 10;
    parameter DATA_WIDTH = 32;

    // Testbench signals
    reg [31:0] address;
    wire [31:0] instruction;

    // Instantiate the instruction memory
    instruction_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .address(address),
        .instruction(instruction)
    );

    // VCD dump
    initial begin
        $dumpfile("instruction_memory_tb.vcd");  // VCD file name
        $dumpvars(0, tb_instruction_memory);     // Dump all variables in this module
    end

    // Test procedure
    initial begin
        // Initialize address
        address = 0;

        // Wait for a short time to observe output
        #10;
        $display("Address = %0d, Instruction = %h", address, instruction);

        // Test a few addresses
        address = 4;   // memory[1]
        #10;
        $display("Address = %0d, Instruction = %h", address, instruction);

        address = 8;   // memory[2]
        #10;
        $display("Address = %0d, Instruction = %h", address, instruction);

        address = 36;  // memory[9]
        #10;
        $display("Address = %0d, Instruction = %h", address, instruction);

        // Test non-aligned access (lower 2 bits ignored)
        address = 2;   // memory[0]
        #10;
        $display("Address = %0d, Instruction = %h", address, instruction);

        address = 7;   // memory[1]
        #10;
        $display("Address = %0d, Instruction = %h", address, instruction);

        $finish;
    end

endmodule
