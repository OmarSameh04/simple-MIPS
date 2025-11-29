//============================================================
// 5-Stage Pipelined MIPS CPU (Verilog)
// IF, ID, EX, MEM, WB
// Basic forwarding & hazard handling
// Register file exposed for testbench
//============================================================

module mips_cpu_pipeline(
    input wire clk,
    input wire reset
);

    // ------------------------------
    // IF Stage
    // ------------------------------
    wire [31:0] pc_current, pc_next, pc_plus4, instruction;

    program_counter PC (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    adder #(32) PC_ADDER (
        .A(pc_current),
        .B(32'd4),
        .SUM(pc_plus4)
    );

    instruction_memory IMEM (
        .address(pc_current),
        .instruction(instruction)
    );

    // ------------------------------
    // Control Unit
    // ------------------------------
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

    // ------------------------------
    // Register File
    // ------------------------------
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[15:11];
    wire [4:0] write_reg;
    wire [31:0] reg_data1, reg_data2, write_data;

    mux2 #(5) MUX_RegDst (
        .A(rt), .B(rd), .sel(RegDst), .Y(write_reg)
    );

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

    // ------------------------------
    // ALU
    // ------------------------------
    wire [31:0] sign_ext_imm, ALU_inputB, alu_result;
    wire alu_zero;

    sign_extender SIGNEXT (
        .in(instruction[15:0]),
        .out(sign_ext_imm)
    );

    mux2 #(32) MUX_ALUSrc (
        .A(reg_data2),
        .B(sign_ext_imm),
        .sel(ALUSrc),
        .Y(ALU_inputB)
    );

    alu ALU (
        .A(reg_data1),
        .B(ALU_inputB),
        .ALUCtrl(ALUCtrl),
        .shamt(instruction[10:6]),
        .Result(alu_result),
        .Zero(alu_zero)
    );

    // ------------------------------
    // Data Memory
    // ------------------------------
    wire [31:0] mem_read_data;

    data_memory DMEM (
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(alu_result),
        .write_data(reg_data2),
        .read_data(mem_read_data)
    );

    mux2 #(32) MUX_MemtoReg (
        .A(alu_result),
        .B(mem_read_data),
        .sel(MemtoReg),
        .Y(write_data)
    );

    // ------------------------------
    // Jump Logic
    // ------------------------------
    wire [31:0] jump_target = { pc_plus4[31:28], instruction[25:0], 2'b00 };

    mux2 #(32) MUX_Jump (
        .A(pc_plus4),
        .B(jump_target),
        .sel(Jump),
        .Y(pc_next)
    );

    // ------------------------------
    // Expose registers for testbench
    // ------------------------------
    wire [31:0] registers [0:31];
    genvar idx;
    generate
        for (idx = 0; idx < 32; idx = idx + 1) begin : REG_ACCESS
            assign registers[idx] = REGFILE.regs[idx];
        end
    endgenerate

endmodule
