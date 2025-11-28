# simple-MIPS

A simple MIPS processor implementation in Verilog with both single-cycle and pipelined versions.

## Versions

- **`src/Top.v` (mips_cpu):** Single-cycle MIPS CPU — one instruction completes per clock cycle
- **`src/mips_pipeline.v` (mips_cpu_pipeline):** 5-stage pipelined MIPS CPU with forwarding and load-use stall detection

## Quick Start

### Prerequisites

Install Icarus Verilog:
```bash
# Ubuntu/Debian
sudo apt install iverilog

# macOS
brew install icarus-verilog
```

### Run Tests

```bash
bash run_tests.sh
```

Or manually:
```bash
# Single-cycle
iverilog -g2012 -o sim_top.vvp src/*.v src/tb_Top.v
vvp sim_top.vvp

# Pipelined
iverilog -g2012 -o sim_pipeline.vvp src/*.v src/tb_pipeline.v
vvp sim_pipeline.vvp
```

## Architecture

### Single-Cycle (Top.v)

A straightforward single-cycle datapath:
- **Fetch:** Instruction memory lookup
- **Decode:** Control unit + register file read
- **Execute:** ALU operation
- **Memory:** Load/Store
- **Write-back:** Register update

All in one clock cycle. Supports: ADD, SUB, AND, OR, NOR, XOR, SLL, SRL, SRA, ADDI, ANDI, ORI, XORI, LW, SW, J

### Pipelined (mips_pipeline.v)

5-stage pipeline for better throughput:
- **IF:** Instruction Fetch
- **ID:** Instruction Decode + Register Read
- **EX:** Execute (with forwarding)
- **MEM:** Memory Access
- **WB:** Write Back

Features:
- **Forwarding unit:** Reduces stalls from data hazards
- **Hazard detection:** Detects load-use hazards and inserts stalls
- **Jump handling:** Resolved in ID stage

See `PIPELINE.md` for detailed design documentation.

## Supported Instructions

| Type | Instructions |
|------|--------------|
| Arithmetic | ADD, ADDI, SUB |
| Logical | AND, ANDI, OR, ORI, XOR, XORI, NOR |
| Shift | SLL, SRL, SRA |
| Memory | LW, SW |
| Control | J (Jump) |

*Note: Branches (BEQ, BNE, etc.) are not yet implemented; jump only.*

## File Structure

```
src/
├── Top.v                   # Single-cycle CPU (main datapath)
├── mips_pipeline.v         # 5-stage pipelined CPU
├── tb_Top.v                # Testbench for single-cycle
├── tb_pipeline.v           # Testbench for pipelined
├── ControlUnit.v           # Instruction decoder & control signals
├── RegisterFile.v          # 32 x 32-bit register file
├── ALU.v                   # 32-bit ALU
├── InstructionMemory.v     # ROM with test program
├── Memory.v                # Data memory (RAM)
├── ProgramCounter.v        # PC register with reset
├── SignExtender.v          # 16→32 bit sign extension
├── 2by1MUX.v               # 2-to-1 multiplexer
├── 2bitLeftShifter.v       # Left shift by 2 (unused in current design)
└── genericAdder.v          # 32-bit adder
PIPELINE.md                 # Detailed pipeline documentation
run_tests.sh                # Script to run both testbenches
```

## Testing

Both testbenches check:
- Register values after execution
- Memory contents
- Jump/branch behavior (if enabled)

Expected results from the demo program:
```
$t0 = 7,  $t1 = 3,  $t2 = 10,  $t3 = 4
$t4 = 3,  $t5 = 7,  $t6 = 4,   $t7 = 12
$s0 = 10, $s1 = 0,  $s2 = 42   (jumped to)
memory[0] = 10
```

## Waveform Viewing

Generate VCD (waveform) files during simulation (testbenches already have `$dumpvars`):
```bash
gtkwave cpu.vcd           # Single-cycle waveform
gtkwave cpu_pipeline.vcd  # Pipelined waveform
```

## Future Work

- [ ] Implement branch instructions (BEQ, BNE, BLEZ, BGTZ)
- [ ] Add branch prediction
- [ ] Convert asynchronous memory to synchronous (better synthesis)
- [ ] Implement caches (I-cache, D-cache)
- [ ] Add exception/interrupt handling
- [ ] Optimize forwarding for all hazard cases
- [ ] Create an assembler for easier programming

## References

- MIPS Instruction Set (R2000/R3000)
- Patterson & Hennessy, "Computer Organization and Design"
