#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${VENV_DIR:-${ROOT_DIR}/.venv}"

if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  echo "error: ${PYTHON_BIN} not found"
  exit 1
fi

WHEELHOUSE_DIR="${WHEELHOUSE_DIR:-${ROOT_DIR}/wheelhouse}"

echo "creating virtual environment at ${VENV_DIR}"
"${PYTHON_BIN}" -m venv "${VENV_DIR}"

"${VENV_DIR}/bin/python" -m ensurepip --upgrade --default-pip

# Upgrade pip/setuptools/wheel: use wheelhouse if available, otherwise network
if [[ -d "${WHEELHOUSE_DIR}" ]] && find "${WHEELHOUSE_DIR}" -name '*.whl' -print -quit | grep -q .; then
  echo "installing pip/setuptools/wheel from local wheelhouse (offline)"
  "${VENV_DIR}/bin/python" -m pip install --no-index --find-links "${WHEELHOUSE_DIR}" \
    pip setuptools wheel
else
  "${VENV_DIR}/bin/python" -m pip install --upgrade pip setuptools wheel
fi

echo "virtual environment ready: ${VENV_DIR}"
