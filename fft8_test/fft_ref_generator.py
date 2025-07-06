"""
fft_reference_generator.py

Generates NumPy FFT reference results for 8-point inputs.
Supports:
 - Standard test cases (real, complex, zeros)
 - Custom CSV input
 - Verilog Q16.16 output
 - Optional magnitude/phase plots
 - Error comparison if hardware CSV provided
"""

import numpy as np
import argparse
import csv
import os
import matplotlib.pyplot as plt

SCALE = 1 << 16

def to_fixed(x):
    return int(np.round(x * SCALE))

def compute_fft(x):
    return np.fft.fft(x)

def save_csv(filename, X):
    with open(filename, 'w', newline='') as f:
        w = csv.writer(f)
        w.writerow(["k", "real_fp", "imag_fp", "real_f", "imag_f", "mag", "phase"])
        for k, val in enumerate(X):
            r_fp = to_fixed(val.real)
            i_fp = to_fixed(val.imag)
            mag = np.abs(val)
            phase = np.angle(val, deg=True)
            w.writerow([k, r_fp, i_fp, f"{val.real:.6f}", f"{val.imag:.6f}", f"{mag:.6f}", f"{phase:.2f}"])

def plot_spectrum(X, title, out_png):
    k = np.arange(len(X))
    mag = np.abs(X)
    phase = np.angle(X, deg=True)
    plt.figure(figsize=(8,4))
    plt.subplot(1,2,1)
    plt.stem(k, mag, basefmt=" ")
    plt.title(f"{title} Magnitude")
    plt.xlabel("k"); plt.ylabel("|X[k]|")
    plt.subplot(1,2,2)
    plt.stem(k, phase, basefmt=" ")
    plt.title(f"{title} Phase")
    plt.xlabel("k"); plt.ylabel("Phase (°)")
    plt.tight_layout()
    plt.savefig(out_png)
    plt.close()

def print_verilog(X):
    for k, val in enumerate(X):
        print(f"// k={k}: {val.real:.6f} + j{val.imag:.6f}")
        print(f"expected_real[{k}] = 32'd{to_fixed(val.real)}; expected_imag[{k}] = 32'd{to_fixed(val.imag)};")

def load_csv_input(path):
    x = []
    with open(path) as f:
        r = csv.reader(f)
        for row in r:
            re, im = float(row[0]), float(row[1])
            x.append(re + 1j*im)
    return np.array(x, dtype=np.complex64)

def main():
    p = argparse.ArgumentParser(description="8-point FFT reference generator")
    p.add_argument("--input", help="CSV file of 8 rows: real,imag")
    p.add_argument("--out-csv", help="Save reference CSV")
    p.add_argument("--plot", action="store_true", help="Generate magnitude/phase plot")
    p.add_argument("--verilog", action="store_true", help="Print Verilog assignments")
    p.add_argument("--hw-csv", help="Compare hardware outputs CSV file (k,real_fp,imag_fp)")
    args = p.parse_args()

    # Load or use default test
    if args.input:
        x = load_csv_input(args.input)
        title = os.path.basename(args.input)
    else:
        # default real sequence
        x = np.array([1,2,3,4,5,6,7,8], dtype=np.complex64)
        title = "real_seq"

    X = compute_fft(x)

    if args.out_csv:
        save_csv(args.out_csv, X)
        print(f"Saved reference CSV to {args.out_csv}")
    if args.plot:
        png = f"{title}_spectrum.png"
        plot_spectrum(X, title, png)
        print(f"Saved plot to {png}")
    if args.verilog:
        print_verilog(X)
    if args.hw_csv and os.path.exists(args.hw_csv):
        # Compare hardware vs reference
        hw = []
        with open(args.hw_csv) as f:
            for row in csv.reader(f):
                k, r_fp, i_fp = int(row[0]), int(row[1]), int(row[2])
                hw.append(r_fp + 1j*i_fp)
        hw = np.array(hw, dtype=np.complex64)
        errs = np.abs((hw.astype(np.float32)/SCALE) - X)
        print("Max error:", np.max(errs))

if __name__ == "__main__":
    main()
