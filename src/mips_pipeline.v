//============================================================
// 5-Stage Pipelined MIPS CPU (basic)
// - IF, ID, EX, MEM, WB
// - Basic forwarding (EX/MEM, MEM/WB)
// - Load-use stall (1 cycle)
// - Jump handled in ID stage (flush IF/ID)
// This pipeline reuses existing modules in the repo.
//============================================================

module mips_cpu_pipeline(
    input wire clk,
    input wire reset
);

    //==============================
    // IF stage wires
    //==============================
    wire [31:0] pc_current, pc_next, pc_plus4;
    wire [31:0] if_instruction;

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
        .instruction(if_instruction)
    );

    // IF/ID pipeline register
    reg [31:0] IFID_pc_plus4;
    reg [31:0] IFID_instruction;

    // Control signals for stalling and flushing
    reg stall;
    reg flush_ifid;

    //==============================
    // ID stage wires
    //==============================
    wire RegDst_id, ALUSrc_id, MemtoReg_id, RegWrite_id, MemRead_id, MemWrite_id, Jump_id;
    wire [3:0] ALUCtrl_id;

    control_unit CTRL_ID (
        .instruction(IFID_instruction),
        .RegDst(RegDst_id),
        .ALUSrc(ALUSrc_id),
        .MemtoReg(MemtoReg_id),
        .RegWrite(RegWrite_id),
        .MemRead(MemRead_id),
        .MemWrite(MemWrite_id),
        .Jump(Jump_id),
        .ALUCtrl(ALUCtrl_id)
    );

    //==============================
    // Register file - single instance used for both read and write
    //==============================
    wire [4:0] rs_id = IFID_instruction[25:21];
    wire [4:0] rt_id = IFID_instruction[20:16];
    wire [4:0] rd_id = IFID_instruction[15:11];
    wire [31:0] reg_data1_id, reg_data2_id;
    reg regfile_RegWrite;
    reg [4:0] regfile_write_reg;
    reg [31:0] regfile_write_data;

    register_file REGFILE (
        .clk(clk),
        .RegWrite(regfile_RegWrite),
        .read_reg1(rs_id),
        .read_reg2(rt_id),
        .write_reg(regfile_write_reg),
        .write_data(regfile_write_data),
        .read_data1(reg_data1_id),
        .read_data2(reg_data2_id)
    );

    // Sign-extend immediate
    wire [31:0] sign_ext_imm_id;
    sign_extender SIGNEXT_ID (
        .in(IFID_instruction[15:0]),
        .out(sign_ext_imm_id)
    );

    // Jump target
    wire [31:0] jump_target_id = { IFID_pc_plus4[31:28], IFID_instruction[25:0], 2'b00 };

    //==============================
    // ID/EX pipeline register
    //==============================
    // Control signals passed into EX stage
    reg RegDst_ex, ALUSrc_ex, MemtoReg_ex, RegWrite_ex, MemRead_ex, MemWrite_ex;
    reg [3:0] ALUCtrl_ex;

    // Data in EX stage
    reg [31:0] EX_reg_data1;
    reg [31:0] EX_reg_data2;
    reg [31:0] EX_sign_ext_imm;
    reg [4:0] EX_rs, EX_rt, EX_rd;
    reg [4:0] EX_shamt;

    //==============================
    // EX stage wires
    //==============================
    wire [4:0] write_reg_ex = RegDst_ex ? EX_rd : EX_rt;

    // Forwarding signals
    reg [1:0] forwardA, forwardB;

    // ALU operand selection (with forwarding)
    wire [31:0] ALU_inA;
    wire [31:0] ALU_inB_pre;
    wire [31:0] ALU_inB = ALUSrc_ex ? EX_sign_ext_imm : ALU_inB_pre;

    // ALU result (combinational output from ALU)
    wire [31:0] alu_result_comb;

    // EX/MEM pipeline regs
    reg [31:0] EXMEM_alu_result;
    reg [31:0] EXMEM_write_data; // reg_data2 forwarded
    reg [4:0] EXMEM_write_reg;
    reg EXMEM_MemRead, EXMEM_MemWrite, EXMEM_MemtoReg, EXMEM_RegWrite;

    //==============================
    // MEM stage wires
    //==============================
    wire [31:0] mem_read_data;

    data_memory DMEM (
        .MemWrite(EXMEM_MemWrite),
        .MemRead(EXMEM_MemRead),
        .address(EXMEM_alu_result),
        .write_data(EXMEM_write_data),
        .read_data(mem_read_data)
    );

    // MEM/WB pipeline regs
    reg [31:0] MEM_alu_result;
    reg [31:0] MEM_mem_read_data;
    reg [4:0] MEM_write_reg;
    reg MEM_MemtoReg, MEM_RegWrite;

    //==============================
    // WB stage wires
    //==============================
    wire [31:0] WB_write_data = MEM_MemtoReg ? MEM_mem_read_data : MEM_alu_result;
    wire WB_RegWrite = MEM_RegWrite;
    wire [4:0] WB_write_reg = MEM_write_reg;

    // Update register file write ports at WB (synchronous write happens inside register_file on posedge)
    always @(*) begin
        regfile_RegWrite = WB_RegWrite;
        regfile_write_reg = WB_write_reg;
        regfile_write_data = WB_write_data;
    end

    //==============================
    // ALU and forwarding logic (combinational)
    //==============================
    // Forward A selection
    assign ALU_inA = (forwardA == 2'b00) ? EX_reg_data1 :
                     (forwardA == 2'b10) ? alu_result_comb :
                     (forwardA == 2'b01) ? WB_write_data : 32'd0;

    // Forward B pre-selection
    assign ALU_inB_pre = (forwardB == 2'b00) ? EX_reg_data2 :
                         (forwardB == 2'b10) ? alu_result_comb :
                         (forwardB == 2'b01) ? WB_write_data : 32'd0;

    // ALU instance
    alu ALU_EX (
        .A(ALU_inA),
        .B(ALU_inB),
        .ALUCtrl(ALUCtrl_ex),
        .shamt(EX_shamt),
        .Result(alu_result_comb),
        .Zero() // not used here for branches
    );

    //==============================
    // Pipeline registers update (clocked)
    //==============================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // IF/ID
            IFID_pc_plus4 <= 32'd0;
            IFID_instruction <= 32'd0;

            // ID/EX
            RegDst_ex <= 0; ALUSrc_ex <= 0; MemtoReg_ex <= 0; RegWrite_ex <= 0; MemRead_ex <= 0; MemWrite_ex <= 0;
            ALUCtrl_ex <= 4'd0;
            EX_reg_data1 <= 32'd0; EX_reg_data2 <= 32'd0; EX_sign_ext_imm <= 32'd0;
            EX_rs <= 5'd0; EX_rt <= 5'd0; EX_rd <= 5'd0; EX_shamt <= 5'd0;

            // EX/MEM
            EXMEM_alu_result <= 32'd0; EXMEM_write_data <= 32'd0; EXMEM_write_reg <= 5'd0;
            EXMEM_MemRead <= 0; EXMEM_MemWrite <= 0; EXMEM_MemtoReg <= 0; EXMEM_RegWrite <= 0;

            // MEM/WB
            MEM_alu_result <= 32'd0; MEM_mem_read_data <= 32'd0; MEM_write_reg <= 5'd0; MEM_MemtoReg <= 0; MEM_RegWrite <= 0;
        end else begin
            // Handle PC and IF/ID update based on stall/flush
            if (!stall) begin
                IFID_pc_plus4 <= pc_plus4;
                IFID_instruction <= if_instruction;
            end else begin
                // hold IF/ID (do not update) on stall
                IFID_pc_plus4 <= IFID_pc_plus4;
                IFID_instruction <= IFID_instruction;
            end

            if (flush_ifid) begin
                IFID_instruction <= 32'd0; // insert bubble
            end

            // ID -> EX pipeline register (either normal update or bubble on stall)
            if (stall) begin
                // insert bubble into EX stage (clear control signals)
                RegDst_ex <= 0; ALUSrc_ex <= 0; MemtoReg_ex <= 0; RegWrite_ex <= 0; MemRead_ex <= 0; MemWrite_ex <= 0;
                ALUCtrl_ex <= 4'd0;
                EX_reg_data1 <= 32'd0; EX_reg_data2 <= 32'd0; EX_sign_ext_imm <= 32'd0;
                EX_rs <= 5'd0; EX_rt <= 5'd0; EX_rd <= 5'd0; EX_shamt <= 5'd0;
            end else begin
                RegDst_ex <= RegDst_id;
                ALUSrc_ex <= ALUSrc_id;
                MemtoReg_ex <= MemtoReg_id;
                RegWrite_ex <= RegWrite_id;
                MemRead_ex <= MemRead_id;
                MemWrite_ex <= MemWrite_id;
                ALUCtrl_ex <= ALUCtrl_id;

                EX_reg_data1 <= reg_data1_id;
                EX_reg_data2 <= reg_data2_id;
                EX_sign_ext_imm <= sign_ext_imm_id;
                EX_rs <= rs_id;
                EX_rt <= rt_id;
                EX_rd <= rd_id;
                EX_shamt <= IFID_instruction[10:6];
            end

            // EX -> MEM
            EXMEM_write_reg <= write_reg_ex;
            EXMEM_write_data <= EX_reg_data2; // capture before forwarding for memory write; forwarding handled combinationally for ALU
            EXMEM_alu_result <= alu_result_comb; // capture combinational ALU result
            EXMEM_MemRead <= MemRead_ex;
            EXMEM_MemWrite <= MemWrite_ex;
            EXMEM_MemtoReg <= MemtoReg_ex;
            EXMEM_RegWrite <= RegWrite_ex;

            // MEM -> WB
            MEM_alu_result <= EXMEM_alu_result;
            MEM_mem_read_data <= mem_read_data;
            MEM_write_reg <= EXMEM_write_reg;
            MEM_MemtoReg <= EXMEM_MemtoReg;
            MEM_RegWrite <= EXMEM_RegWrite;
        end
    end

    //==============================
    // Hazard detection (load-use) and forwarding unit (combinational)
    //==============================
    always @(*) begin
        // Default
        stall = 0;
        flush_ifid = 0;

        // Load-use hazard: if ID/EX.MemRead and ID/EX.rt == IF/ID.rs or IF/ID.rt then stall
        if (MemRead_ex && ( (EX_rt != 0) && ( (EX_rt == IFID_instruction[25:21]) || (EX_rt == IFID_instruction[20:16]) ) )) begin
            stall = 1;
        end

        // Forwarding decisions for ALU inputs
        // forwardA: 00 = from EX.reg_data1, 10 = from EX/MEM.alu_result, 01 = from MEM/WB.write_data
        if (EXMEM_RegWrite && (EXMEM_write_reg != 0) && (EXMEM_write_reg == EX_rs)) begin
            forwardA = 2'b10;
        end else if (MEM_RegWrite && (MEM_write_reg != 0) && (MEM_write_reg == EX_rs)) begin
            forwardA = 2'b01;
        end else begin
            forwardA = 2'b00;
        end

        // forwardB for second operand
        if (EXMEM_RegWrite && (EXMEM_write_reg != 0) && (EXMEM_write_reg == EX_rt)) begin
            forwardB = 2'b10;
        end else if (MEM_RegWrite && (MEM_write_reg != 0) && (MEM_write_reg == EX_rt)) begin
            forwardB = 2'b01;
        end else begin
            forwardB = 2'b00;
        end
    end

    //==============================
    // PC update logic (combinational)
    // - handle jump in ID stage: if Jump_id then next PC = jump_target_id
    // - if stall: hold PC (pc_next = pc_current)
    // - otherwise pc_plus4
    //==============================
    assign pc_next = (stall) ? pc_current : (Jump_id ? jump_target_id : pc_plus4);

endmodule
