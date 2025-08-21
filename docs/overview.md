# Pipeline Architecture

The CPU consists of the following stages, encapsulated in a modular Verilog (core.v) unit with dedicated pipeline registers:

### 1. Instruction Fetch (IF)
- Fetches instruction from instruction memory using the current Program Counter (PC)
- Handles PC updates for sequential execution and branch/jump targets
- Outputs instruction and updated PC to the next stage

### 2. Instruction Decode (ID)
- Decodes instruction fields (opcode, funct3, funct7, rs1, rs2, rd)
- Reads source operands from the register file
- Generates control signals for execution, memory access, and write-back
- Prepares immediate values and passes control/data to EX stage

### 3. Execute (EX)
- Performs ALU operations (arithmetic, logical, comparisons)
- Computes branch/jump targets and evaluates branch conditions
- Handles multiplication/division for RV32M instructions
- Outputs ALU result, branch decision, and memory address to MEM stage

### 4. Memory Access (MEM)
- Performs load/store operations with data memory
- Applies byte/halfword/word alignment and sign-extension as needed
- Forwards ALU result or loaded data to WB stage

### 5. Write Back (WB)
- Writes result back to the destination register (`rd`)
- Selects between ALU result and memory data based on instruction type
- Ensures correct register file update and architectural state consistency

## Supported Instructions

- **RV32I Base**: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `LW`, `SW`, `BEQ`, `BNE`, `JAL`, `JALR`, etc.
- **RV32M Extension**: `MUL`, `DIV`, `REM`, and variants

## Key Features

- Modular stage-wise design with clean interfaces
- Branch and jump logic with flush and control hazard mitigation
- Minimal test programs for instruction-level and hazard-level validation
- Waveform-level verification of architectural invariants
- Designed for extensibility and future architectural enhancements

## Validation Strategy

- **Waveform Inspection**: Register file updates, PC alignment, memory access correctness
- **Minimal Assembly Tests**: Fibonacci sequence, memory stress tests, control flow probes
- **Regression Suite**: Covers arithmetic, memory, and control instructions under pipeline conditions

## Integration Notes

- Designed to be integrated into a larger SoC or simulation environment
- Compatible with standard Verilog simulation tools
- Interfaces exposed for instruction memory, data memory, and external control
