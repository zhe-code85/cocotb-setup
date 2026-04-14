#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
  echo "error: activate your virtual environment first"
  exit 1
fi

if ! command -v vcs >/dev/null 2>&1; then
  echo "error: vcs executable not found"
  echo "hint: install and license Synopsys VCS separately, then make sure it is on PATH"
  exit 1
fi

# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/env.sh"
python "${ROOT_DIR}/examples/tiny_counter/run.py" --sim vcs
