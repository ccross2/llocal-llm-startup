#!/bin/bash

echo "🔧 System Optimization Script for LLM Performance"
echo "==============================================="

# Function to check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo "❌ Please run as root (sudo)"
        exit 1
    fi
}

# Function to optimize CPU governor
optimize_cpu() {
    echo "⚡ Optimizing CPU Performance..."
    
    # Set CPU governor to performance mode
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "performance" > "$cpu"
        done
        
        # Disable CPU throttling
        echo "1" > /sys/devices/system/cpu/intel_pstate/no_turbo
    
    # Set process niceness for Ollama
    ollama_pid=$(pgrep ollama)
    if [ ! -z "$ollama_pid" ]; then
        renice -20 "$ollama_pid"
        echo "✓ Set high priority for Ollama process"
    fi
}

# Function to optimize memory
optimize_memory() {
    echo "💾 Optimizing Memory..."
    
    # Drop caches
    sync
    echo 3 > /proc/sys/vm/drop_caches
    
    # Optimize swap
    echo 10 > /proc/sys/vm/swappiness
    
    # Disable transparent huge pages
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    
    # Increase max map count for better memory management
    echo 262144 > /proc/sys/vm/max_map_count
}

# Function to optimize I/O
optimize_io() {
    echo "💿 Optimizing I/O..."
    
    # Set I/O scheduler to deadline for NVMe
    for device in /sys/block/nvme*; do
        if [ -d "$device" ]; then
            echo deadline > "$device/queue/scheduler"
        fi
    done
    
    # Increase read ahead value for better I/O performance
    for device in /sys/block/nvme*; do
        if [ -d "$device" ]; then
            echo 2048 > "$device/queue/read_ahead_kb"
        fi
    done
}

# Function to create a RAM disk for temporary files
create_ramdisk() {
    echo "🚀 Creating RAM disk for temporary files..."
    
    # Create mount point if it doesn't exist
    mkdir -p /mnt/ollama_tmp
    
    # Mount RAM disk
    mount -t tmpfs -o size=8G tmpfs /mnt/ollama_tmp
    
    # Set permissions
    chmod 1777 /mnt/ollama_tmp
    
    echo "✓ RAM disk created at /mnt/ollama_tmp"
}

# Function to optimize network
optimize_network() {
    echo "🌐 Optimizing Network..."
    
    # Increase network buffer sizes
    echo 16777216 > /proc/sys/net/core/rmem_max
    echo 16777216 > /proc/sys/net/core/wmem_max
    echo 16777216 > /proc/sys/net/core/rmem_default
    echo 16777216 > /proc/sys/net/core/wmem_default
    
    # Optimize TCP settings
    echo 1 > /proc/sys/net/ipv4/tcp_low_latency
}

# Function to monitor system resources
setup_monitoring() {
    echo "📊 Setting up system monitoring..."
    
    # Install monitoring tools if not present
    if ! command -v htop &> /dev/null; then
        apt-get update
        apt-get install -y htop
    fi
}

# Function to optimize system settings for running the LLM
optimize_llm_settings() {
    echo "Setting up system optimizations..."

    # Set conservative environment variables for Ollama
    export OLLAMA_HOST_THREADS=4
    export OLLAMA_BATCH_SIZE=4
    export OLLAMA_GPU_LAYERS=0

    # Aggressive memory management
    sudo sysctl -w vm.swappiness=5
    sudo sysctl -w vm.vfs_cache_pressure=50
    sudo sysctl -w vm.dirty_ratio=5
    sudo sysctl -w vm.dirty_background_ratio=2
    sudo sysctl -w vm.min_free_kbytes=1048576  # 1GB minimum free

    # Clear system caches
    sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

    # Set CPU governor to powersave for thermal management
    if command -v cpupower &> /dev/null; then
        sudo cpupower frequency-set -g powersave
    fi

    # Optimize process priority
    pid=$(pgrep ollama)
    if [ ! -z "$pid" ]; then
        sudo renice -n 0 -p $pid  # Normal priority to avoid system strain
        sudo ionice -c 2 -n 4 -p $pid  # Best-effort, lower priority
    fi

    echo "Memory-focused optimization complete."
}

# Main execution
echo "Starting system optimization..."
check_root

# Run optimizations
optimize_cpu
optimize_memory
optimize_io
create_ramdisk
optimize_network
setup_monitoring
optimize_llm_settings

echo "✅ System optimization complete!"
echo "NOTE: These settings will revert after system reboot."
echo "To make them permanent, add this script to your startup configuration."

# Print current system status
echo -e "\n📊 Current System Status:"
echo "-------------------------"
free -h
echo -e "\nCPU Governor Settings:"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo -e "\nSwap Usage:"
swapon --show
echo -e "\nActive RAM Disk:"
df -h | grep ollama_tmp
