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

 
                        // ===== Instruction Set C =====

        // C0: addi $t0, $zero, 100     ; $t0 = 100
        memory[0] = 32'b001000_00000_01000_0000000001100100;

        // C1: lw $t1, 0($t0)           ; t1 = MEM[t0]
        memory[1] = 32'b100011_01000_01001_0000000000000000;

        // C2: addi $t2, $t1, 5         ; RAW after load
        memory[2] = 32'b001000_01001_01010_0000000000000101;

        // C3: add $t3, $t2, $t1
        memory[3] = 32'b000000_01010_01001_01011_00000_100000;

        // C4: sub $t4, $t3, $t2
        memory[4] = 32'b000000_01011_01010_01100_00000_100010;

        // C5: xor $t5, $t4, $t1
        memory[5] = 32'b000000_01100_01001_01101_00000_100110;

        // C6: sw $t5, 4($t0)           ; MEM[t0+4] = t5
        memory[6] = 32'b101011_01000_01101_0000000000000100;

        // C7: sll $t6, $t5, 2
        memory[7] = 32'b000000_00000_01101_01110_00010_000000;

        // C8: addi $t7, $t6, 1
        memory[8] = 32'b001000_01110_01111_0000000000000001;

        // C9: j 40 (address = 10 instructions down)
        //     jump target = 10 << 2 = 40 = 0x00000028
        memory[9] = 32'b000010_000000000000000000001010;


    end

    always @(*) begin
        instruction = memory[address[31:2]];
    end

endmodule
