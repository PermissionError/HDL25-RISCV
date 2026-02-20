# RISC-V - PYNQ Integration Project

## File structure

| Path | Description |
|------|-------------|
| `hdl_group_project.xpr` | Vivado project file (open this in Vivado). |
| `custom_ip/` | Custom RISC-V IP: `rv-pl.v` (core), `xgui/` (IP config UI), `component.xml`. |
| `hdl_group_project.srcs/` | Project sources (RTL, constraints, block design sources). |
| `hdl_group_project.gen/` | Generated block design and IP (e.g. `ip_integrator` BD and wrapper). |
| `hdl_group_project.runs/` | Build outputs: `synth_1` (synthesis), `impl_1` (implementation/bitstream). |
| `hdl_group_project.cache/` | Vivado cache (IP, compile_simlib, webtalk). |
| `hdl_group_project.sim/` | Simulation project and run data. |
| `hdl_group_project.hw/` | Hardware export/checkpoint outputs. |
| `checkpoints/` | Design checkpoints (e.g. `checkpoint_pipelined.dcp`) for incremental flow. |
| `tb-rv-pl.v` | Testbench for the RISC-V custom IP. |
| `test-program.asm`, `test-program.hex` | Test program used for verification. |
| `verify.ipynb` | Jupyter notebook for verification on PYNQ. |
| `ip_integrator.bit`, `ip_integrator.hwh` | Bitstream and hardware handoff for deployment. |
