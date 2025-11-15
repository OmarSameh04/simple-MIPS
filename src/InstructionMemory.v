module instruction_memory #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32
)(
    input  wire [31:0] address,
    output reg  [31:0] instruction
);

    reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];
    integer i;

    initial begin
        // Clear memory with NOPs
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1)
            memory[i] = 32'b000000_00000_00000_00000_00000_000000;

        // ------------------------------
        // New test program
        // ------------------------------

        // addi $t0, $zero, 7       ; $t0 = 7
        memory[0] = 32'b001000_00000_01000_0000000000000111;

        // addi $t1, $zero, 3       ; $t1 = 3
        memory[1] = 32'b001000_00000_01001_0000000000000011;

        // add $t2, $t0, $t1         ; $t2 = 7 + 3 = 10
        memory[2] = 32'b000000_01000_01001_01010_00000_100000;

        // sub $t3, $t0, $t1         ; $t3 = 7 - 3 = 4
        memory[3] = 32'b000000_01000_01001_01011_00000_100010;

        // and $t4, $t0, $t1         ; $t4 = 7 & 3 = 3
        memory[4] = 32'b000000_01000_01001_01100_00000_100100;

        // or $t5, $t0, $t1          ; $t5 = 7 | 3 = 7
        memory[5] = 32'b000000_01000_01001_01101_00000_100101;

        // xor $t6, $t0, $t1         ; $t6 = 7 ^ 3 = 4
        memory[6] = 32'b000000_01000_01001_01110_00000_100110;

        // sll $t7, $t1, 2           ; $t7 = 3 << 2 = 12
        memory[7] = 32'b000000_00000_01001_01111_00010_000000;

        // sw $t2, 0($zero)          ; memory[0] = 10
        memory[8] = 32'b101011_00000_01010_0000000000000000;

        // lw $s0, 0($zero)          ; $s0 = memory[0] = 10
        memory[9] = 32'b100011_00000_10000_0000000000000000;

        // j 12                       ; jump to memory[12]
        memory[10] = 32'b000010_00000000000000000000001100;

        // addi $s1, $zero, 255      ; $s1 = 255 (this is skipped by jump)
        memory[11] = 32'b001000_00000_10001_0000000011111111;

        // addi $s2, $zero, 42       ; $s2 = 42 (this is jumped to)
        memory[12] = 32'b001000_00000_10010_0000000000101010;
    end

    always @(*) begin
        instruction = memory[address[31:2]];
    end

endmodule
