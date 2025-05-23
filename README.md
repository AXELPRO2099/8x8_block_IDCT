# 8x8 Block IDCT Module

## Overview

This project implements an 8x8 Block Inverse Discrete Cosine Transform (IDCT) in SystemVerilog. The `top.sv` module processes 8x8 blocks of 16-bit signed DCT coefficients and outputs 8x8 blocks of 8-bit unsigned pixel values. The module is designed for use in image processing applications such as JPEG decoding.

### Features:
- **Fixed-point arithmetic**: 16-bit signed fixed-point numbers for accuracy.
- **FSM-based control**: A finite state machine (FSM) manages the process.
- **Efficient Image Processing**: Implements row-wise and column-wise 8x8 IDCT operations.

## Inputs and Outputs

### Inputs:
- **x [0:7][0:7]**: 8x8 array of 16-bit signed DCT coefficients.
- **sys_clk**: System clock (100 MHz).
- **sys_rst**: Reset signal (active high).
- **start**: Start signal to begin IDCT processing.

### Outputs:
- **done**: Signal indicating the completion of the IDCT process.
- **pixel_out [0:7][0:7]**: 8x8 array of 8-bit unsigned pixel values (resulting image).

## Synthesis and Simulation

- **Clock Frequency**: 100 MHz
- **Resource Usage**: 
  - 2062 LUTs
  - 4795 Slice Registers
  - 692 F7 Muxes
  - 220 F8 Muxes
  - 6 DSPs
  - 3 BUFGCTRLs

## Testbench

The `idct_tb.sv` testbench file is provided for simulation. It verifies the functionality of the `top.sv` module by providing clock, reset, and input stimuli.

## Conclusion

The 8x8 Block IDCT module efficiently processes DCT coefficients and produces pixel values, suitable for applications like JPEG decoding. The design utilizes fixed-point arithmetic and an FSM for control, ensuring reliable operation in hardware.
