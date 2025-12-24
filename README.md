# UPS 4x6 AutoFit Printer (Linux / CUPS)

Creates a system-wide CUPS printer queue that:
- takes UPS letter-sized PDFs
- crops the top-left 4×6 label
- rotates to match thermal feed
- prints to a Bixolon/Zebra-style label printer

## Install (Linux Mint / Debian / Ubuntu)

```bash
sudo apt install git
git clone https://github.com/YOURUSER/upslabel-autofit.git
cd upslabel-autofit
sudo ./install.sh
