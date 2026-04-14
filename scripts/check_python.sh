#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN="${PYTHON_BIN:-python3}"

if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  echo "error: ${PYTHON_BIN} not found"
  exit 1
fi

"${PYTHON_BIN}" - <<'PY'
import sys
import sysconfig

min_version = (3, 8)
version = sys.version_info[:3]

print(f"python executable: {sys.executable}")
print(f"python version: {sys.version.split()[0]}")
print(f"Py_ENABLE_SHARED: {sysconfig.get_config_var('Py_ENABLE_SHARED')}")
print(f"LIBDIR: {sysconfig.get_config_var('LIBDIR')}")
print(f"LDLIBRARY: {sysconfig.get_config_var('LDLIBRARY')}")

if version < min_version:
    raise SystemExit(
        f"error: Python {version[0]}.{version[1]}.{version[2]} is too old; "
        f"need >= {min_version[0]}.{min_version[1]}"
    )
PY

echo "python check passed"
