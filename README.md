# shift_register_8bit

A SystemVerilog serial-in, serial-out shift register with eight internal bits and a registered serial output. A beginner hardware project exploring vectors, clocked logic, and simulation with Icarus Verilog.

## How It Works

```text
serial_in -> stages[0] -> stages[1] -> ... -> stages[7] -> data_out
```

**There are nine storage stages total:** eight in `stages[7:0]` plus the one-bit `data_out` register. A bit captured into `stages[0]` on the first enabled rising edge reaches `data_out` on the ninth enabled rising edge (eight further enabled edges).

- `rst`: synchronous, active-high reset. Clears all stages on a rising clock edge and takes priority over `en`.
- `en`: when high, shifts one bit on each rising edge. When low, both the internal stages and output hold their values.
- `serial_in`: one input bit, sampled only on enabled rising edges outside reset.
- `data_out`: one registered output bit, not a parallel byte output.

Nonblocking assignments (`<=`) mean that `data_out` receives the old value of `stages[7]` as the internal vector shifts. Apply reset before relying on the stored values.

## Files

```text
shift_register.sv       Design
shift_register_tb.sv    Self-checking testbench
```

## Run the Simulation

With Icarus Verilog installed, run these commands from the repository root:

```bash
mkdir -p build
iverilog -g2012 -s shift_register_tb -o build/shift_sim shift_register.sv shift_register_tb.sv
vvp build/shift_sim
```

Expected result:

```text
PASS: reset, nine-stage timing, bit order, enable hold, and recovery
```

The simulation creates `shift_register.vcd` for waveform viewing. Simulation outputs are excluded from Git by `.gitignore`.

## Verification

The testbench checks:

- A single bit reaches the output on the ninth enabled edge.
- Disabling shifts preserves internal data and the output.
- The serial pattern `10100110` emerges in the same order it entered.
- Reset is synchronous and takes priority over enable.
- Reset clears the full pipeline, and shifting resumes afterward.

Inputs change on falling clock edges; checks run 1 ns after rising edges so nonblocking updates have completed. Unknown outputs fail the checks.

## Learning Notes

The design evolved from individually named one-bit registers into an eight-bit vector. The additional registered output is intentional in this version and is included in the timing checks.

I developed the RTL while learning SystemVerilog with OpenAI Codex. Codex assisted with explanations, the testbench, and documentation.
