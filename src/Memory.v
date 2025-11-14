//============================================================
// MIPS Data Memory (LW / SW)
// - Fully asynchronous: reads & writes update immediately
// - No clock required
// - Word-addressable: memory[address >> 2]
//============================================================

module data_memory #(
    parameter MEM_SIZE = 1024  // number of 32-bit words
)(
    input  wire        MemWrite,     // store enable
    input  wire        MemRead,      // load enable
    input  wire [31:0] address,      // byte address from ALU
    input  wire [31:0] write_data,   // data to store
    output reg  [31:0] read_data     // load result
);

    // 32-bit word memory
    reg [31:0] memory [0:MEM_SIZE-1];
    integer i;

    // Optional: initialize to zero
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1)
            memory[i] = 32'b0;
    end

    //============================================================
    // Asynchronous WRITE (dangerous in real hardware, but fine here)
    //============================================================
    always @(*) begin
        if (MemWrite)
            memory[address[31:2]] = write_data; // immediate update
    end

    //============================================================
    // Asynchronous READ
    //============================================================
    always @(*) begin
        if (MemRead)
            read_data = memory[address[31:2]];
        else
            read_data = 32'b0;
    end

endmodule

