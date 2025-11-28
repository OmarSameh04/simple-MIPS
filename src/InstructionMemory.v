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
        // Test program
        // Arithmetic & Logical operations
        // ------------------------------

        // addi $t0, $zero, 5       ; $t0 = 5
        memory[0] = 32'b001000_00000_01000_0000000000000101;

        // addi $t1, $zero, 10      ; $t1 = 10
        memory[1] = 32'b001000_00000_01001_0000000000001010;

        // add $t2, $t0, $t1         ; $t2 = 5 + 10 = 15
        memory[2] = 32'b000000_01000_01001_01010_00000_100000;

        // sub $t3, $t1, $t0         ; $t3 = 10 - 5 = 5
        memory[3] = 32'b000000_01001_01000_01011_00000_100010;

        // and $t4, $t0, $t1         ; $t4 = 5 & 10 = 0
        memory[4] = 32'b000000_01000_01001_01100_00000_100100;

        // or $t5, $t0, $t1          ; $t5 = 5 | 10 = 15
        memory[5] = 32'b000000_01000_01001_01101_00000_100101;

        // xor $t6, $t0, $t1         ; $t6 = 5 ^ 10 = 15
        memory[6] = 32'b000000_01000_01001_01110_00000_100110;

        // sll $t7, $t1, 2           ; $t7 = 10 << 2 = 40
        memory[7] = 32'b000000_00000_01001_01111_00010_000000;

        // srl $s0, $t1, 1           ; $s0 = 10 >> 1 = 5 (logical shift)
        memory[8] = 32'b000000_00000_01001_10000_00001_000010;

        // sra $s1, $t1, 1           ; $s1 = 10 >> 1 = 5 (arithmetic shift)
        memory[9] = 32'b000000_00000_01001_10001_00001_000011;
    end

    always @(*) begin
        instruction = memory[address[31:2]];
    end

endmodule
