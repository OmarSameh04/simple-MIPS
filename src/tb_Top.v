`timescale 1ns/1ps

module tb_mips_cpu;

    reg clk;
    reg reset;

    mips_cpu DUT (
        .clk(clk),
        .reset(reset)
    );

    // Clock
    always #10 clk = ~clk;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_mips_cpu);

        clk = 0;
        reset = 1;
        #20 reset = 0;

        repeat(100) @(posedge clk);

        $display("\n===== CPU REGISTER CHECK =====");

        // Check all registers based on new program
        check_reg(8,  7,   "$t0");
        check_reg(9,  3,   "$t1");
        check_reg(10, 10,  "$t2");
        check_reg(11, 4,   "$t3");
        check_reg(12, 3,   "$t4");
        check_reg(13, 7,   "$t5");
        check_reg(14, 4,   "$t6");
        check_reg(15, 12,  "$t7");
        check_reg(16, 10,  "$s0");
        check_reg(18, 42,  "$s2");  // jumped-to instruction
        check_reg(17, 0,   "$s1");  // skipped by jump

        // Memory check
        check_mem(0, 10);

        $display("\n===== FULL REGISTER FILE DUMP =====");
        dump_register_file();

        $display("===== TEST COMPLETE =====");
        $finish;
    end

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

    //===========================
    // Check memory location
    //===========================
    task check_mem(input integer addr, input integer exp);
        begin
            if (DUT.DMEM.memory[addr] !== exp)
                $display("FAIL: memory[%0d] = %0d (expected %0d)",
                         addr, DUT.DMEM.memory[addr], exp);
            else
                $display("PASS: memory[%0d] = %0d", addr, exp);
        end
    endtask

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

endmodule
