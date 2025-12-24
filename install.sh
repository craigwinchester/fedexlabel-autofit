#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }

echo "Installing dependencies..."
apt-get update -y >/dev/null
apt-get install -y cups ghostscript imagemagick >/dev/null

echo "Installing CUPS filter..."

# IMPORTANT: Mint/CUPS uses /usr/lib/cups/filter in PATH.
# Also remove any old copy in /usr/local to avoid confusion.
rm -f /usr/local/lib/cups/filter/fedex_4x6_autofit 2>/dev/null || true

install -Dm755 cups/filter/fedex_4x6_autofit \
  /usr/lib/cups/filter/fedex_4x6_autofit

echo "Installing config (won't overwrite existing)..."
if [[ ! -f /etc/fedexlabel-autofit.conf ]]; then
  install -Dm644 cups/config/fedexlabel-autofit.conf /etc/fedexlabel-autofit.conf
else
  echo "Config exists at /etc/fedexlabel-autofit.conf — leaving it unchanged."
fi

echo "Detecting label printer..."
PRINTER="$(scripts/find_printer.sh || true)"
[[ -n "$PRINTER" ]] || { echo "No Bixolon/Zebra printer found."; exit 2; }

echo "Using printer: $PRINTER"

PPD_SRC="/etc/cups/ppd/${PRINTER}.ppd"
PPD_DST="/etc/cups/ppd/FedEx_4x6_Autofit.ppd"

cp -f "$PPD_SRC" "$PPD_DST"

if ! grep -q fedex_4x6_autofit "$PPD_DST"; then
  echo '*cupsFilter: "application/pdf 0 fedex_4x6_autofit"' >> "$PPD_DST"
fi

URI="$(lpstat -v "$PRINTER" | sed -n 's/^device for .*: //p')"

lpadmin -x FedEx_4x6_Autofit >/dev/null 2>&1 || true
lpadmin -p FedEx_4x6_Autofit -E -v "$URI" -P "$PPD_DST"

lpoptions -p FedEx_4x6_Autofit \
  -o PageSize=w288h432 \
  -o Resolution=203dpi >/dev/null 2>&1 || true

systemctl restart cups || service cups restart

echo
echo "✔ Installed printer: FedEx_4x6_Autofit"
echo "✔ Available to ALL users"

