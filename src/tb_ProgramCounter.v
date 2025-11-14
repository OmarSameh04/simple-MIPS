`timescale 1ns/1ps

module tb_program_counter;

    reg clk;
    reg reset;
    reg [31:0] pc_next;
    wire [31:0] pc_current;

    // Instantiate DUT
    program_counter uut (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("program_counter_tb.vcd");
        $dumpvars(0, tb_program_counter);

        // Initial values
        clk = 0;
        reset = 1;
        pc_next = 32'h0000_0000;

        // Reset test
        #10 reset = 0;

        // Test sequential increments
        #10 pc_next = 32'h0000_0004;
        #10 pc_next = 32'h0000_0008;
        #10 pc_next = 32'h0000_000C;

        // Trigger reset again
        #10 reset = 1;
        #10 reset = 0;

        // Another update
        #10 pc_next = 32'h0000_0010;

        #20 $finish;
    end

    initial begin
        $monitor("t=%0t | reset=%b | pc_next=%h | pc_current=%h",
                  $time, reset, pc_next, pc_current);
    end

endmodule

