# Supported Instructions — RV32IM Pipelined CPU Core

This document outlines the instruction set implemented and validated in the RV32IM pipelined CPU core. The design supports the full RV32I base instruction set along with the RV32M extension for integer multiplication and division.

## RV32I Base Instruction Set

### Arithmetic & Logical Instructions
| Mnemonic | Description                     | Format  |
|----------|----------------------------------|---------|
| ADD      | Add                             | R-type  |
| SUB      | Subtract                        | R-type  |
| AND      | Bitwise AND                     | R-type  |
| OR       | Bitwise OR                      | R-type  |
| XOR      | Bitwise XOR                     | R-type  |
| SLL      | Shift Left Logical              | R-type  |
| SRL      | Shift Right Logical             | R-type  |
| SRA      | Shift Right Arithmetic          | R-type  |
| SLT      | Set Less Than                   | R-type  |
| SLTU     | Set Less Than Unsigned          | R-type  |

### Immediate Instructions
| Mnemonic | Description                     | Format  |
|----------|----------------------------------|---------|
| ADDI     | Add Immediate                   | I-type  |
| ANDI     | AND Immediate                   | I-type  |
| ORI      | OR Immediate                    | I-type  |
| XORI     | XOR Immediate                   | I-type  |
| SLLI     | Shift Left Logical Immediate    | I-type  |
| SRLI     | Shift Right Logical Immediate   | I-type  |
| SRAI     | Shift Right Arithmetic Immediate| I-type  |
| SLTI     | Set Less Than Immediate         | I-type  |
| SLTIU    | Set Less Than Unsigned Immediate| I-type  |

### Load Instructions
| Mnemonic | Description                     | Format  |
|----------|----------------------------------|---------|
| LW       | Load Word                       | I-type  |


### Store Instructions
| Mnemonic | Description                     | Format  |
|----------|----------------------------------|---------|
| SW       | Store Word                      | S-type  |

### Control Flow Instructions
| Mnemonic | Description                     | Format  |
|----------|----------------------------------|---------|
| BEQ      | Branch if Equal                 | B-type  |
| BNE      | Branch if Not Equal             | B-type  |
| BLT      | Branch if Less Than             | B-type  |
| BGE      | Branch if Greater or Equal      | B-type  |
| BLTU     | Branch if Less Than Unsigned    | B-type  |
| BGEU     | Branch if Greater or Equal Unsigned | B-type |
| JAL      | Jump and Link                   | J-type  |
| JALR     | Jump and Link Register          | I-type  |


## RV32M Extension (Multiplication & Division)

| Mnemonic | Description                     | Format  |
|----------|----------------------------------|---------|
| MUL      | Multiply                        | R-type  |
| DIV      | Divide Signed                   | R-type  |
| DIVU     | Divide Unsigned                 | R-type  |
| REM      | Remainder Signed                | R-type  |
| REMU     | Remainder Unsigned              | R-type  |

## Validation Status

All instructions listed above have been:
- Simulated using minimal assembly programs
- Verified via waveform inspection
- Included in regression suites for control/data hazard scenarios

## Notes

- Instructions are decoded and executed with full pipeline support, including flush and hazard mitigation.
- Memory alignment and sign-extension are handled per RISC-V specification.
- Future extensions may include CSR instructions, floating-point operations, and interrupt handling.

---

For waveform traces, test programs, and validation artifacts, refer to the `docs/` and `test/` directories in the repository.
