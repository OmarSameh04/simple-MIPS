module instruction_memory #(
    parameter ADDR_WIDTH = 10,            // 2^10 = 1024 words = 4 KB
    parameter DATA_WIDTH = 32
)(
    input  wire [31:0] address,            // Current PC
    output reg  [31:0] instruction         // Instruction output
);
    // Internal memory array
    reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];

    // Initialize program contents
    initial begin
        // Example program (you can replace these later)
        memory[0] = 32'h20080005; // addi $t0, $zero, 5
        memory[1] = 32'h2009000A; // addi $t1, $zero, 10
        memory[2] = 32'h01095020; // add  $t2, $t0, $t1
        memory[3] = 32'h01285822; // sub  $t3, $t1, $t0
        memory[4] = 32'h01096024; // and  $t4, $t0, $t1
        memory[5] = 32'h01096825; // or   $t5, $t0, $t1
        memory[6] = 32'h01097026; // xor  $t6, $t0, $t1
        memory[7] = 32'h00097880; // sll  $t7, $t1, 2
        memory[8] = 32'h00098042; // srl  $s0, $t1, 1
        memory[9] = 32'h00098843; // sra  $s1, $t1, 1
    end

    // Asynchronous read (combinational)
    always @(*) begin
        instruction = memory[address[31:2]];  // Word-aligned access
    end

endmodule
