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

 
                // ===== Instruction Set D =====

        // D0: addi $s0, $zero, 200     ; $s0 = 200
        memory[10] = 32'b001000_00000_10000_0000000011001000;

        // D1: lw $s1, 0($s0)
        memory[11] = 32'b100011_10000_10001_0000000000000000;

        // D2: addi $s2, $s1, 3
        memory[12] = 32'b001000_10001_10010_0000000000000011;

        // D3: add $s3, $s2, $s1
        memory[13] = 32'b000000_10010_10001_10011_00000_100000;

        // D4: and $s4, $s3, $s2
        memory[14] = 32'b000000_10011_10010_10100_00000_100100;

        // D5: or $s5, $s4, $s1
        memory[15] = 32'b000000_10100_10001_10101_00000_100101;

        // D6: sw $s5, 4($s0)
        memory[16] = 32'b101011_10000_10101_0000000000000100;

        // D7: lw $t0, 4($s0)
        memory[17] = 32'b100011_10000_01000_0000000000000100;

        // D8: sll $t1, $t0, 1
        memory[18] = 32'b000000_00000_01000_01001_00001_000000;

        // D9: j 60 (address = 15 instructions down)
        //     jump target = 15 << 2 = 60 = 0x0000003C
        memory[19] = 32'b000010_000000000000000000001111;


    end

    always @(*) begin
        instruction = memory[address[31:2]];
    end

endmodule
