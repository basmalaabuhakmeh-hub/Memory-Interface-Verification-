# Memory Interface Verification

This project implements and verifies a synchronous memory design using SystemVerilog. The memory is connected to the testbench through an interface that includes a clocking block and a checker to prevent read and write from being active in the same transaction.

## Project Structure

```text
DV_HW4/
├── design/
│   ├── mem_if.sv
│   └── my_mem.sv
├── verif/
│   ├── mem_pkg.sv
│   ├── test_prog.sv
│   └── top.sv
└── flist.f
