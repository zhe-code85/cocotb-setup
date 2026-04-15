#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VERILATOR_PATH="${VERILATOR_PATH:-${ROOT_DIR}/third_party/verilator}"
COCOTB_PATH="${COCOTB_PATH:-${ROOT_DIR}/third_party/cocotb}"

VERILATOR_TAG="${VERILATOR_TAG:-v5.046}"
COCOTB_TAG="${COCOTB_TAG:-v2.0.1}"

# Check if a submodule is properly initialized by looking for a .git file/link
# that points into the parent's .git/modules/ directory (not the parent repo itself).
is_submodule_initialized() {
  local repo_path="$1"
  local gitdir

  if [[ ! -f "${repo_path}/.git" ]] && [[ ! -d "${repo_path}/.git" ]]; then
    return 1
  fi

  gitdir="$(cd "${repo_path}" && git rev-parse --git-dir 2>/dev/null || true)"
  # An initialized submodule's gitdir contains "modules/" in the path
  if [[ "${gitdir}" == *"/modules/"* ]]; then
    return 0
  fi
  return 1
}

sync_repo() {
  local repo_path="$1"
  local repo_name="$2"
  local target_ref="$3"

  if ! is_submodule_initialized "${repo_path}"; then
    echo "warning: ${repo_name} submodule not initialized at ${repo_path}"
    echo "run 'git submodule update --init --recursive' from the repository root first"
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
