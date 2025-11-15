`timescale 1ns/1ps
module tb_register_file;

    reg RegWrite;
    reg [4:0] read_reg1, read_reg2, write_reg;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;

    register_file DUT (
        .RegWrite(RegWrite),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial begin
        $dumpfile("rf.vcd");
        $dumpvars(0, tb_register_file);

        // Initialize
        RegWrite = 0; write_reg = 0; write_data = 0;
        read_reg1 = 0; read_reg2 = 0;
        #10;

        // Write to $t0 ($8)
        RegWrite = 1; write_reg = 8; write_data = 7; #5;
        if (read_data1 !== 7) $display("FAIL: $t0 read_data1 = %0d", read_data1);

        // Attempt to write to $zero ($0)
        write_reg = 0; write_data = 123; #5;
        if (DUT.regs[0] !== 0) $display("FAIL: $zero should always be 0");

        // Check multiple reads
        read_reg1 = 8; read_reg2 = 9; #5;
        $display("REG[8] = %0d, REG[9] = %0d", read_data1, read_data2);

        $display("Register file test complete");
        $finish;
    end

endmodule
