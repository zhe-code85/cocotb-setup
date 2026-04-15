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

WHEELHOUSE_DIR="${WHEELHOUSE_DIR:-${ROOT_DIR}/wheelhouse}"

python -m ensurepip --upgrade --default-pip

# Upgrade pip/setuptools/wheel: use wheelhouse if available, otherwise network
if [[ -d "${WHEELHOUSE_DIR}" ]] && find "${WHEELHOUSE_DIR}" -name '*.whl' -print -quit | grep -q .; then
  echo "installing pip/setuptools/wheel from local wheelhouse (offline)"
  python -m pip install --no-index --find-links "${WHEELHOUSE_DIR}" \
    pip setuptools wheel
else
  python -m pip install --upgrade pip setuptools wheel
fi

PYTHON_BIN=python "${ROOT_DIR}/scripts/check_python.sh"
"${ROOT_DIR}/scripts/build_verilator.sh"
PYTHON_BIN="$(command -v python)" "${ROOT_DIR}/scripts/install_cocotb.sh"

echo
echo "toolchain installation complete"
echo "next step:"
echo "  source scripts/env.sh"
echo "  ./examples/tiny_counter/run_verilator.sh"
