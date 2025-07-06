`timescale 1ns/1ps

module fft8_tb;
    // Clock and reset
    reg clk, rst, start;
    
    // Input signals (16-bit signed for real and imaginary parts)
    reg signed [15:0] x0_real, x1_real, x2_real, x3_real, x4_real, x5_real, x6_real, x7_real;
    reg signed [15:0] x0_imag, x1_imag, x2_imag, x3_imag, x4_imag, x5_imag, x6_imag, x7_imag;
    
    // Output signals (32-bit signed for real and imaginary parts)
    wire signed [31:0] X0_real, X1_real, X2_real, X3_real, X4_real, X5_real, X6_real, X7_real;
    wire signed [31:0] X0_imag, X1_imag, X2_imag, X3_imag, X4_imag, X5_imag, X6_imag, X7_imag;
    wire valid;

    // Expected results for verification
    reg signed [31:0] expected_real [0:7];
    reg signed [31:0] expected_imag [0:7];
    
    // Error tracking
    integer error_count;
    real tolerance = 1000.0; // Allow some tolerance for fixed-point arithmetic

    // Instantiate the FFT module
    fft8 uut (
        .clk(clk), .rst(rst), .start(start),
        .x0_real(x0_real), .x1_real(x1_real), .x2_real(x2_real), .x3_real(x3_real),
        .x4_real(x4_real), .x5_real(x5_real), .x6_real(x6_real), .x7_real(x7_real),
        .x0_imag(x0_imag), .x1_imag(x1_imag), .x2_imag(x2_imag), .x3_imag(x3_imag),
        .x4_imag(x4_imag), .x5_imag(x5_imag), .x6_imag(x6_imag), .x7_imag(x7_imag),
        .X0_real(X0_real), .X1_real(X1_real), .X2_real(X2_real), .X3_real(X3_real),
        .X4_real(X4_real), .X5_real(X5_real), .X6_real(X6_real), .X7_real(X7_real),
        .X0_imag(X0_imag), .X1_imag(X1_imag), .X2_imag(X2_imag), .X3_imag(X3_imag),
        .X4_imag(X4_imag), .X5_imag(X5_imag), .X6_imag(X6_imag), .X7_imag(X7_imag),
        .valid(valid)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    // Task to check results
    task check_results;
        input [7*8-1:0] test_name;
        integer i;
        real real_error, imag_error;
        begin
            $display("\n=== %s ===", test_name);
            $display("Index | Expected Real | Expected Imag | Actual Real   | Actual Imag   | Error");
            $display("------|---------------|---------------|---------------|---------------|-------");
            
            error_count = 0;
            for (i = 0; i < 8; i = i + 1) begin
                case (i)
                    0: begin
                        real_error = $abs($signed(expected_real[i]) - $signed(X0_real));
                        imag_error = $abs($signed(expected_imag[i]) - $signed(X0_imag));
                        $display("  %0d   | %11d   | %11d   | %11d   | %11d   | %5.1f", 
                                i, expected_real[i], expected_imag[i], X0_real, X0_imag, real_error + imag_error);
                    end
                    1: begin
                        real_error = $abs($signed(expected_real[i]) - $signed(X1_real));
                        imag_error = $abs($signed(expected_imag[i]) - $signed(X1_imag));
                        $display("  %0d   | %11d   | %11d   | %11d   | %11d   | %5.1f", 
                                i, expected_real[i], expected_imag[i], X1_real, X1_imag, real_error + imag_error);
                    end
                    2: begin
                        real_error = $abs($signed(expected_real[i]) - $signed(X2_real));
                        imag_error = $abs($signed(expected_imag[i]) - $signed(X2_imag));
                        $display("  %0d   | %11d   | %11d   | %11d   | %11d   | %5.1f", 
                                i, expected_real[i], expected_imag[i], X2_real, X2_imag, real_error + imag_error);
                    end
                    3: begin
                        real_error = $abs($signed(expected_real[i]) - $signed(X3_real));
                        imag_error = $abs($signed(expected_imag[i]) - $signed(X3_imag));
                        $display("  %0d   | %11d   | %11d   | %11d   | %11d   | %5.1f", 
                                i, expected_real[i], expected_imag[i], X3_real, X3_imag, real_error + imag_error);
                    end
                    4: begin
                        real_error = $abs($signed(expected_real[i]) - $signed(X4_real));
                        imag_error = $abs($signed(expected_imag[i]) - $signed(X4_imag));
                        $display("  %0d   | %11d   | %11d   | %11d   | %11d   | %5.1f", 
                                i, expected_real[i], expected_imag[i], X4_real, X4_imag, real_error + imag_error);
                    end
                    5: begin
                        real_error = $abs($signed(expected_real[i]) - $signed(X5_real));
                        imag_error = $abs($signed(expected_imag[i]) - $signed(X5_imag));
                        $display("  %0d   | %11d   | %11d   | %11d   | %11d   | %5.1f", 
                                i, expected_real[i], expected_imag[i], X5_real, X5_imag, real_error + imag_error);
                    end
                    6: begin
                        real_error = $abs($signed(expected_real[i]) - $signed(X6_real));
                        imag_error = $abs($signed(expected_imag[i]) - $signed(X6_imag));
                        $display("  %0d   | %11d   | %11d   | %11d   | %11d   | %5.1f", 
                                i, expected_real[i], expected_imag[i], X6_real, X6_imag, real_error + imag_error);
                    end
                    7: begin
                        real_error = $abs($signed(expected_real[i]) - $signed(X7_real));
                        imag_error = $abs($signed(expected_imag[i]) - $signed(X7_imag));
                        $display("  %0d   | %11d   | %11d   | %11d   | %11d   | %5.1f", 
                                i, expected_real[i], expected_imag[i], X7_real, X7_imag, real_error + imag_error);
                    end
                endcase
                
                if ((real_error > tolerance) || (imag_error > tolerance)) begin
                    error_count = error_count + 1;
                    $display("ERROR: Output X[%0d] exceeds tolerance!", i);
                end
            end
            
            if (error_count == 0) begin
                $display("✓ PASS: All outputs within tolerance");
            end else begin
                $display("✗ FAIL: %0d outputs exceed tolerance", error_count);
            end
        end
    endtask

    initial begin
        // Set up waveform dump for GTKWave
        $dumpfile("test.vcd");
        $dumpvars(0, fft8_tb);

        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        error_count = 0;

        // Reset all inputs
        x0_real = 0; x1_real = 0; x2_real = 0; x3_real = 0;
        x4_real = 0; x5_real = 0; x6_real = 0; x7_real = 0;
        x0_imag = 0; x1_imag = 0; x2_imag = 0; x3_imag = 0;
        x4_imag = 0; x5_imag = 0; x6_imag = 0; x7_imag = 0;

        // Hold reset for a few cycles
        #50;
        rst = 0;
        #20;

        // Test Case 1: Real input sequence [1, 2, 3, 4, 5, 6, 7, 8]
        $display("Starting Test Case 1: Real input [1, 2, 3, 4, 5, 6, 7, 8]");
        x0_real = 16'd1; x1_real = 16'd2; x2_real = 16'd3; x3_real = 16'd4;
        x4_real = 16'd5; x5_real = 16'd6; x6_real = 16'd7; x7_real = 16'd8;
        x0_imag = 0; x1_imag = 0; x2_imag = 0; x3_imag = 0;
        x4_imag = 0; x5_imag = 0; x6_imag = 0; x7_imag = 0;
        
        // Expected results (converted to fixed-point Q16.16)
        expected_real[0] = 32'd2359296;   // 36.0 * 65536
        expected_real[1] = -32'd262144;   // -4.0 * 65536
        expected_real[2] = -32'd262144;   // -4.0 * 65536
        expected_real[3] = -32'd262144;   // -4.0 * 65536
        expected_real[4] = -32'd262144;   // -4.0 * 65536
        expected_real[5] = -32'd262144;   // -4.0 * 65536
        expected_real[6] = -32'd262144;   // -4.0 * 65536
        expected_real[7] = -32'd262144;   // -4.0 * 65536
        
        expected_imag[0] = 32'd0;         // 0.0 * 65536
        expected_imag[1] = 32'd632736;    // 9.657 * 65536
        expected_imag[2] = 32'd262144;    // 4.0 * 65536
        expected_imag[3] = 32'd108543;    // 1.657 * 65536
        expected_imag[4] = 32'd0;         // 0.0 * 65536
        expected_imag[5] = -32'd108543;   // -1.657 * 65536
        expected_imag[6] = -32'd262144;   // -4.0 * 65536
        expected_imag[7] = -32'd632736;   // -9.657 * 65536

        start = 1;
        #10;
        start = 0;
        
        // Wait for valid output
        wait(valid);
        #10;
        check_results("Test Case 1");

        #100;

        // Test Case 2: Complex input sequence
        $display("\nStarting Test Case 2: Complex input");
        x0_real = 16'd1; x1_real = 16'd0; x2_real = -16'd1; x3_real = 16'd0;
        x4_real = 16'd1; x5_real = 16'd0; x6_real = -16'd1; x7_real = 16'd0;
        x0_imag = 16'd0; x1_imag = 16'd1; x2_imag = 16'd0; x3_imag = -16'd1;
        x4_imag = 16'd0; x5_imag = 16'd1; x6_imag = 16'd0; x7_imag = -16'd1;
        
        // Expected results for this complex test case
        expected_real[0] = 32'd0;         // 0.0 * 65536
        expected_real[1] = 32'd0;         // 0.0 * 65536
        expected_real[2] = 32'd262144;    // 4.0 * 65536
        expected_real[3] = 32'd0;         // 0.0 * 65536
        expected_real[4] = 32'd0;         // 0.0 * 65536
        expected_real[5] = 32'd0;         // 0.0 * 65536
        expected_real[6] = 32'd262144;    // 4.0 * 65536
        expected_real[7] = 32'd0;         // 0.0 * 65536
        
        expected_imag[0] = 32'd0;         // 0.0 * 65536
        expected_imag[1] = 32'd262144;    // 4.0 * 65536
        expected_imag[2] = 32'd0;         // 0.0 * 65536
        expected_imag[3] = 32'd262144;    // 4.0 * 65536
        expected_imag[4] = 32'd0;         // 0.0 * 65536
        expected_imag[5] = 32'd262144;    // 4.0 * 65536
        expected_imag[6] = 32'd0;         // 0.0 * 65536
        expected_imag[7] = 32'd262144;    // 4.0 * 65536

        start = 1;
        #10;
        start = 0;
        
        wait(valid);
        #10;
        check_results("Test Case 2");

        #100;

        // Test Case 3: All zeros (edge case)
        $display("\nStarting Test Case 3: All zeros");
        x0_real = 0; x1_real = 0; x2_real = 0; x3_real = 0;
        x4_real = 0; x5_real = 0; x6_real = 0; x7_real = 0;
        x0_imag = 0; x1_imag = 0; x2_imag = 0; x3_imag = 0;
        x4_imag = 0; x5_imag = 0; x6_imag = 0; x7_imag = 0;
        
        // Expected: all zeros
        for (integer j = 0; j < 8; j = j + 1) begin
            expected_real[j] = 0;
            expected_imag[j] = 0;
        end

        start = 1;
        #10;
        start = 0;
        
        wait(valid);
        #10;
        check_results("Test Case 3");

        #100;

        // Summary
        $display("\n=== SIMULATION SUMMARY ===");
        $display("FFT module verification completed");
        $display("All test cases processed");
        $display("Note: Small errors are expected due to fixed-point arithmetic");
        
        $finish;
    end

endmodule
