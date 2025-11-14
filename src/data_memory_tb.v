`timescale 1ns/1ps

module data_memory_tb;

    // Parameters
    localparam MEM_SIZE = 1024;

    // Testbench signals
    reg         MemWrite;
    reg         MemRead;
    reg  [31:0] address;
    reg  [31:0] write_data;
    wire [31:0] read_data;

    // Instantiate DUT
    data_memory #(MEM_SIZE) dut (
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Memory addresses we will test
    localparam ADDR0 = 32'h0;
    localparam ADDR4 = 32'h4;
    localparam ADDR8 = 32'h8;
    localparam ADDR100 = 32'h100;

    // Task to write and check memory
    task write_and_check;
        input [31:0] addr;
        input [31:0] data;
    begin
        // Write
        MemWrite = 1;
        MemRead  = 0;
        address  = addr;
        write_data = data;
        #1; // wait for combinational write

        // Read back
        MemWrite = 0;
        MemRead  = 1;
        #1; // wait for combinational read

        if (read_data !== data)
            $display("ERROR: Memory[%h] = %h, expected %h", addr, read_data, data);
        else
            $display("OK:    Memory[%h] = %h", addr, read_data);
    end
    endtask

    // Main testbench
    initial begin
        // === VCD waveform dump ===
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);

        // Dump only memory locations we will test
        $dumpvars(0, dut.memory[ADDR0>>2]);
        $dumpvars(0, dut.memory[ADDR4>>2]);
        $dumpvars(0, dut.memory[ADDR8>>2]);
        $dumpvars(0, dut.memory[ADDR100>>2]);

        $display("\n=== Data Memory Testbench ===");

        // Initialize signals
        MemWrite = 0;
        MemRead  = 0;
        address  = 0;
        write_data = 0;

        #5;

        // Write and check several addresses
        write_and_check(ADDR0,    32'hDEADBEEF);
        write_and_check(ADDR4,    32'h12345678);
        write_and_check(ADDR8,    32'hAAAA5555);
        write_and_check(ADDR100,  32'hCAFEBABE);

        $display("\n=== Testing read without write enabled ===");
        MemWrite = 0;
        MemRead  = 1;

        // Check read_data = 0 for address not written
        address = 32'h200; // not written
        #1;
        if (read_data !== 0)
            $display("ERROR: Memory[%h] = %h, expected 0", address, read_data);
        else
            $display("OK:    Memory[%h] = %h", address, read_data);

        $display("\n=== Testbench DONE ===");
        $finish;
    end

endmodule