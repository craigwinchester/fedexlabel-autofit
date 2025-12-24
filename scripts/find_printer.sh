#!/usr/bin/env bash
set -euo pipefail

# Prefer a known queue name
if lpstat -p LabelPrinter >/dev/null 2>&1; then
  echo "LabelPrinter"
  exit 0
fi

# Otherwise, detect Bixolon/Zebra-like devices
while read -r p; do
  if lpstat -v "$p" 2>/dev/null | grep -qiE 'bixolon|zebra|srp-770'; then
    echo "$p"
    exit 0
  fi
done < <(lpstat -p | awk '{print $2}')

exit 1
