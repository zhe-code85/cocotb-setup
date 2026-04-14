#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COCOTB_SRC_DIR="${COCOTB_SRC_DIR:-${ROOT_DIR}/third_party/cocotb}"
PYTHON_BIN="${PYTHON_BIN:-python}"
WHEELHOUSE_DIR="${WHEELHOUSE_DIR:-${ROOT_DIR}/wheelhouse}"
PYTHON_PATH=""
HAS_OFFLINE_PACKAGES=0

if [[ ! -d "${COCOTB_SRC_DIR}" ]]; then
  echo "error: cocotb source tree not found: ${COCOTB_SRC_DIR}"
  exit 1
fi

if [[ "${PYTHON_BIN}" == */* ]]; then
  PYTHON_PATH="${PYTHON_BIN}"
else
  PYTHON_PATH="$(command -v "${PYTHON_BIN}" || true)"
fi

if [[ -z "${PYTHON_PATH}" ]] || [[ ! -x "${PYTHON_PATH}" ]]; then
  echo "error: Python interpreter not found: ${PYTHON_BIN}"
  echo "hint: activate your virtual environment first or set PYTHON_BIN"
  exit 1
fi

if [[ -d "${WHEELHOUSE_DIR}" ]] && find "${WHEELHOUSE_DIR}" -type f ! -name '.gitignore' -print -quit | grep -q .; then
  HAS_OFFLINE_PACKAGES=1
fi

if [[ -f "${COCOTB_SRC_DIR}/pyproject.toml" ]]; then
  if [[ "${HAS_OFFLINE_PACKAGES}" -eq 1 ]]; then
    "${PYTHON_PATH}" -m pip install --no-build-isolation --no-index --find-links "${WHEELHOUSE_DIR}" "${COCOTB_SRC_DIR}"
  else
    "${PYTHON_PATH}" -m pip install --no-build-isolation "${COCOTB_SRC_DIR}"
  fi
else
  echo "error: ${COCOTB_SRC_DIR} does not look like a Python package source tree"
  exit 1
fi

echo "cocotb installed with ${PYTHON_PATH}"
