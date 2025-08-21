# Pipelined RV32IM CPU Core

This repository showcases a custom-designed 5-stage pipelined RV32IM CPU core, built from the ground up with modularity, waveform-level validation, and architectural clarity in mind. It represents a significant leap from the single-cycle design, emphasizing control hazard handling, flush mechanisms, and extensible pipeline behavior.

## Overview

The CPU implements the RV32IM instruction set architecture with the following pipeline stages:

1. **IF (Instruction Fetch)**  
2. **ID (Instruction Decode & Register Read)**  
3. **EX (Execute / ALU Operations)**  
4. **MEM (Memory Access)**  
5. **WB (Write Back)**  

Each stage is modularly designed with clear interface boundaries and pipeline registers to ensure correct data/control propagation and hazard isolation.

## Key Features

- Full support for RV32I base instructions and RV32M extensions (e.g., `MUL`, `DIV`)
- Branch and jump logic with flush and control hazard mitigation
- Minimal test programs for validating instruction behavior and pipeline correctness
- Waveform-level validation using simulation traces
- Modular design for extensibility and future architectural enhancements
- Regression suite covering arithmetic, memory, and control flow instructions

## Validation Strategy

- **Waveform Probes**: Each architectural invariant is validated via waveform inspection, including register file updates, PC alignment, and memory access correctness.
- **Minimal Assembly Tests**: Custom programs (e.g., Fibonacci sequence, memory stress tests) are used to isolate and validate pipeline behavior.
- **Hazard Handling**: Control hazards are exercised through jump/branch sequences, with flush logic verified across edge cases.

## Directory Structure

