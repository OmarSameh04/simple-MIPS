// Code your design here
//============================================================
// TOP-LEVEL SINGLE CYCLE MIPS CPU
// Using 4 muxes:
// 1) RegDst
// 2) ALUSrc
// 3) MemToReg
// 4) Jump
//============================================================

module mips_cpu(
    input wire clk,
    input wire reset
);

    //==============================
    // Program Counter
    //==============================
    wire [31:0] pc_current, pc_next, pc_plus4;

    program_counter PC (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    // pc + 4 adder
    adder #(32) PC_ADDER (
        .A(pc_current),
        .B(32'd4),
        .SUM(pc_plus4)
    );

    //==============================
    // Instruction Memory
    //==============================
    wire [31:0] instruction;

    instruction_memory IMEM (
        .address(pc_current),
        .instruction(instruction)
    );

    //==============================
    // Control Unit
    //==============================
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump;
    wire [3:0] ALUCtrl;

    control_unit CTRL (
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

    //==============================
    // Register File Connections
    //==============================
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[15:11];
    wire [4:0] write_reg;

    // REGDST MUX (rd or rt)
    mux2 #(5) MUX_RegDst (
        .A(rt),
        .B(rd),
        .sel(RegDst),
        .Y(write_reg)
    );

    // Register file wires
    wire [31:0] reg_data1, reg_data2, write_data;

    register_file REGFILE (
      	.clk(clk),
      	.RegWrite(RegWrite),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    //==============================
    // Immediate Generation
    //==============================
    wire [31:0] sign_ext_imm;

    sign_extender SIGNEXT (
        .in(instruction[15:0]),
        .out(sign_ext_imm)
    );

    // ALUSRC MUX (reg2 vs immediate)
    wire [31:0] ALU_inputB;

    mux2 #(32) MUX_ALUSrc (
        .A(reg_data2),
        .B(sign_ext_imm),
        .sel(ALUSrc),
        .Y(ALU_inputB)
    );

    //==============================
    // ALU
    //==============================
    wire [31:0] alu_result;
    wire alu_zero;

    alu ALU (
        .A(reg_data1),
        .B(ALU_inputB),
        .ALUCtrl(ALUCtrl),
        .shamt(instruction[10:6]),
        .Result(alu_result),
        .Zero(alu_zero)
    );

    //==============================
    // Data Memory
    //==============================
    wire [31:0] mem_read_data;

    data_memory DMEM (
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(alu_result),
        .write_data(reg_data2),
        .read_data(mem_read_data)
    );

    // MEMTOREG MUX
    mux2 #(32) MUX_MemtoReg (
        .A(alu_result),
        .B(mem_read_data),
        .sel(MemtoReg),
        .Y(write_data)
    );

    //==============================
    // JUMP Logic
    //==============================
    // Jump target = {PC+4[31:28], instruction[25:0] << 2}
    wire [31:0] jump_target = { pc_plus4[31:28], instruction[25:0], 2'b00 };

    // JUMP MUX
    mux2 #(32) MUX_Jump (
        .A(pc_plus4),
        .B(jump_target),
        .sel(Jump),
        .Y(pc_next)
    );

endmodule

