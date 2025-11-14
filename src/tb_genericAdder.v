`timescale 1ns/1ps

module tb_genericAdder;

    // Parameter override for the DUT
    parameter WIDTH = 32;

    reg  [WIDTH-1:0] A;
    reg  [WIDTH-1:0] B;
    wire [WIDTH-1:0] SUM;

    // Instantiate the DUT (Device Under Test)
    adder #(
        .WIDTH(WIDTH)
    ) uut (
        .A(A),
        .B(B),
        .SUM(SUM)
    );

    initial begin
        $dumpfile("genericAdder.vcd");
        $dumpvars(0, tb_genericAdder);

        // Test vectors
        A = 0; B = 0;     #10;
        A = 10; B = 5;    #10;
        A = 32'hFFFF_FFFF; B = 1; #10;
        A = 100; B = 200; #10;
        A = 12345; B = 54321; #10;

        $finish;
    end

    initial begin
        $monitor("Time=%0t | A=%h + B=%h = SUM=%h", $time, A, B, SUM);
    end

endmodule

