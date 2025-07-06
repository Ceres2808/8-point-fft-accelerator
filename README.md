# 8-Point FFT Accelerator (Verilog)

A pipelined, fully verified 8-point complex FFT accelerator in Verilog, suitable for FPGA/ASIC and digital signal processing applications.

## Features
- Full 8-point radix-2 DIT FFT (complex inputs & outputs)
- 16-bit input, 32-bit output (Q16.16 fixed-point)
- Twiddle factor multiplication (hardware, Q1.15)
- 5-stage pipeline with start/valid handshaking
- Comprehensive testbench with NumPy reference checks

## Project Structure
\fft8_test
- [**fft8.v**](fft8_test/fft8.v): Verilog source code for the 8-point FFT module.
- [**fft8_tb.v**](fft8_test/fft8_tb.v): Testbench for simulating the FFT module.
- [**fft8_test**](fft8_test/fft8_test): Output or log file from the simulation.
- [**plots.png**](fft8_test/plots.png): Visualization of FFT results (e.g., input/output waveforms or spectra).
- [**test.vcd**](fft8_test/test.vcd): Value Change Dump file for waveform analysis.


## How to Run the Simulation

1. **Install Icarus Verilog** (if not already installed).
2. **Compile the design and testbench:**

```sh
iverilog -o fft8_test fft8.v fft8_tb.v
```

3. **Run the simulation:**

```sh
vvp fft8_test
```

4. **View waveforms** (optional, using GTKWave):

```sh
gtkwave test.vcd
```

## Results

- Accuracy: Matches NumPy FFT for all test cases (real, complex, zero input)
- Latency: 5 cycles per FFT
- Verified: Testbench compares hardware output to NumPy reference

Example plot:
![FFT Output Plot](fft8_test/plots.png)

- Modify test vectors in fft8_tb.v for your own input.
- Outputs are in Q16.16 format.
- Use gtkwave to view signals and debug.

**For details, see comments in the source code. If this project helps you, please star the repo!**
