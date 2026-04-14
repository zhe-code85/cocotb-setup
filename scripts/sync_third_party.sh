#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VERILATOR_PATH="${VERILATOR_PATH:-${ROOT_DIR}/third_party/verilator}"
COCOTB_PATH="${COCOTB_PATH:-${ROOT_DIR}/third_party/cocotb}"

VERILATOR_TAG="${VERILATOR_TAG:-v5.046}"
COCOTB_TAG="${COCOTB_TAG:-v2.0.1}"

sync_repo() {
  local repo_path="$1"
  local repo_name="$2"
  local target_ref="$3"

  if ! git -C "${repo_path}" rev-parse --git-dir >/dev/null 2>&1; then
    echo "error: ${repo_name} repository not found at ${repo_path}"
    echo "hint: run 'git submodule update --init --recursive' first, or place the source tree there"
    exit 1
  fi

  echo "syncing ${repo_name} at ${repo_path}"
  git -C "${repo_path}" fetch --tags --force origin
  git -C "${repo_path}" checkout "${target_ref}"
  git -C "${repo_path}" submodule update --init --recursive
  echo "${repo_name} aligned to ${target_ref}"
}

sync_repo "${VERILATOR_PATH}" "verilator" "${VERILATOR_TAG}"
sync_repo "${COCOTB_PATH}" "cocotb" "${COCOTB_TAG}"

echo
echo "third-party libraries are aligned"
echo "  verilator -> ${VERILATOR_TAG}"
echo "  cocotb    -> ${COCOTB_TAG}"
