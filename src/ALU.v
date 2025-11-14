//============================================================
// MIPS 32-bit ALU
// Supports all required operations for your 16 instructions
// Pure combinational logic (no clock)
//============================================================

module alu(
    input  wire [31:0] A,      // First operand (rs)
    input  wire [31:0] B,      // Second operand (rt or immediate)
    input  wire [3:0]  ALUCtrl,// Operation select from ALU Control
    input  wire [4:0]  shamt,  // Shift amount (for SLL, SRL, SRA)
    output reg  [31:0] Result, // ALU output
    output wire        Zero    // High if result == 0
);

    assign Zero = (Result == 32'b0);

    always @(*) begin
        case (ALUCtrl)

            //=====================
            // Arithmetic
            //=====================
            4'b0000: Result = A + B;          // ADD, ADDI, LW, SW
            4'b0001: Result = A - B;          // SUB

            //=====================
            // Logical ops
            //=====================
            4'b0010: Result = A & B;          // AND, ANDI
            4'b0011: Result = A | B;          // OR, ORI
            4'b0100: Result = A ^ B;          // XOR, XORI
            4'b0101: Result = ~(A | B);       // NOR

            //=====================
            // Shifts
            //=====================
            4'b0110: Result = B << shamt;     // SLL
            4'b0111: Result = B >> shamt;     // SRL (logical shift)
            4'b1000: Result = $signed(B) >>> shamt; // SRA (arithmetic shift)

            //=====================
            // Default case
            //=====================
            default: Result = 32'b0;

        endcase
    end

endmodule

