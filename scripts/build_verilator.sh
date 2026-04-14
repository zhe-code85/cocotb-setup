#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERILATOR_SRC_DIR="${VERILATOR_SRC_DIR:-${ROOT_DIR}/third_party/verilator}"
VERILATOR_PREFIX="${VERILATOR_PREFIX:-${ROOT_DIR}/local/verilator}"
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

mkdir -p "${VERILATOR_PREFIX}"

pushd "${VERILATOR_SRC_DIR}" >/dev/null

if [[ -f "autogen.sh" ]]; then
  ./autogen.sh
elif [[ ! -f "configure" ]]; then
  autoconf
fi

./configure --prefix="${VERILATOR_PREFIX}"
if command -v help2man >/dev/null 2>&1; then
  make -j"${JOBS}"
  make install
else
  echo "warning: help2man not found; installing Verilator without man pages"
  make -j"${JOBS}" verilator_exe
  make installbin installredirect installdata
fi

popd >/dev/null

echo "Verilator installed to ${VERILATOR_PREFIX}"
echo "binary: ${VERILATOR_PREFIX}/bin/verilator"
