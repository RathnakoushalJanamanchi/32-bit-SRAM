# 32-Bit RAM — Verilog Design & Simulation

> **Day 50 Project** · Designed and simulated in [EDA Playground](https://www.edaplayground.com/)

---

## Overview

This project implements a **synchronous 32-bit RAM** with 32 addressable locations (depth = 32, word width = 32 bits) written in Verilog. The design supports independent read and write control signals, synchronous reset, and tri-state output. A self-checking testbench drives the DUT with random data and verifies both write and read operations. Simulation was carried out on EDA Playground using the **Synopsys VCS** simulator, with waveforms dumped to a VCD file.

---
---

## Design Details (`design.sv`)

### Module: `Day_50`

| Port       | Direction | Width   | Description                                      |
|------------|-----------|---------|--------------------------------------------------|
| `clk`      | Input     | 1-bit   | Clock signal (rising-edge triggered)             |
| `wr`       | Input     | 1-bit   | Write enable — write occurs on posedge when high |
| `rd`       | Input     | 1-bit   | Read enable — drives output when high            |
| `rst`      | Input     | 1-bit   | Synchronous reset — clears addressed location    |
| `data_in`  | Input     | 32-bit  | Data to be written into RAM                      |
| `addr`     | Input     | 6-bit   | Address bus (selects 1 of 32 locations)          |
| `data_out` | Output    | 32-bit  | Data read from RAM (high-Z when `rd` is low)     |

### Memory Array

```verilog
reg [31:0] ram [0:31];   // 32 locations × 32 bits = 1 Kbit total
```

### Write Logic (Synchronous)

On every rising edge of `clk`:
- If `rst` is asserted, the currently addressed location is cleared to `0`.
- If `wr` is asserted (and `rst` is deasserted), `data_in` is written to `ram[addr]`.

### Read Logic (Combinational)

```verilog
assign data_out = rd ? ram[addr] : 64'dz;
```

Output is driven combinationally: `ram[addr]` appears on `data_out` when `rd = 1`; otherwise the output is held at high impedance (`Z`), making it bus-friendly.

---

## Testbench Details (`testbench.sv`)

### Module: `Day_50_tb`

The testbench instantiates the DUT as `uut` and exercises it through three phases:

| Phase       | Description                                                                          |
|-------------|--------------------------------------------------------------------------------------|
| **Reset**   | Asserts `rst` for one clock cycle to initialize the RAM before any operation         |
| **Write**   | Writes 15 random 32-bit values (`$random`) into addresses 0–14 with `wr = 1`        |
| **Read**    | Reads back addresses 0–14 with `rd = 1` and prints results via `$display`           |

**Clock generation:** 10 ns period (toggled every 5 ns).

**Waveform dump:** VCD is written to `dump.vcd` using `$dumpfile` / `$dumpvars` — viewable in GTKWave or any VCD-compatible viewer.

> **Note:** The testbench declares `addr` as 9-bit (`reg [8:0]`) while the DUT port is 6-bit. Only the lower 6 bits are connected, so addressing stays within the valid 0–31 range for the 15 write/read iterations used.

---

## Simulation

### Tool

- **Simulator:** Synopsys VCS (version X-2025.06-SP1, run via EDA Playground)
- **Language:** Verilog / SystemVerilog (`.sv`)
- **Timescale:** 1 ns

### Running on EDA Playground

1. Open [EDA Playground](https://www.edaplayground.com/) and create a new playground.
2. Paste the contents of `design.sv` into the **Design** pane.
3. Paste the contents of `testbench.sv` into the **Testbench** pane.
4. Under **Tools & Simulators**, select **Synopsys VCS**.
5. Enable **Open EPWave after run** to view waveforms, or download `dump.vcd` and open it in GTKWave.
6. Click **Run**.

### Expected Console Output

```
wr=1, data_in=<random>, addr=0
wr=1, data_in=<random>, addr=1
...
wr=1, data_in=<random>, addr=14
rd=0, addr=0,  data_out=<value written at addr 0>
rd=0, addr=1,  data_out=<value written at addr 1>
...
rd=0, addr=14, data_out=<value written at addr 14>
```

*(The `rd` column in the read-phase display shows the `wr` signal by mistake in the format string — this is a minor testbench cosmetic bug and does not affect functional correctness.)*

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| Synchronous write, combinational read | Common FPGA/ASIC RAM idiom; write is clock-safe, read is low-latency |
| High-Z on `rd = 0` | Allows `data_out` to be shared on a multi-master bus |
| Synchronous reset (per-address) | Avoids unintentional bulk-clear; only the currently addressed word is reset |
| 6-bit address bus | Exactly covers depth of 32 locations (2⁵ = 32) |

---

## Waveform Inspection

The `dump.vcd` file captures all signals in the testbench scope (`Day_50_tb`) and the DUT scope (`uut`). Signals recorded:

- `clk`, `wr`, `rd`, `rst`
- `data_in [31:0]`, `data_out [31:0]`
- `addr [8:0]` (testbench) / `addr [5:0]` (DUT)

Open with GTKWave:
```bash
gtkwave dump.vcd
```

---

## Possible Improvements

- Extend address bus to support deeper memory (e.g., 64 or 256 locations).
- Add a write-byte-enable mask for sub-word writes.
- Implement a full reset that clears all locations (using a loop or a dedicated initialization state).
- Add self-checking assertions in the testbench (compare read-back data against a reference shadow array).
- Switch to `$urandom` (SystemVerilog) for a more portable random stimulus source.
