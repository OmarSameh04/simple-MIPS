`timescale 1ns/1ps

module tb_mips_cpu_pipeline;

    reg clk;
    reg reset;

    mips_cpu_pipeline DUT (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #10 clk = ~clk;

    initial begin
        $dumpfile("cpu_pipeline.vcd");
        $dumpvars(0, tb_mips_cpu_pipeline);

        // Initialize signals
        clk = 0;
        reset = 1;
        #20 reset = 0;

        // Run simulation for a fixed number of cycles
        repeat(100) @(posedge clk);

        $display("\n===== PIPELINE CPU REGISTER CHECK =====");

        // Check registers based on the program in InstructionMemory
        check_reg(8,  5,   "$t0");
        check_reg(9,  10,  "$t1");
        check_reg(10, 15,  "$t2");
        check_reg(11, 5,   "$t3");
        check_reg(12, 0,   "$t4");
        check_reg(13, 15,  "$t5");
        check_reg(14, 15,  "$t6");
        check_reg(15, 40,  "$t7");
        check_reg(16, 5,   "$s0");
        check_reg(17, 5,   "$s1");

        $display("\n===== FULL REGISTER FILE DUMP =====");
        dump_register_file();

        $display("===== TEST COMPLETE =====");
        $finish;
    end

    //===========================
    // Dump all 32 registers
    //===========================
    task dump_register_file;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1)
                $display("REG[%0d] = %0d (0x%08h)", i, DUT.REGFILE.regs[i], DUT.REGFILE.regs[i]);
        end
    endtask

    //===========================
    // Check a single register
    //===========================
    task check_reg(input integer idx, input integer exp, input [31:0] name);
        begin
            if (DUT.REGFILE.regs[idx] !== exp)
                $display("FAIL: %s = %0d (expected %0d)", name, DUT.REGFILE.regs[idx], exp);
            else
                $display("PASS: %s = %0d", name, exp);
        end
    endtask

endmodule
