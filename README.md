# cocotb-setup

Offline-friendly Verilator + cocotb setup. Three-step workflow:

1. **Prepare** (online) — download source and dependencies
2. **Install** (offline) — build and install on the target machine
3. **Verify** — self-test the installed toolchain

## Layout

```text
cocotb-setup/
├── local/                  # Verilator install prefix (created by scripts)
├── scripts/                # setup and environment scripts
├── third_party/            # vendored source trees
│   ├── cocotb/             # cocotb source (git submodule, v2.0.1)
│   └── verilator/          # Verilator source (git submodule, v5.046)
├── wheelhouse/             # pre-downloaded Python wheels (created by step 1)
└── examples/               # cocotb test examples
```

## System Requirements

The offline target machine needs:

- **OS**: Linux
- **Python**: >= 3.8, with **shared library** (`libpython*.so`) — cocotb needs this for VPI to work
  - Debian/Ubuntu: `apt install python3-dev` (provides `libpython3.x.so`)
  - RHEL/CentOS: `yum install python3-devel`
- **Build tools**: `g++`, `make`, `autoconf`, `bison`, `flex`, `perl`

## Step 1 — Prepare (online machine)

Download source code and Python dependencies:

```bash
cd /path/to/cocotb-setup
./scripts/prepare_offline.sh
```

This will:
- Initialize git submodules (verilator v5.046, cocotb v2.0.1)
- Download Python wheels to `wheelhouse/` (pip, setuptools, wheel, find_libpython)

## Step 2 — Package & Install (offline machine)

Package the entire project directory and transfer to the offline target:

```bash
tar czf cocotb-setup.tar.gz /path/to/cocotb-setup
# transfer cocotb-setup.tar.gz to the offline machine
```

On the offline target machine:

```bash
tar xzf cocotb-setup.tar.gz
cd cocotb-setup
./scripts/install_offline.sh
```

This will:
- Check system build tools (g++, make, autoconf, bison, flex, perl)
- Check Python >= 3.8 and shared library (`libpython*.so`)
- Create a virtual environment at `.venv`
- Build and install Verilator from source to `local/verilator`
- Install cocotb from local source using local wheels (fully offline)

## Step 3 — Verify

```bash
source .venv/bin/activate
source scripts/env.sh
./scripts/verify_install.sh
```

This will:
- Check `verilator --version`
- Check `python -c "import cocotb"`
- Check `python -c "import find_libpython"`
- Run the tiny_counter Verilator simulation

## Quick Start (online, all steps)

```bash
cd /path/to/cocotb-setup

./scripts/prepare_offline.sh
./scripts/install_offline.sh
source .venv/bin/activate
source scripts/env.sh
./scripts/verify_install.sh
```

## Configuration

All defaults can be overridden via environment variables:

| Variable | Default | Purpose |
|---|---|---|
| `VENV_DIR` | `./.venv` | Virtual environment path |
| `VERILATOR_PREFIX` | `./local/verilator` | Verilator install prefix |
| `WHEELHOUSE_DIR` | `./wheelhouse` | Pre-downloaded Python wheels |
| `PYTHON_BIN` | `python3` | Python interpreter |
| `VERILATOR_TAG` | `v5.046` | Verilator git tag (step 1) |
| `COCOTB_TAG` | `v2.0.1` | cocotb git tag (step 1) |
| `JOBS` | `$(nproc)` | Parallel build jobs |

## Vendored Versions

- Verilator: `v5.046`
- cocotb: `v2.0.1`
