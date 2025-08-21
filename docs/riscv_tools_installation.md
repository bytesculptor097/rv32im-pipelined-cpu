# Installing RISC-V GNU Toolchain for RV32IM Development

This guide outlines the steps to install the official RISC-V GNU toolchain, suitable for compiling and simulating RV32IM assembly programs. The toolchain includes `riscv32-unknown-elf-gcc`, `objdump`, `as`, and other utilities required for bare-metal development.

## Prerequisites

- Linux (Ubuntu recommended), macOS, or Windows with WSL
- Git
- Autoconf, automake, libtool, gawk, curl, python3, and build-essential

## Installation Steps

### 1. Clone the Toolchain Repository

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
```

### 2. Install Required Dependencies (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install autoconf automake libtool curl python3 gawk build-essential \
    bison flex texinfo libgmp-dev libmpfr-dev libmpc-dev libusb-1.0-0-dev \
    libexpat-dev
```

### 3. Build the Toolchain for RV32IM

```bash
./configure --prefix=$HOME/riscv --with-arch=rv32im --with-abi=ilp32
make
```

> This process may take 20–40 minutes depending on your system.

### 4. Add Toolchain to PATH

```bash
export PATH=$HOME/riscv/bin:$PATH
```

To make this permanent, add the above line to your `.bashrc` or `.zshrc`.

## Verifying Installation

Run the following command to confirm:

```bash
riscv32-unknown-elf-gcc -v
```

You should see version information for the RISC-V GCC compiler.

## Usage

- Compile assembly source:
  ```bash
  riscv32-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -o program.elf program.s
  ```
- View disassembly:
  ```bash
  riscv32-unknown-elf-objdump -d program.elf
  ```

## Notes

- This toolchain targets **bare-metal RV32IM** systems (no OS).
- For simulation, use with Verilog testbenches and memory loaders.
- For RV64 or Linux-targeted builds, use `--with-arch=rv64gc` and `--with-abi=lp64`.

---

For more details, refer to the [official RISC-V GNU Toolchain repository](https://github.com/riscv/riscv-gnu-toolchain).

