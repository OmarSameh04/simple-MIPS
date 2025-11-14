`timescale 1ns/1ps

module sign_extender_tb;

    // Parameters
    localparam IN_WIDTH  = 16;
    localparam OUT_WIDTH = 32;

    // Testbench signals
    reg  [IN_WIDTH-1:0]  in;
    wire [OUT_WIDTH-1:0] out;

    // Instantiate DUT
    sign_extender #(IN_WIDTH, OUT_WIDTH) dut (
        .in(in),
        .out(out)
    );

    // Task for checking correctness
    task check;
        input [IN_WIDTH-1:0] in_val;
        reg   [OUT_WIDTH-1:0] expected;
    begin
        in = in_val;
        #1;

        expected = {{(OUT_WIDTH-IN_WIDTH){in_val[IN_WIDTH-1]}}, in_val};

        if (out !== expected)
            $display("ERROR: in=%h | expected=%h | got=%h", in_val, expected, out);
        else
            $display("OK:    in=%h | out=%h", in_val, out);
    end
    endtask

    initial begin
        // === VCD waveform dump ===
        $dumpfile("sign_extender_tb.vcd");   // name of the VCD file
        $dumpvars(0, sign_extender_tb);       // dump everything in this testbench

        $display("\n=== Sign Extender Testbench ===");

        check(16'h0000);
        check(16'h0001);
        check(16'h7FFF);
        check(16'h8000);
        check(16'hFFFF);
        check(16'hF00F);
        check(16'h1234);

        $display("=== Testbench DONE ===\n");
        $finish;
    end

endmodule
