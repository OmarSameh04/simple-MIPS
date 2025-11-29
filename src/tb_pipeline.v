`timescale 1ns/1ps

module tb_mips_cpu_pipeline;

    reg clk;
    reg reset;

    // Instantiate CPU
    mips_cpu_pipeline CPU (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Expected register values for test program
    reg [31:0] expected_regs [0:31];
    integer i;

    initial begin
        // Initialize all registers to 0
        for (i = 0; i < 32; i = i + 1)
            expected_regs[i] = 0;

        // Preload expected results for 10 instructions
        expected_regs[8]  = 5;   // $t0
        expected_regs[9]  = 10;  // $t1
        expected_regs[10] = 15;  // $t2
        expected_regs[11] = 5;   // $t3
        expected_regs[12] = 0;   // $t4
        expected_regs[13] = 15;  // $t5
        expected_regs[14] = 15;  // $t6
        expected_regs[15] = 40;  // $t7
        expected_regs[16] = 5;   // $s0
        expected_regs[17] = 5;   // $s1

        // Reset CPU
        reset = 1;
        #10;
        reset = 0;

        // Wait enough cycles for pipeline to flush (10 instructions + 4 pipeline stages)
        repeat (20) @(posedge clk);

        // Check final register values
        $display("Final Register Values:");
        for (i = 0; i < 32; i = i + 1) begin
            $display("R%0d = %0d %s", i, CPU.registers[i],
                     (CPU.registers[i] === expected_regs[i]) ? "OK" : "ERROR");
        end

        $display("Simulation finished");
        $stop;
    end

endmodule
