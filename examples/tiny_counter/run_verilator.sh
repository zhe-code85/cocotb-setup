#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
  echo "error: activate your virtual environment first"
  exit 1
fi

# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/env.sh"
python "${ROOT_DIR}/examples/tiny_counter/run.py" --sim verilator
