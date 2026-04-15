#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERILATOR_SRC_DIR="${VERILATOR_SRC_DIR:-${ROOT_DIR}/third_party/verilator}"
VERILATOR_PREFIX="${VERILATOR_PREFIX:-${ROOT_DIR}/local/verilator}"
VERILATOR_BUILD_DIR="${VERILATOR_BUILD_DIR:-${ROOT_DIR}/build/verilator}"
JOBS="${JOBS:-$(nproc)}"
REQUIRED_TOOLS=(autoconf bison flex g++ make perl)

if [[ ! -d "${VERILATOR_SRC_DIR}" ]]; then
  echo "error: Verilator source tree not found: ${VERILATOR_SRC_DIR}"
  exit 1
fi

if [[ ! -f "${VERILATOR_SRC_DIR}/configure.ac" ]] && [[ ! -f "${VERILATOR_SRC_DIR}/configure" ]]; then
  echo "error: ${VERILATOR_SRC_DIR} does not look like a Verilator source tree"
  exit 1
fi

for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "error: required build tool not found: ${tool}"
    exit 1
  fi
done

# Generate configure script in source tree (does not produce .o files)
if [[ -f "${VERILATOR_SRC_DIR}/autogen.sh" ]]; then
  pushd "${VERILATOR_SRC_DIR}" >/dev/null
  ./autogen.sh
  popd >/dev/null
elif [[ ! -f "${VERILATOR_SRC_DIR}/configure" ]]; then
  pushd "${VERILATOR_SRC_DIR}" >/dev/null
  autoconf
  popd >/dev/null
fi

# Build in a separate directory to keep source tree clean
mkdir -p "${VERILATOR_BUILD_DIR}"

pushd "${VERILATOR_BUILD_DIR}" >/dev/null

"${VERILATOR_SRC_DIR}/configure" --prefix="${VERILATOR_PREFIX}"
make -j"${JOBS}"
# Out-of-source build breaks man page install paths; install components separately
make installbin installredirect installdata
echo "note: man pages skipped (out-of-source build)"

popd >/dev/null

echo "Verilator installed to ${VERILATOR_PREFIX}"
echo "binary: ${VERILATOR_PREFIX}/bin/verilator"
