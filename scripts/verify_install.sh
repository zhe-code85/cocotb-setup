#!/usr/bin/env bash
# verify_install.sh — Step 3: verify the installed toolchain
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERILATOR_PREFIX="${VERILATOR_PREFIX:-${ROOT_DIR}/local/verilator}"

pass=0
fail=0

check() {
  local desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "  [PASS] ${desc}"
    pass=$((pass + 1))
  else
    echo "  [FAIL] ${desc}"
    fail=$((fail + 1))
  fi
}

echo "=== Step 3: Verifying installation ==="
echo ""

# --- 1. Check verilator binary ---
echo "--- Verilator ---"
verilator_bin="${VERILATOR_PREFIX}/bin/verilator"
if [[ -x "${verilator_bin}" ]]; then
  echo "  [PASS] verilator binary: ${verilator_bin}"
  echo "         $(${verilator_bin} --version)"
  pass=$((pass + 1))
else
  echo "  [FAIL] verilator binary not found: ${verilator_bin}"
  fail=$((fail + 1))
fi
echo ""

# --- 2. Check Python / cocotb ---
echo "--- Python & cocotb ---"

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
  echo "  [WARN] no virtual environment active; activate it first for accurate results"
fi

if command -v python >/dev/null 2>&1; then
  check "python executable" python -c "pass"

  # cocotb import
  if python -c "import cocotb" 2>/dev/null; then
    cocotb_ver="$(python -c "import cocotb; print(cocotb.__version__)" 2>/dev/null || echo "unknown")"
    echo "  [PASS] import cocotb (version: ${cocotb_ver})"
    pass=$((pass + 1))
  else
    echo "  [FAIL] import cocotb"
    fail=$((fail + 1))
  fi

  # find_libpython
  check "import find_libpython" python -c "import find_libpython"
else
  echo "  [FAIL] python not found in PATH"
  fail=$((fail + 1))
fi
echo ""

# --- 3. Run tiny_counter example ---
echo "--- Tiny counter example (Verilator) ---"
if [[ -x "${verilator_bin}" ]] && command -v python >/dev/null 2>&1; then
  export PATH="${VERILATOR_PREFIX}/bin:${PATH}"
  if command -v python >/dev/null 2>&1; then
    libpython="$(python - <<'PY'
import sysconfig
from pathlib import Path
libdir = sysconfig.get_config_var("LIBDIR")
ldlibrary = sysconfig.get_config_var("LDLIBRARY")
if libdir and ldlibrary:
    print(Path(libdir) / ldlibrary)
PY
    )"
    if [[ -n "${libpython}" ]]; then
      export LIBPYTHON_LOC="${libpython}"
    fi
  fi

  if "${ROOT_DIR}/examples/tiny_counter/run_verilator.sh" 2>&1; then
    echo "  [PASS] tiny_counter simulation"
    pass=$((pass + 1))
  else
    echo "  [FAIL] tiny_counter simulation"
    fail=$((fail + 1))
  fi
else
  echo "  [SKIP] verilator or python not available"
fi
echo ""

# --- Summary ---
echo "=== Summary ==="
total=$((pass + fail))
echo "  Passed: ${pass}/${total}"
if [[ ${fail} -gt 0 ]]; then
  echo "  Failed: ${fail}/${total}"
  exit 1
else
  echo "  All checks passed."
fi
