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

    // Expected register values (Instruction Set C)
    reg [31:0] expected_regs [0:31];
    integer i;

    initial begin
        
        // -----------------------------
        // Initialize expected registers
        // After Instruction Set C (0..9)
        // -----------------------------
        for (i = 0; i < 32; i = i + 1)
            expected_regs[i] = 0;

        // Instruction Set C final expected results:
        // C0: addi $t0 = 100
        expected_regs[8]  = 100;  

        // C1: lw $t1, 0($t0)  → MEM[100]
        // We will preload DMEM[25] = 20
        expected_regs[9]  = 20;

        // C2: addi t2 = t1 + 5 = 25
        expected_regs[10] = 25;

        // C3: t3 = t2 + t1 = 25 + 20 = 45
        expected_regs[11] = 45;

        // C4: t4 = t3 - t2 = 45 - 25 = 20
        expected_regs[12] = 20;

        // C5: t5 = t4 XOR t1 = 20 ^ 20 = 0
        expected_regs[13] = 0;

        // C6: sw t5 → stored into MEM[104]
        // (not a register result)

        // C7: t6 = t5 << 2 = 0 << 2 = 0
        expected_regs[14] = 0;

        // C8: t7 = t6 + 1 = 1
        expected_regs[15] = 1;
        
        // C9: jump → no register effect


        // --------------------------------------
        // Apply Reset
        // --------------------------------------
        reset = 1;
        #20;
        reset = 0;

        // --------------------------------------
        // Preload data memory for LW
        // LW at C1 uses address 100 → word index 25
        // --------------------------------------
        CPU.DMEM.memory[25] = 20;

        // --------------------------------------
        // Run long enough for pipeline to finish
        // (10 instructions + 4 pipeline flush cycles)
        // --------------------------------------
        repeat (25) @(posedge clk);

        // --------------------------------------
        // Print results
        // --------------------------------------
        $display("Final Register Values (After Instruction Set C):");
        
        for (i = 0; i < 32; i = i + 1) begin
            $display("R%0d = %0d   %s",
                     i,
                     CPU.REGFILE.regs[i],
                     (CPU.REGFILE.regs[i] === expected_regs[i]) ? "OK" : "ERROR");
        end

        $display("Simulation finished.");
        $stop;
    end

endmodule
