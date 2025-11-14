`timescale 1ns/1ps

module tb_alu;

    reg  [31:0] A, B;
    reg  [3:0]  ALUCtrl;
    reg  [4:0]  shamt;
    wire [31:0] Result;
    wire Zero;

    alu uut (
        .A(A), .B(B),
        .ALUCtrl(ALUCtrl),
        .shamt(shamt),
        .Result(Result),
        .Zero(Zero)
    );

    // Self-checking task
    task check;
        input [31:0] expected;
        begin
            #1; // allow Result to update
            if (Result !== expected) begin
                $display("❌ ERROR @ %0t | A=%h B=%h Ctrl=%b shamt=%0d | Got=%h Expected=%h",
                         $time, A, B, ALUCtrl, shamt, Result, expected);
            end else begin
                $display("✔ OK   @ %0t | A=%h B=%h Ctrl=%b shamt=%0d | Result=%h Zero=%b",
                         $time, A, B, ALUCtrl, shamt, Result, Zero);
            end
        end
    endtask

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, tb_alu);

        // ================================
        // ADD 0000
        // ================================
        ALUCtrl = 4'b0000;
        shamt = 0;
        A = 10; B = 20;  check(30);
        A = 32'hFFFF_FFFF; B = 1;  check(0);   // Overflow wrap test

        // ================================
        // SUB 0001
        // ================================
        ALUCtrl = 4'b0001;
        A = 20; B = 10;  check(10);
        A = 10; B = 20;  check(32'hFFFF_FFF6); // Negative result

        // ================================
        // AND 0010
        // ================================
        ALUCtrl = 4'b0010;
        A = 32'hAA55_FF00; B = 32'h0F0F_F0F0;  check(32'h0A05_F000);

        // ================================
        // OR 0011
        // ================================
        ALUCtrl = 4'b0011;
        check(32'hAF5F_FFF0);

        // ================================
        // XOR 0100
        // ================================
        ALUCtrl = 4'b0100;
        check(32'hA55A_0FF0);

        // ================================
        // NOR 0101
        // ================================
        ALUCtrl = 4'b0101;
        check(~(A | B));

        // ================================
        // SLL 0110
        // ================================
        ALUCtrl = 4'b0110;
        B = 32'h0000_0001; shamt = 5;  check(32'h0000_0020);

        // ================================
        // SRL 0111
        // ================================
        ALUCtrl = 4'b0111;
        B = 32'h8000_0000; shamt = 4;  check(32'h0800_0000);

        // ================================
        // SRA 1000
        // ================================
        ALUCtrl = 4'b1000;
        B = 32'h8000_0000; shamt = 4;  check(32'hF800_0000);

        // ================================
        // Zero output check
        // ================================
        ALUCtrl = 4'b0000;
        A = 1; B = 32'hFFFF_FFFF; #1;
        if (Zero !== 1)
            $display("❌ Zero flag incorrect!");
        else
            $display("✔ Zero flag OK");

        $display("\n=== TEST COMPLETE ===\n");
        #10 $finish;
    end

endmodule

