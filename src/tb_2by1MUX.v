`timescale 1ns/1ps

module tb_mux2;

    reg sel;

    // 5-bit test (RegDst MUX)
    reg  [4:0] A5, B5;
    wire [4:0] Y5;

    // 32-bit test (ALUSrc, MemtoReg, Jump MUX)
    reg  [31:0] A32, B32;
    wire [31:0] Y32;

    // Instantiate two MUXes with different widths
    mux2 #(5)  mux_5bit  (.A(A5),  .B(B5),  .sel(sel), .Y(Y5));
    mux2 #(32) mux_32bit (.A(A32), .B(B32), .sel(sel), .Y(Y32));

    initial begin
        $dumpfile("mux.vcd");
        $dumpvars(0, tb_mux2);

        $display("=== TESTING MUX WITH BINARY VALUES ===");

        // -----------------------------------------
        // Test 1: sel=0 → Y = A
        // -----------------------------------------

        // Very simple binary patterns for 5-bit
        A5  = 5'b00001;   // 1
        B5  = 5'b11100;   // 28

        // Very distinct binary patterns for 32-bit
        A32 = 32'b00000000_11110000_00001111_00000000;
        B32 = 32'b11111111_00001111_11110000_11111111;

        sel = 0; #5;
        $display("sel=0: Y5=%b (expect 00001), Y32=%b (expect A32 pattern)", Y5, Y32);

        // -----------------------------------------
        // Test 2: sel=1 → Y = B
        // -----------------------------------------
        sel = 1; #5;
        $display("sel=1: Y5=%b (expect 11100), Y32=%b (expect B32 pattern)", Y5, Y32);

        // -----------------------------------------
        // Test 3: Another simple binary pattern
        // -----------------------------------------
        A5  = 5'b10101;
        B5  = 5'b01010;

        A32 = 32'b10101010_10101010_10101010_10101010;
        B32 = 32'b01010101_01010101_01010101_01010101;

        sel = 0; #5;
        $display("sel=0: Y32=%b (expect A32: repeating 1010...)", Y32);

        sel = 1; #5;
        $display("sel=1: Y32=%b (expect B32: repeating 0101...)", Y32);

        $display("=== MUX TEST DONE ===");
        $finish;
    end
endmodule
