#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
  echo "error: no virtual environment is active"
  echo "hint: activate your chosen virtual environment before running this script"
  exit 1
fi

if ! command -v python >/dev/null 2>&1; then
  echo "error: python not found in the active virtual environment"
  exit 1
fi

echo "using python: $(command -v python)"
python -V

python -m ensurepip --upgrade
python -m pip install --upgrade pip setuptools wheel

PYTHON_BIN=python "${ROOT_DIR}/scripts/check_python.sh"
"${ROOT_DIR}/scripts/build_verilator.sh"
PYTHON_BIN="$(command -v python)" "${ROOT_DIR}/scripts/install_cocotb.sh"

echo
echo "toolchain installation complete"
echo "next step:"
echo "  source scripts/env.sh"
echo "  ./examples/tiny_counter/run_verilator.sh"
