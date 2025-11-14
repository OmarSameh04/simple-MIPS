//============================================================
// Generic 2-to-1 Multiplexer
// Parameterized bit width
//============================================================
module mux2 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] A,   // input 0
    input  wire [WIDTH-1:0] B,   // input 1
    input  wire             sel, // select signal (0 = A, 1 = B)
    output wire [WIDTH-1:0] Y    // output
);

    assign Y = sel ? B : A;

endmodule

