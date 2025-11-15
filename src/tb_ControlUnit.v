`timescale 1ns/1ps
module tb_control_unit;

    reg [31:0] instruction;
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump;
    wire [3:0] ALUCtrl;

    control_unit DUT (
        .instruction(instruction),
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
        $dumpfile("ctrl.vcd");
        $dumpvars(0, tb_control_unit);

        // Test R-type ADD
        instruction = 32'b000000_01000_01001_01010_00000_100000; #5;
        $display("ADD: RegDst=%b, ALUSrc=%b, RegWrite=%b, ALUCtrl=%b", RegDst, ALUSrc, RegWrite, ALUCtrl);

        // Test ADDI
        instruction = 32'b001000_00000_01000_0000000000000111; #5;
        $display("ADDI: RegDst=%b, ALUSrc=%b, RegWrite=%b, ALUCtrl=%b", RegDst, ALUSrc, RegWrite, ALUCtrl);

        // Test LW
        instruction = 32'b100011_00000_01100_0000000000000000; #5;
        $display("LW: ALUSrc=%b, MemRead=%b, MemtoReg=%b, RegWrite=%b", ALUSrc, MemRead, MemtoReg, RegWrite);

        // Test SW
        instruction = 32'b101011_00000_01010_0000000000000000; #5;
        $display("SW: ALUSrc=%b, MemWrite=%b, RegWrite=%b, ALUCtrl=%b", ALUSrc, MemWrite, RegWrite, ALUCtrl);

        // Test J
        instruction = 32'b000010_00000000000000000000001100; #5;
        $display("JUMP: Jump=%b", Jump);

        $display("Control unit test complete");
        $finish;
    end

endmodule
