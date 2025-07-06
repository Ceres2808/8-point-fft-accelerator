module fft8(
    input clk,
    input rst,
    input start,
    input signed [15:0] x0_real, x1_real, x2_real, x3_real, x4_real, x5_real, x6_real, x7_real,
    input signed [15:0] x0_imag, x1_imag, x2_imag, x3_imag, x4_imag, x5_imag, x6_imag, x7_imag,
    output reg signed [31:0] X0_real, X1_real, X2_real, X3_real, X4_real, X5_real, X6_real, X7_real,
    output reg signed [31:0] X0_imag, X1_imag, X2_imag, X3_imag, X4_imag, X5_imag, X6_imag, X7_imag,
    output reg valid
);

    // Fixed-point representation: 16.16 format for intermediate calculations
    // Twiddle factor constants (Q15 format: 1.15)
    localparam signed [15:0] TW_1_REAL =  16'h5A82;  // cos(π/4) ≈ 0.707
    localparam signed [15:0] TW_1_IMAG = -16'h5A82;  // -sin(π/4) ≈ -0.707
    localparam signed [15:0] TW_2_REAL =  16'h0000;  // cos(π/2) = 0
    localparam signed [15:0] TW_2_IMAG = -16'h8000;  // -sin(π/2) = -1
    localparam signed [15:0] TW_3_REAL = -16'h5A82;  // cos(3π/4) ≈ -0.707
    localparam signed [15:0] TW_3_IMAG = -16'h5A82;  // -sin(3π/4) ≈ -0.707

    // Stage registers for pipeline
    reg signed [31:0] stage1_real [0:7];
    reg signed [31:0] stage1_imag [0:7];
    reg signed [31:0] stage2_real [0:7];
    reg signed [31:0] stage2_imag [0:7];
    reg signed [31:0] stage3_real [0:7];
    reg signed [31:0] stage3_imag [0:7];
    
    // Pipeline control
    reg [2:0] pipeline_stage;
    reg processing;

    // Complex multiplier outputs
    wire signed [31:0] mult_out_real [0:3];
    wire signed [31:0] mult_out_imag [0:3];
    
    // Instantiate complex multipliers for twiddle factor multiplication
    complex_mult cmult0(
        .clk(clk),
        .a_real(stage2_real[1]),
        .a_imag(stage2_imag[1]),
        .b_real({TW_1_REAL, 16'b0}),
        .b_imag({TW_1_IMAG, 16'b0}),
        .result_real(mult_out_real[0]),
        .result_imag(mult_out_imag[0])
    );
    
    complex_mult cmult1(
        .clk(clk),
        .a_real(stage2_real[3]),
        .a_imag(stage2_imag[3]),
        .b_real({TW_2_REAL, 16'b0}),
        .b_imag({TW_2_IMAG, 16'b0}),
        .result_real(mult_out_real[1]),
        .result_imag(mult_out_imag[1])
    );
    
    complex_mult cmult2(
        .clk(clk),
        .a_real(stage2_real[5]),
        .a_imag(stage2_imag[5]),
        .b_real({TW_1_REAL, 16'b0}),
        .b_imag({TW_1_IMAG, 16'b0}),
        .result_real(mult_out_real[2]),
        .result_imag(mult_out_imag[2])
    );
    
    complex_mult cmult3(
        .clk(clk),
        .a_real(stage2_real[7]),
        .a_imag(stage2_imag[7]),
        .b_real({TW_3_REAL, 16'b0}),
        .b_imag({TW_3_IMAG, 16'b0}),
        .result_real(mult_out_real[3]),
        .result_imag(mult_out_imag[3])
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pipeline_stage <= 0;
            processing <= 0;
            valid <= 0;
            // Reset all output registers
            X0_real <= 0; X1_real <= 0; X2_real <= 0; X3_real <= 0;
            X4_real <= 0; X5_real <= 0; X6_real <= 0; X7_real <= 0;
            X0_imag <= 0; X1_imag <= 0; X2_imag <= 0; X3_imag <= 0;
            X4_imag <= 0; X5_imag <= 0; X6_imag <= 0; X7_imag <= 0;
        end else begin
            case (pipeline_stage)
                3'd0: begin
                    valid <= 0;
                    if (start && !processing) begin
                        processing <= 1;
                        pipeline_stage <= 1;
                        // Stage 1: Radix-2 butterflies (no twiddle factors)
                        stage1_real[0] <= {x0_real, 16'b0} + {x4_real, 16'b0};
                        stage1_imag[0] <= {x0_imag, 16'b0} + {x4_imag, 16'b0};
                        stage1_real[1] <= {x1_real, 16'b0} + {x5_real, 16'b0};
                        stage1_imag[1] <= {x1_imag, 16'b0} + {x5_imag, 16'b0};
                        stage1_real[2] <= {x2_real, 16'b0} + {x6_real, 16'b0};
                        stage1_imag[2] <= {x2_imag, 16'b0} + {x6_imag, 16'b0};
                        stage1_real[3] <= {x3_real, 16'b0} + {x7_real, 16'b0};
                        stage1_imag[3] <= {x3_imag, 16'b0} + {x7_imag, 16'b0};
                        stage1_real[4] <= {x0_real, 16'b0} - {x4_real, 16'b0};
                        stage1_imag[4] <= {x0_imag, 16'b0} - {x4_imag, 16'b0};
                        stage1_real[5] <= {x1_real, 16'b0} - {x5_real, 16'b0};
                        stage1_imag[5] <= {x1_imag, 16'b0} - {x5_imag, 16'b0};
                        stage1_real[6] <= {x2_real, 16'b0} - {x6_real, 16'b0};
                        stage1_imag[6] <= {x2_imag, 16'b0} - {x6_imag, 16'b0};
                        stage1_real[7] <= {x3_real, 16'b0} - {x7_real, 16'b0};
                        stage1_imag[7] <= {x3_imag, 16'b0} - {x7_imag, 16'b0};
                    end
                end
                
                3'd1: begin
                    pipeline_stage <= 2;
                    // Stage 2: Second set of butterflies (no twiddle factors yet)
                    stage2_real[0] <= stage1_real[0] + stage1_real[2];
                    stage2_imag[0] <= stage1_imag[0] + stage1_imag[2];
                    stage2_real[1] <= stage1_real[1] + stage1_real[3];
                    stage2_imag[1] <= stage1_imag[1] + stage1_imag[3];
                    stage2_real[2] <= stage1_real[0] - stage1_real[2];
                    stage2_imag[2] <= stage1_imag[0] - stage1_imag[2];
                    stage2_real[3] <= stage1_real[1] - stage1_real[3];
                    stage2_imag[3] <= stage1_imag[1] - stage1_imag[3];
                    stage2_real[4] <= stage1_real[4] + stage1_real[6];
                    stage2_imag[4] <= stage1_imag[4] + stage1_imag[6];
                    stage2_real[5] <= stage1_real[5] + stage1_real[7];
                    stage2_imag[5] <= stage1_imag[5] + stage1_imag[7];
                    stage2_real[6] <= stage1_real[4] - stage1_real[6];
                    stage2_imag[6] <= stage1_imag[4] - stage1_imag[6];
                    stage2_real[7] <= stage1_real[5] - stage1_real[7];
                    stage2_imag[7] <= stage1_imag[5] - stage1_imag[7];
                end
                
                3'd2: begin
                    pipeline_stage <= 3;
                    // Wait for complex multipliers (twiddle factor multiplication)
                end
                
                3'd3: begin
                    pipeline_stage <= 4;
                    // Stage 3: Final butterflies with twiddle factor results
                    stage3_real[0] <= stage2_real[0] + stage2_real[1];
                    stage3_imag[0] <= stage2_imag[0] + stage2_imag[1];
                    stage3_real[1] <= stage2_real[4] + mult_out_real[0];
                    stage3_imag[1] <= stage2_imag[4] + mult_out_imag[0];
                    stage3_real[2] <= stage2_real[2] + mult_out_real[1];
                    stage3_imag[2] <= stage2_imag[2] + mult_out_imag[1];
                    stage3_real[3] <= stage2_real[6] + mult_out_real[2];
                    stage3_imag[3] <= stage2_imag[6] + mult_out_imag[2];
                    stage3_real[4] <= stage2_real[0] - stage2_real[1];
                    stage3_imag[4] <= stage2_imag[0] - stage2_imag[1];
                    stage3_real[5] <= stage2_real[4] - mult_out_real[0];
                    stage3_imag[5] <= stage2_imag[4] - mult_out_imag[0];
                    stage3_real[6] <= stage2_real[2] - mult_out_real[1];
                    stage3_imag[6] <= stage2_imag[2] - mult_out_imag[1];
                    stage3_real[7] <= stage2_real[6] - mult_out_real[2];
                    stage3_imag[7] <= stage2_imag[6] - mult_out_imag[2];
                end
                
                3'd4: begin
                    pipeline_stage <= 0;
                    processing <= 0;
                    valid <= 1;
                    // Output with bit-reversal (DIT FFT characteristic)
                    X0_real <= stage3_real[0]; X0_imag <= stage3_imag[0]; // 000 -> 000
                    X1_real <= stage3_real[4]; X1_imag <= stage3_imag[4]; // 100 -> 001
                    X2_real <= stage3_real[2]; X2_imag <= stage3_imag[2]; // 010 -> 010
                    X3_real <= stage3_real[6]; X3_imag <= stage3_imag[6]; // 110 -> 011
                    X4_real <= stage3_real[1]; X4_imag <= stage3_imag[1]; // 001 -> 100
                    X5_real <= stage3_real[5]; X5_imag <= stage3_imag[5]; // 101 -> 101
                    X6_real <= stage3_real[3]; X6_imag <= stage3_imag[3]; // 011 -> 110
                    X7_real <= stage3_real[7]; X7_imag <= stage3_imag[7]; // 111 -> 111
                end
                
                default: pipeline_stage <= 0;
            endcase
        end
    end

endmodule

// Complex multiplier module
module complex_mult(
    input clk,
    input signed [31:0] a_real, a_imag,
    input signed [31:0] b_real, b_imag,
    output reg signed [31:0] result_real, result_imag
);

    reg signed [63:0] temp_real, temp_imag;
    reg signed [63:0] ac, bd, ad, bc;

    always @(posedge clk) begin
        // Stage 1: Multiply components
        ac <= a_real * b_real;
        bd <= a_imag * b_imag;
        ad <= a_real * b_imag;
        bc <= a_imag * b_real;
        
        // Stage 2: Combine results
        // (a+jb)(c+jd) = (ac-bd) + j(ad+bc)
        temp_real <= ac - bd;
        temp_imag <= ad + bc;
        
        // Stage 3: Scale back from Q31.32 to Q15.16
        result_real <= temp_real[47:16];  // Keep upper 32 bits
        result_imag <= temp_imag[47:16];  // Keep upper 32 bits
    end

endmodule
