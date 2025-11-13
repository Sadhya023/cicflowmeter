#!/bin/bash
# ---------------------------------------------------------
# CICFlowMeter Auto Setup Script by Sadhya023
# ---------------------------------------------------------

set -e  # Exit on error

echo "🔧 Updating and installing dependencies..."
apt update -y && apt upgrade -y
apt install -y git python3 python3-venv python3-pip curl apache2 telnetd vsftpd

echo "🚀 Installing uv..."
pip install uv

echo "📂 Cloning CICFlowMeter repository..."
git clone https://github.com/Sadhya023/cicflowmeter.git
cd cicflowmeter

echo "⚙️ Syncing environment with uv..."
uv sync

echo "🔒 Activating virtual environment..."
source .venv/bin/activate

echo "✅ CICFlowMeter environment ready!"
echo "------------------------------------"
read -p "Enter input interface (e.g. eth0, wlan0): " interface
read -p "Enter output file type (csv or flow): " filetype
read -p "Enter URL to send logs (or leave blank): " logurl
echo "------------------------------------"

echo "🌐 Starting Apache, Telnet, and FTP services..."
service apache2 start
service openbsd-inetd start 2>/dev/null || true
service vsftpd start 2>/dev/null || true

echo "🚦 Running CICFlowMeter..."
if [ -z "$logurl" ]; then
    cicflowmeter -i "$interface" -f "$filetype"
else
    cicflowmeter -i "$interface" -f "$filetype" -u "$logurl"
fi
