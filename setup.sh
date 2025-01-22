#!/bin/bash

echo "🚀 Local LLM Setup Script"
echo "========================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (sudo)"
    exit 1
fi

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "📥 Installing required packages..."
apt install -y python3-pip python3-venv build-essential curl wget git htop lm-sensors

# Set up Python environment
echo "🐍 Setting up Python environment..."
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Install Ollama
echo "🤖 Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Run system check
echo "🔍 Checking system capabilities..."
chmod +x system_check.sh
./system_check.sh > system_info.txt

# Select appropriate model
echo "📊 Selecting optimal model..."
chmod +x select_model.sh
./select_model.sh > model_selection.txt

# Optimize system
echo "⚡ Optimizing system..."
chmod +x optimize_system.sh
./optimize_system.sh

# Make monitoring script executable
chmod +x monitor.sh

echo "✅ Setup complete!"
echo "Next steps:"
echo "1. Review system_info.txt for hardware capabilities"
echo "2. Review model_selection.txt for recommended model"
echo "3. Run './monitor.sh' to start system monitoring"
echo "4. Run benchmark tests with 'python llm_benchmark.py'"
