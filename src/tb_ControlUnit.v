`timescale 1ns/1ps

module tb_control;

    reg  [31:0] instr;
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump;
    wire [3:0] ALUCtrl;

    control_unit CU (
        .instruction(instr),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Jump(Jump),
        .ALUCtrl(ALUCtrl)
    );

    initial begin
        $dumpfile("control.vcd");
        $dumpvars(0, tb_control);

        $display("=========== CONTROL UNIT TEST ===========");

        // -------------------------------
        // R-TYPE: ADD  (opcode=000000, funct=100000)
        // instruction: add $t1,$t2,$t3
        // -------------------------------
        instr = 32'b000000_01010_01011_01001_00000_100000;
        #5;
        $display("ADD: RegDst=%b ALUSrc=%b RegWrite=%b ALUCtrl=%b",
                  RegDst, ALUSrc, RegWrite, ALUCtrl);

        // -------------------------------
        // I-TYPE: ADDI (opcode=001000)
        // addi $t0,$t0,5
        // -------------------------------
        instr = 32'b001000_01000_01000_0000000000000101;
        #5;
        $display("ADDI: RegDst=%b ALUSrc=%b RegWrite=%b ALUCtrl=%b",
                  RegDst, ALUSrc, RegWrite, ALUCtrl);

        // -------------------------------
        // LOAD WORD: LW (opcode=100011)
        // lw $t0, 4($t1)
        // -------------------------------
        instr = 32'b100011_01001_01000_0000000000000100;
        #5;
        $display("LW: MemRead=%b MemtoReg=%b RegWrite=%b ALUSrc=%b",
                  MemRead, MemtoReg, RegWrite, ALUSrc);

        // -------------------------------
        // STORE WORD: SW (opcode=101011)
        // sw $t0, 4($t1)
        // -------------------------------
        instr = 32'b101011_01001_01000_0000000000000100;
        #5;
        $display("SW: MemWrite=%b MemRead=%b ALUSrc=%b",
                  MemWrite, MemRead, ALUSrc);

        // -------------------------------
        // JUMP: J (opcode=000010)
        // j 0x000004
        // -------------------------------
        instr = 32'b000010_00000000000000000000000100;
        #5;
        $display("JUMP: Jump=%b", Jump);

        $display("=========== TEST COMPLETE ===========");
        $finish;
    end

endmodule
