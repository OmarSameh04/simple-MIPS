//============================================================
// Sign Extender
// Default: extend 16-bit immediate to 32 bits
//============================================================
module sign_extender #(
    parameter IN_WIDTH  = 16,
    parameter OUT_WIDTH = 32
)(
    input  wire [IN_WIDTH-1:0]  in,
    output wire [OUT_WIDTH-1:0] out
);

    assign out = {{(OUT_WIDTH-IN_WIDTH){in[IN_WIDTH-1]}}, in};

endmodule

