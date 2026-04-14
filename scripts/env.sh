#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "source scripts/env.sh"
  exit 1
fi

_cocotb_setup_root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
_cocotb_setup_verilator_prefix="${VERILATOR_PREFIX:-${_cocotb_setup_root_dir}/local/verilator}"

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
  echo "warning: no virtual environment is active; activate your chosen virtual environment first" >&2
fi

if [[ -d "${_cocotb_setup_verilator_prefix}/bin" ]]; then
  export PATH="${_cocotb_setup_verilator_prefix}/bin:${PATH}"
fi

if command -v python >/dev/null 2>&1; then
  _cocotb_setup_libpython="$(
    python - <<'PY'
import sysconfig
from pathlib import Path

libdir = sysconfig.get_config_var("LIBDIR")
ldlibrary = sysconfig.get_config_var("LDLIBRARY")
if libdir and ldlibrary:
    print(Path(libdir) / ldlibrary)
PY
  )"
  if [[ -n "${_cocotb_setup_libpython}" ]]; then
    export LIBPYTHON_LOC="${_cocotb_setup_libpython}"
  fi
fi

unset _cocotb_setup_root_dir
unset _cocotb_setup_verilator_prefix
unset _cocotb_setup_libpython
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
  echo "using virtual environment: ${VIRTUAL_ENV}"
fi
