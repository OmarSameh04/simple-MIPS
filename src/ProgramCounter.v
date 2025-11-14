module program_counter #(
    input  wire        clk,       // Clock signal
    input  wire        reset,     // Active-high reset
    input  wire [31:0] pc_next,   // Next PC value (from adder or branch logic)
    output reg  [31:0] pc_current // Current PC value (sent to instruction memory)
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_current <= 32'b0;        // Start execution at address 0
        else
            pc_current <= pc_next;      // Update PC each clock cycle
    end

endmodule
