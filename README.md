# cocotb-setup

This repository is for building an offline-friendly Verilator + cocotb setup
that can be carried to target Linux systems with unknown Python versions.

## Goals

- vendor Verilator and cocotb source trees into one repository
- build Verilator locally from source on the target machine
- install cocotb from local source into a target-specific virtual environment
- avoid depending on internet access during target-machine setup
- keep installation under the repository root by default

## Layout

```text
cocotb-setup/
├── local/                  # install prefix created by scripts
├── scripts/                # setup and environment scripts
├── third_party/            # vendored source trees live here
│   ├── cocotb/
│   └── verilator/
└── wheelhouse/             # optional offline Python wheels
```

## Recommended Source Layout

This repository currently vendors the upstream projects as git submodules:

- `third_party/verilator` at `v5.046`
- `third_party/cocotb` at `v2.0.1`

If someone clones this repository without `--recursive`, they should run:

```bash
git submodule update --init --recursive
```

To re-fetch and align both third-party repositories to the versions expected by
this repository, run:

```bash
./scripts/sync_third_party.sh
```

Submodules are convenient for development. For final offline delivery, fixed
source snapshots or archive exports may still be easier to carry into closed
environments.

## Supported Flow

1. Put Verilator source under `third_party/verilator`
2. Put cocotb source under `third_party/cocotb`
3. Run `scripts/sync_third_party.sh`
4. Create and activate a virtual environment yourself
5. Run `scripts/install_toolchain.sh`
6. Run `source scripts/env.sh`
7. Run one of the example simulators

## Defaults

- Default Python virtual environment path: `./.venv`
- Verilator install prefix: `./local/verilator`
- cocotb install target: current virtual environment

## Vendored Versions

- Verilator: `v5.046`
- cocotb: `v2.0.1`

## Notes

- `cocotb` still depends on the target machine's Python version and ABI.
- This repository does not assume a system-wide Python or Verilator install.
- Verilator + cocotb with Verilator typically requires a shared-library Python.

## Quick Start

```bash
cd /path/to/cocotb-setup

./scripts/create_venv.sh
source <your-venv>/bin/activate

./scripts/sync_third_party.sh
./scripts/install_toolchain.sh
source ./scripts/env.sh

./examples/tiny_counter/run_verilator.sh
```

## Activation Requirement

The installer does not activate a virtual environment for you.
Activate it yourself before running the installer:

```bash
source <your-venv>/bin/activate
./scripts/install_toolchain.sh
```

If you use the repository default, `<your-venv>` is `.venv`.

The scripts are written to be repository-relative and override-friendly:

- set `VENV_DIR` before `scripts/create_venv.sh` if you do not want `./.venv`
- set `VERILATOR_PREFIX` if you do not want `./local/verilator`
- set `VERILATOR_TAG` or `COCOTB_TAG` before `scripts/sync_third_party.sh` if you need different tags
- set `PYTHON_BIN`, `COCOTB_SRC_DIR`, `VERILATOR_SRC_DIR`, or `WHEELHOUSE_DIR` when needed

If `help2man` is missing on the host, the installer still builds and installs a
usable Verilator toolchain, but skips man page installation.

## Example Simulations

This repository includes one small Verilog example with two cocotb run paths:

- `examples/tiny_counter/run_verilator.sh`
- `examples/tiny_counter/run_vcs.sh`

`run_vcs.sh` assumes Synopsys VCS is already installed and licensed on the host.
This repository only installs Verilator and cocotb.

## Next Steps

- optionally add a `wheelhouse/` for fully offline Python dependency installs
- add smoke tests that validate `verilator --version` and `python -c 'import cocotb'`
- decide whether release artifacts should keep submodules or be exported as plain source snapshots
