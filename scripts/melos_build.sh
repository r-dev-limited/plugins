#!/usr/bin/env bash
set -euo pipefail

/opt/homebrew/bin/fvm dart run build_runner build -d
