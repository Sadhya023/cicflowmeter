#!/bin/bash
# ---------------------------------------------------------
# 🚀 CICFlowMeter Auto Setup Script by Sadhya023
# ---------------------------------------------------------
# This script automatically sets up all dependencies,
# configures services, and prepares the CICFlowMeter
# environment with uv and Apache server.
# ---------------------------------------------------------

set -e  # Exit immediately if a command exits with a non-zero status

# ---------------------------------------------------------
# 💻 Server Banner
# ---------------------------------------------------------
echo "
 ██████╗ ██╗ ██████╗███████╗██╗      ██████╗ ██╗    ██╗███╗   ███╗███████╗████████╗███████╗██████╗ 
██╔════╝ ██║██╔════╝██╔════╝██║     ██╔═══██╗██║    ██║████╗ ████║██╔════╝╚══██╔══╝██╔════╝██╔══██╗
██║  ███╗██║██║     █████╗  ██║     ██║   ██║██║ █╗ ██║██╔████╔██║█████╗     ██║   █████╗  ██████╔╝
██║   ██║██║██║     ██╔══╝  ██║     ██║   ██║██║███╗██║██║╚██╔╝██║██╔══╝     ██║   ██╔══╝  ██╔══██╗
╚██████╔╝██║╚██████╗███████╗███████╗╚██████╔╝╚███╔███╔╝██║ ╚═╝ ██║███████╗   ██║   ███████╗██║  ██║
 ╚═════╝ ╚═╝ ╚═════╝╚══════╝╚══════╝ ╚═════╝  ╚══╝╚══╝ ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
----------------------------------------------------------------------------------------------------
"

echo "🔧 Updating and installing dependencies..."
apt update -y && apt upgrade -y
apt install -y git python3 python3-venv python3-pip curl apache2 telnetd vsftpd

echo "🌐 Configuring Apache server..."
systemctl enable apache2
systemctl start apache2
ufw allow 'Apache' >/dev/null 2>&1 || true
echo "✅ Apache web server is up and running at: http://localhost"

# ---------------------------------------------------------
# 🧰 Setup CICFlowMeter
# ---------------------------------------------------------
echo "🚀 Installing uv..."
pip install uv

echo "📂 Cloning CICFlowMeter repository..."
if [ ! -d "cicflowmeter" ]; then
    git clone https://github.com/Sadhya023/cicflowmeter.git
fi
cd cicflowmeter

# ---------------------------------------------------------
# 🐍 Setting up Python environment using uv
# ---------------------------------------------------------
echo "⚙️ Setting up Python environment..."

# 1️⃣ Install the required Python version
uv python install 3.12

# 2️⃣ Create and activate a venv
uv venv --python 3.12
source .venv/bin/activate

# 3️⃣ Sync dependencies
uv sync

# Deactivate the uv's environment
deactivate

# ---------------------------------------------------------
# 🚦 Running CICFlowMeter
# ---------------------------------------------------------
#echo "✅ CICFlowMeter environment ready!"
#echo "------------------------------------"
#read -p "Enter input interface (e.g. eth0, wlan0): " interface
#read -p "Enter output file type (csv or flow): " filetype
#read -p "Enter URL to send logs (or leave blank): " logurl
#echo "------------------------------------"

echo "🌐 Starting Telnet and FTP services..."
service openbsd-inetd start 2>/dev/null || true
service vsftpd start 2>/dev/null || true

echo "🚦 Running CICFlowMeter..."
source .venv/bin/activate
if [ -z "$logurl" ]; then
    cicflowmeter -i "$interface" -f "$filetype"
else
    cicflowmeter -i "$interface" -f "$filetype" -u "$logurl"
fi
