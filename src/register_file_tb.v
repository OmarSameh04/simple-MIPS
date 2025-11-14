`timescale 1ns/1ps

module register_file_tb;

    // Parameters
    localparam REG_WIDTH     = 32;
    localparam REG_ADDR_BITS = 5;
    localparam NUM_REGS      = 1 << REG_ADDR_BITS;

    // Testbench signals
    reg                      RegWrite;
    reg  [REG_ADDR_BITS-1:0] read_reg1, read_reg2;
    reg  [REG_ADDR_BITS-1:0] write_reg;
    reg  [REG_WIDTH-1:0]     write_data;
    wire [REG_WIDTH-1:0]     read_data1, read_data2;
    //Integer for loops
    integer j;

    // Instantiate DUT
    register_file #(REG_WIDTH, REG_ADDR_BITS) dut (
        .RegWrite(RegWrite),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // === Self-checking write + read task ===
    task check_write_read;
        input [REG_ADDR_BITS-1:0] waddr;
        input [REG_WIDTH-1:0]     wdata;
        reg   [REG_WIDTH-1:0]     expected;
    begin
        $display("Writing %h to register %0d", wdata, waddr);

        // Write
        RegWrite = 1;
        write_reg = waddr;
        write_data = wdata;
        #1; // allow asynchronous write

        // Read back
        RegWrite = 0;
        read_reg1 = waddr;
        #1; // allow combinational read

        expected = (waddr == 0) ? 0 : wdata;

        if (read_data1 !== expected)
            $display("ERROR: Read %h from R%0d, expected %h", read_data1, waddr, expected);
        else
            $display("OK:    Read %h from R%0d", read_data1, waddr);
    end
    endtask

    // === Testbench main flow ===
    initial begin
        // === VCD waveform dump setup ===
        $dumpfile("register_file_tb.vcd");
        // dump top-level TB signals and DUT ports
        $dumpvars(0, register_file_tb);

        // explicitly dump each register file element so GTKWave shows regs[0..31]
        for (j = 0; j < NUM_REGS; j = j + 1) begin
            $dumpvars(0, register_file_tb.dut.regs[j]);
        end
        #0; // tiny pause

        $display("\n=== Register File Testbench ===");

        // Default inputs
        RegWrite   = 0;
        read_reg1  = 0;
        read_reg2  = 0;
        write_reg  = 0;
        write_data = 0;

        #5; // allow initialization

        // Test writing to multiple registers
        check_write_read(5, 32'hAAAA5555);
        check_write_read(7, 32'h11223344);
        check_write_read(10, 32'hDEADBEEF);
        check_write_read(31, 32'h12345678);

        // === Special case: R0 must always stay 0 ===
        $display("\nChecking that register 0 ($zero) ignores writes...");
        check_write_read(0, 32'hFFFFFFFF);

        if (read_data1 !== 0)
            $display("ERROR: R0 changed! Value = %h", read_data1);
        else
            $display("OK:    R0 correctly stays at 0");

        // === Cross read test ===
        $display("\nChecking cross reads between registers...");
        read_reg1 = 7;
        read_reg2 = 31;
        #1;

        if (read_data1 !== 32'h11223344)
            $display("ERROR: read_data1 wrong: %h", read_data1);
        else
            $display("OK: read_data1 = %h (R7)", read_data1);

        if (read_data2 !== 32'h12345678)
            $display("ERROR: read_data2 wrong: %h", read_data2);
        else
            $display("OK: read_data2 = %h (R31)", read_data2);

        $display("\n=== Testbench DONE ===\n");
        $finish;
    end

endmodule