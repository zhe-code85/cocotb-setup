#!/usr/bin/env bash
# install_offline.sh — Step 2: install toolchain on offline target machine
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${VENV_DIR:-${ROOT_DIR}/.venv}"
VERILATOR_PREFIX="${VERILATOR_PREFIX:-${ROOT_DIR}/local/verilator}"
WHEELHOUSE_DIR="${WHEELHOUSE_DIR:-${ROOT_DIR}/wheelhouse}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
JOBS="${JOBS:-$(nproc)}"

echo "=== Step 2: Offline installation ==="
echo ""

# --- 1. Check system build tools ---
echo "--- Checking system build tools ---"
missing_tools=()
for tool in g++ make autoconf bison flex perl; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    missing_tools+=("${tool}")
  fi
done

if [[ ${#missing_tools[@]} -gt 0 ]]; then
  echo "error: missing required build tools: ${missing_tools[*]}"
  echo "hint: install them with your system package manager, e.g.:"
  echo "  apt install ${missing_tools[*]}"
  exit 1
fi
echo "All build tools present."
echo ""

# --- 2. Check Python ---
echo "--- Checking Python ---"
if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  echo "error: ${PYTHON_BIN} not found"
  exit 1
fi

"${PYTHON_BIN}" - <<'PY'
import sys
import sysconfig
if sys.version_info < (3, 8):
    raise SystemExit(f"error: Python {sys.version_info[:3]} is too old; need >= 3.8")
print(f"Python {sys.version_info[:3]} OK")
# Check for shared library (required by cocotb VPI)
ldlibrary = sysconfig.get_config_var("LDLIBRARY") or ""
libdir = sysconfig.get_config_var("LIBDIR") or ""
if not ldlibrary.endswith(".so"):
    print(f"warning: Python shared library not found (LDLIBRARY={ldlibrary})")
    print("  cocotb VPI requires libpython*.so")
    print("  install: apt install python3-dev  or  yum install python3-devel")
PY
echo ""

# --- 3. Create virtual environment ---
echo "--- Creating virtual environment at ${VENV_DIR} ---"
"${PYTHON_BIN}" -m venv "${VENV_DIR}"

VENV_PYTHON="${VENV_DIR}/bin/python"

"${VENV_PYTHON}" -m ensurepip --upgrade --default-pip

# Upgrade pip/setuptools/wheel from wheelhouse (offline)
if [[ -d "${WHEELHOUSE_DIR}" ]] && find "${WHEELHOUSE_DIR}" -name '*.whl' -print -quit | grep -q .; then
  echo "Installing pip/setuptools/wheel from local wheelhouse (offline)"
  "${VENV_PYTHON}" -m pip install --no-index --find-links "${WHEELHOUSE_DIR}" \
    pip setuptools wheel
else
  echo "warning: no wheels found in ${WHEELHOUSE_DIR}, using bundled versions"
fi
echo ""

# --- 4. Activate venv for subsequent commands ---
# (activate in this shell so subscripts see VIRTUAL_ENV)
# shellcheck disable=SC1090
source "${VENV_DIR}/bin/activate"
echo "Virtual environment activated: ${VIRTUAL_ENV}"
echo ""

# --- 5. Build Verilator ---
echo "--- Building Verilator ---"
export VERILATOR_PREFIX
export JOBS
"${ROOT_DIR}/scripts/build_verilator.sh"
echo ""

# --- 6. Install cocotb ---
echo "--- Installing cocotb ---"
export PYTHON_BIN="$(command -v python)"
export WHEELHOUSE_DIR
export COCOTB_SRC_DIR="${ROOT_DIR}/third_party/cocotb"
"${ROOT_DIR}/scripts/install_cocotb.sh"
echo ""

# --- 7. Done ---
echo "=== Installation complete ==="
echo ""
echo "  Verilator : ${VERILATOR_PREFIX}/bin/verilator"
echo "  cocotb    : installed in ${VIRTUAL_ENV}"
echo "  venv      : ${VENV_DIR}"
echo ""
echo "Next steps:"
echo "  source scripts/env.sh"
echo "  ./scripts/verify_install.sh"
