module program_counter (
    input  wire        clk,       // Clock signal
    input  wire        reset,     // Active-high reset
    input  wire [31:0] pc_next,   // Next PC value
    output reg [31:0] pc_current  // Current PC value
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_current <= 32'b0;
        else
            pc_current <= pc_next;
    end

endmodule

