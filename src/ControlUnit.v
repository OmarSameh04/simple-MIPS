//============================================================
// Single-Cycle MIPS Control Unit
// Takes full 32-bit instruction and outputs control signals
// including ALUCtrl (direct control of ALU)
//============================================================

module control_unit(
    input  wire [31:0] instruction,

    // Main datapath control signals
    output reg         RegDst,
    output reg         ALUSrc,
    output reg         MemtoReg,
    output reg         RegWrite,
    output reg         MemRead,
    output reg         MemWrite,
    output reg         Jump,

    // Direct ALU control
    output reg [3:0]   ALUCtrl
);

    // Extract opcode and funct fields
    wire [5:0] opcode = instruction[31:26];
    wire [5:0] funct  = instruction[5:0];

    always @(*) begin

        // Default values (safe)
        RegDst   = 0;
        ALUSrc   = 0;
        MemtoReg = 0;
        RegWrite = 0;
        MemRead  = 0;
        MemWrite = 0;
        Jump     = 0;
        ALUCtrl  = 4'b0000;

        case (opcode)

            //====================================================
            // R-TYPE (opcode = 000000)
            //====================================================
            6'b000000: begin
                RegDst   = 1;    // write to rd
                RegWrite = 1;

                case (funct)
                    6'b100000: ALUCtrl = 4'b0000; // ADD
                    6'b100010: ALUCtrl = 4'b0001; // SUB
                    6'b100100: ALUCtrl = 4'b0010; // AND
                    6'b100101: ALUCtrl = 4'b0011; // OR
                    6'b100111: ALUCtrl = 4'b0101; // NOR
                    6'b100110: ALUCtrl = 4'b0100; // XOR
                    6'b000000: ALUCtrl = 4'b0110; // SLL
                    6'b000010: ALUCtrl = 4'b0111; // SRL
                    6'b000011: ALUCtrl = 4'b1000; // SRA
                    default:   ALUCtrl = 4'b0000; // default safe
                endcase
            end

            //====================================================
            // ADDI (001000)
            //====================================================
            6'b001000: begin
                ALUSrc   = 1;
                RegWrite = 1;
                ALUCtrl  = 4'b0000; // ADD
            end

            //====================================================
            // ANDI (001100)
            //====================================================
            6'b001100: begin
                ALUSrc   = 1;
                RegWrite = 1;
                ALUCtrl  = 4'b0010; // AND
            end

            //====================================================
            // ORI (001101)
            //====================================================
            6'b001101: begin
                ALUSrc   = 1;
                RegWrite = 1;
                ALUCtrl  = 4'b0011; // OR
            end

            //====================================================
            // XORI (001110)
            //====================================================
            6'b001110: begin
                ALUSrc   = 1;
                RegWrite = 1;
                ALUCtrl  = 4'b0100; // XOR
            end

            //====================================================
            // LW (100011)
            //====================================================
            6'b100011: begin
                ALUSrc   = 1;
                RegWrite = 1;
                MemRead  = 1;
                MemtoReg = 1;
                ALUCtrl  = 4'b0000; // ADD (address)
            end

            //====================================================
            // SW (101011)
            //====================================================
            6'b101011: begin
                ALUSrc   = 1;
                MemWrite = 1;
                ALUCtrl  = 4'b0000; // ADD (address)
            end

            //====================================================
            // J (000010)
            //====================================================
            6'b000010: begin
                Jump = 1;
            end

            default: begin
                // Defaults already set
            end

        endcase
    end

endmodule
