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

    // Timeout mechanism
    initial begin
        #100000 begin
            $display("\nERROR: Simulation timeout! Test did not complete.");
            $finish;
        end
    end

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_mips_cpu);

        clk = 0;
        reset = 1;
        #20 reset = 0;

        $display("Starting simulation...");
        #600;  // Wait 600ns (30 clock cycles at 20ns period)
        $display("Simulation complete.");

        $display("\n===== CPU REGISTER CHECK =====");

        // Check all registers based on new program
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
