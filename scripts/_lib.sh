#!/usr/bin/env bash
set -euo pipefail

ensure_dir(){ mkdir -p "$1"; }

die(){ echo "[ERROR] $*" >&2; exit 1; }