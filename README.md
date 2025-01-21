# Local LLM Setup with DeepSeek and Ollama 🚀

A comprehensive toolkit for setting up and optimizing DeepSeek models locally using Ollama. Designed for both human developers and agentic IDEs (like Cursor, Cline, or Windsurf).

## Quick Start 🏃
```bash
# Clone this repository
git clone https://github.com/ccross2/llocal-llm-startup.git
cd llocal-llm-startup

# Run the automated setup script
chmod +x setup.sh
sudo ./setup.sh
```

## Table of Contents 📑
1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Scripts Overview](#scripts-overview)
5. [Configuration](#configuration)
6. [Usage](#usage)
7. [Optimization](#optimization)
8. [Monitoring](#monitoring)
9. [Troubleshooting](#troubleshooting)

## Features ✨
- Automated system analysis and model selection
- Smart optimization for both desktop and laptop environments
- Real-time performance monitoring
- Thermal and power management for laptops
- Benchmark testing suite
- Agentic IDE integration support

## Prerequisites 📋

### Required Software
```bash
# Update package list
sudo apt update

# Install Python 3.10+ and development tools
sudo apt install -y python3.10 python3.10-venv python3-pip build-essential

# Install system monitoring tools
sudo apt install -y htop nvidia-smi sensors
```

### Python Dependencies
All required Python packages are listed in `requirements.txt`:
```txt
langchain-community>=0.0.10
psutil>=5.9.0
numpy>=1.24.0
torch>=2.0.0  # Optional, for GPU support
```

## Installation 💿

### Automated Installation
```bash
# Make setup script executable
chmod +x setup.sh

# Run setup script
sudo ./setup.sh
```

### Manual Installation
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh
```

## Scripts Overview 📜

### 1. setup.sh
Main installation and configuration script:
- Updates system packages
- Installs dependencies
- Sets up Python environment
- Configures Ollama
- Runs initial system analysis

### 2. system_check.sh
Analyzes system capabilities:
- CPU information and extensions
- Memory capacity and speed
- GPU detection and specifications
- Storage availability
- Power management status
- Temperature sensors

### 3. select_model.sh
Recommends optimal model based on hardware:
- Analyzes system resources
- Suggests appropriate model size
- Provides configuration recommendations
- Adapts to laptop/desktop environments

### 4. optimize_system.sh
System optimization script:
- CPU governor management
- Memory optimization
- Power management (laptop-specific)
- Process priority optimization
- Thermal management

### 5. monitor.sh
Real-time system monitoring:
- CPU usage and temperature
- Memory utilization
- GPU statistics (if available)
- Process status
- Power consumption (laptops)

### 6. llm_benchmark.py
Performance testing suite:
- Response time measurement
- Memory usage tracking
- Token generation speed
- Temperature monitoring
- Resource utilization analysis

## Configuration ⚙️

### Model Selection
Available models with hardware requirements:

| Model | RAM Required | VRAM Required | Best For |
|-------|--------------|---------------|-----------|
| DeepSeek-7B | 8GB | 6GB | Laptops, Limited RAM |
| DeepSeek-R1-8B | 12GB | 8GB | Balanced Usage |
| DeepSeek-14B | 16GB | 8GB | Performance |
| DeepSeek-R1-14B | 16GB | 10GB | High Performance |

### Modelfile Configuration
```
FROM deepseek-llm:7b-q4_0  # Update based on selection

# System-specific parameters
PARAMETER num_ctx {{ if gt .Memory 32 }}2048{{ else }}1024{{ end }}
PARAMETER num_predict {{ if gt .Memory 32 }}200{{ else }}150{{ end }}

# Quality parameters
PARAMETER temperature 0.7
PARAMETER top_k 40
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.2
```

## Usage 🎯

### 1. System Analysis
```bash
./system_check.sh > system_info.txt
```

### 2. Model Selection
```bash
./select_model.sh > model_selection.txt
```

### 3. System Optimization
```bash
sudo ./optimize_system.sh
```

### 4. Monitoring
```bash
./monitor.sh
```

### 5. Benchmark Testing
```bash
python llm_benchmark.py
```

## Optimization 🚀

### Desktop Systems
- Full CPU utilization
- Maximum performance governor
- High priority process scheduling
- GPU acceleration when available

### Laptop Systems
- Dynamic CPU governor
- Thermal-aware processing
- Power-efficient thread allocation
- Battery life optimization

## Monitoring 📊

Real-time monitoring includes:
- CPU usage and frequency
- Memory utilization
- GPU statistics
- Temperature tracking
- Power consumption
- Process statistics

## Troubleshooting 🔧

### Common Issues

1. Out of Memory
```bash
# Add swap space
sudo ./optimize_system.sh
```

2. High Temperature
```bash
# Monitor temperature
./monitor.sh
```

3. Poor Performance
```bash
# Check system status
./system_check.sh
# Adjust model selection
./select_model.sh
```

## Contributing 🤝

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License 📄

MIT License - See LICENSE file for details
