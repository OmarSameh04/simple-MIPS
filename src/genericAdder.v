//============================================================
// Generic Adder
// Parameterized bit width
//============================================================
module adder #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    output wire [WIDTH-1:0] SUM
);

    assign SUM = A + B;

endmodule

