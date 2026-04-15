#!/usr/bin/env bash
# prepare_offline.sh — Step 1: download source and dependencies (requires network)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WHEELHOUSE_DIR="${WHEELHOUSE_DIR:-${ROOT_DIR}/wheelhouse}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

echo "=== Step 1: Preparing offline installation package ==="
echo ""

# --- 1. Initialize and sync third-party source trees ---
echo "--- Initializing submodules ---"
git -C "${ROOT_DIR}" submodule update --init --recursive
echo ""

echo "--- Syncing source trees to pinned versions ---"
"${ROOT_DIR}/scripts/sync_third_party.sh"
echo ""

# --- 2. Download Python wheels ---
echo "--- Downloading Python wheels to ${WHEELHOUSE_DIR} ---"

if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  echo "error: ${PYTHON_BIN} not found"
  exit 1
fi

mkdir -p "${WHEELHOUSE_DIR}"

# cocotb build dependencies + runtime dependencies
#   build: setuptools, wheel (from pyproject.toml [build-system])
#   runtime: find_libpython (only install_requires entry)
"${PYTHON_BIN}" -m pip download \
  --dest "${WHEELHOUSE_DIR}" \
  --only-binary=:all: \
  pip setuptools wheel find_libpython

echo ""
echo "=== Wheelhouse contents ==="
ls -1 "${WHEELHOUSE_DIR}"/*.whl 2>/dev/null || echo "(no wheels found)"
echo ""

echo "=== Preparation complete ==="
echo "Source trees: third_party/verilator, third_party/cocotb"
echo "Python wheels: ${WHEELHOUSE_DIR}/"
echo ""
echo "Next steps:"
echo "  1. Package the entire project directory (tar, zip, etc.)"
echo "  2. Transfer to the offline target machine"
echo "  3. Run: ./scripts/install_offline.sh"
