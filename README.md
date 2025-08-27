# RV32IM Pipelined CPU

This repository contains a custom implementation of a pipelined CPU based on the RISC-V RV32IM instruction set architecture. The design leverages pipelining to achieve higher instruction throughput and improved performance, making it suitable for educational purposes, CPU architecture exploration, and hardware prototyping.

## Features

- **RV32IM Support**: Implements the full 32-bit base integer instruction set (RV32I), plus multiplication and division extensions (M).
- **5-Stage Pipeline**: Fetch, Decode, Execute, Memory, and Write-back stages for efficient instruction processing.
- **Hazard Handling**: Includes basic mechanisms for data forwarding and pipeline stalling to resolve data and control hazards.s
- **Memory Interface**: Supports interaction with instruction and data memory modules.
- **Testbench**: Reference testbench for simulation and validation.

## Block diagram

<img width="1122" height="687" alt="Screenshot (19)" src="https://github.com/user-attachments/assets/5785d714-5e6e-4cc2-b003-650e6ff4750c" />

## Directory Structure

```
.
├── rtl/          # Verilog source files for CPU and components
├── testbench/    # Simulation files and testcases
├── docs/         # Design documentation (pipeline diagrams, timing analysis, etc.)
├── assembly-tests/ # Sample test assembly codes
├── README.md     # Project overview and instructions
├── LICENSE       # Project license
```

## Getting Started

### Prerequisites

- [Verilog/SystemVerilog](https://www.verilog.com/) simulator (e.g., Icarus Verilog, ModelSim, or Vivado)
- RISC-V toolchain for generating machine code

### Running Simulations

1. Clone the repository:
    ```bash
    git clone https://github.com/vlsienthusiast00x/rv32im-pipelined-cpu.git
    cd rv32im-pipelined-cpu
    ```
2. Compile the source code
    ```bash
    cd rtl
    make all
    ```
3. Run the simulation and inspect the waveform/logs for correct behavior.
   ```bash
   vvp rv32im.vvp
   ```
4. Change the code in `instr.S` file for testing different operations
    ### `Click` **[Here](https://github.com/vlsienthusiast00x/rv32im-pipelined-cpu/tree/main/assembly-tests)** `for some sample test assembly codes`
### File Overview

- **rtl/**: Contains the main CPU pipeline design, ALU, register file, control logic, and memory interface.
- **testbench/**: Provides simulation scaffolding for testing instruction execution and pipeline behavior.
- **docs/**: Includes architecture diagrams, pipeline stage explanations, and performance analysis.
- **assembly-tests/**: Provides some sample ready-to-compile assembly codes, that completely proves each instruction of this CPU.

## Documentation

See the [docs](./docs/) folder for:

- Pipeline architecture overview
- Hazard detection and forwarding logic
- Example instruction flows
- RISC-V GNU toolchain installation

## Contributing

Feel free to open issues, suggest improvements, or submit pull requests for bug fixes and enhancements.

## License

This project is licensed under the MIT License.

## Author

Created by [vlsienthusiast00x](https://github.com/vlsienthusiast00x)
