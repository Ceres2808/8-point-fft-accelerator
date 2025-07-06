`timescale 1ns/1ps

module fft8_tb;
    // Clock and reset
    reg clk, rst;
    // 8 real input signals (8 bits each)
    reg [7:0] x0, x1, x2, x3, x4, x5, x6, x7;
    // 8 FFT outputs (16 bits each)
    wire [15:0] X0, X1, X2, X3, X4, X5, X6, X7;

    // Instantiate the FFT module
    fft8 uut (
        .clk(clk), .rst(rst),
        .x0(x0), .x1(x1), .x2(x2), .x3(x3),
        .x4(x4), .x5(x5), .x6(x6), .x7(x7),
        .X0(X0), .X1(X1), .X2(X2), .X3(X3),
        .X4(X4), .X5(X5), .X6(X6), .X7(X7)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    initial begin
        // Set up waveform dump for GTKWave
        $dumpfile("test.vcd");
        $dumpvars(0, fft8_tb);

        // Initialize signals
        clk = 0;
        rst = 1;
        x0 = 8'd1; x1 = 8'd2; x2 = 8'd3; x3 = 8'd4;
        x4 = 8'd5; x5 = 8'd6; x6 = 8'd7; x7 = 8'd8;

        // Hold reset for a few cycles
        #20;
        rst = 0;

        // Wait for a few clock cycles to observe outputs
        #100;

        // Change input values to test another case
        x0 = 8'd10; x1 = 8'd20; x2 = 8'd30; x3 = 8'd40;
        x4 = 8'd50; x5 = 8'd60; x6 = 8'd70; x7 = 8'd80;

        #100;

        // Finish simulation
        $finish;
    end
endmodule
