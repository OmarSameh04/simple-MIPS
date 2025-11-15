module register_file #(
    parameter REG_WIDTH = 32,
    parameter REG_ADDR_BITS = 5,
    parameter NUM_REGS = 1 << REG_ADDR_BITS
)(
    input  wire                      clk,        // clock added
    input  wire                      RegWrite,   // write enable
    input  wire [REG_ADDR_BITS-1:0]  read_reg1,  // read address 1
    input  wire [REG_ADDR_BITS-1:0]  read_reg2,  // read address 2
    input  wire [REG_ADDR_BITS-1:0]  write_reg,  // write address
    input  wire [REG_WIDTH-1:0]      write_data, // data to write
    output wire [REG_WIDTH-1:0]      read_data1, // read data 1
    output wire [REG_WIDTH-1:0]      read_data2  // read data 2
);

    // Register array
    reg [REG_WIDTH-1:0] regs [0:NUM_REGS-1];
    integer i;

    // Initialize all registers to 0
    initial begin
        for (i = 0; i < NUM_REGS; i = i + 1)
            regs[i] = 0;
    end

    // Clocked write
    always @(posedge clk) begin
        if (RegWrite && write_reg != 0)
            regs[write_reg] <= write_data;
    end

    // Combinational read
    assign read_data1 = (read_reg1 == 0) ? 0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 0 : regs[read_reg2];

endmodule
