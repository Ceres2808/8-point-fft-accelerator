module fft8(
    input clk,
    input rst,
    input [7:0] x0, x1, x2, x3, x4, x5, x6, x7, // 8-bit real inputs
    output reg [15:0] X0, X1, X2, X3, X4, X5, X6, X7 // 16-bit outputs (real part only)
);
    // Internal signals for butterfly stages
    reg [8:0] stage1 [0:7];
    reg [9:0] stage2 [0:7];
    reg [10:0] stage3 [0:7];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            X0 <= 0; X1 <= 0; X2 <= 0; X3 <= 0;
            X4 <= 0; X5 <= 0; X6 <= 0; X7 <= 0;
        end else begin
            // Stage 1: Pairwise addition/subtraction
            stage1[0] <= x0 + x4;
            stage1[1] <= x1 + x5;
            stage1[2] <= x2 + x6;
            stage1[3] <= x3 + x7;
            stage1[4] <= x0 - x4;
            stage1[5] <= x1 - x5;
            stage1[6] <= x2 - x6;
            stage1[7] <= x3 - x7;

            // Stage 2: More butterflies
            stage2[0] <= stage1[0] + stage1[2];
            stage2[1] <= stage1[1] + stage1[3];
            stage2[2] <= stage1[0] - stage1[2];
            stage2[3] <= stage1[1] - stage1[3];
            stage2[4] <= stage1[4] + stage1[6];
            stage2[5] <= stage1[5] + stage1[7];
            stage2[6] <= stage1[4] - stage1[6];
            stage2[7] <= stage1[5] - stage1[7];

            // Stage 3: Final butterflies (no twiddle factors for real input, 8-point)
            X0 <= stage2[0] + stage2[1];
            X4 <= stage2[0] - stage2[1];
            X2 <= stage2[2] + stage2[3];
            X6 <= stage2[2] - stage2[3];
            X1 <= stage2[4] + stage2[5];
            X5 <= stage2[4] - stage2[5];
            X3 <= stage2[6] + stage2[7];
            X7 <= stage2[6] - stage2[7];
        end
    end
endmodule
