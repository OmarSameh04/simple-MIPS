`timescale 1ns/1ps

module tb_mips_cpu_pipeline_D;

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

    // Expected register values (Instruction Set D)
    reg [31:0] expected_regs [0:31];
    integer i;

    initial begin
        
        // -----------------------------
        // Initialize all registers to 0
        // -----------------------------
        for (i = 0; i < 32; i = i + 1)
            expected_regs[i] = 0;
      
      

        // Instruction Set D final expected results:
        // D0: addi $s0 = 200
        expected_regs[16] = 200;  

        // D1: lw $s1, 0($s0) → memory[200/4 = 50], preload below
        expected_regs[17] = 50;  

        // D2: addi $s2 = s1 + 3 = 53
        expected_regs[18] = 53;

        // D3: add $s3 = s2 + s1 = 53 + 50 = 103
        expected_regs[19] = 103;

        // D4: and $s4 = s3 & s2 = 103 & 53 = 37
        expected_regs[20] = 37;

        // D5: or $s5 = s4 | s1 = 37 | 50 = 55
      expected_regs[21] = 55;

        // D6: sw s5 → memory[204], no register effect

        // D7: lw $t0, 4($s0) → memory[204/4 = 51], preload below
      expected_regs[8]  = 55;  

        // D8: sll $t1, $t0, 1 → 55 << 1 = 110
      expected_regs[9]  = 110;

        // D9: jump → no register effect

        // --------------------------------------
        // Apply Reset
        // --------------------------------------
        reset = 1;
        #20;
        reset = 0;

        // --------------------------------------
        // Preload data memory for LW
        // D1: lw $s1, 0($s0) → address 200 → word index 50
        // D7: lw $t0, 4($s0) → address 204 → word index 51
        // --------------------------------------
        CPU.DMEM.memory[50] = 50;
        CPU.DMEM.memory[51] = 53;

        // --------------------------------------
        // Run long enough for pipeline to finish
        // 10 instructions + 4 pipeline flush cycles
        // --------------------------------------
        repeat (25) @(posedge clk);

        // --------------------------------------
        // Print results
        // --------------------------------------
        $display("Final Register Values (After Instruction Set D):");
        
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
