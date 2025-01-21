#!/bin/bash

echo "=== CPU Information ==="
lscpu | grep -E "Model name|^CPU\(s\):|Core\(s\) per socket|Thread\(s\) per core|CPU MHz|CPU max MHz"

echo -e "\n=== Memory Information ==="
free -h
echo "RAM Speed:"
sudo dmidecode -t memory | grep -i speed | head -n 1

echo -e "\n=== GPU Information ==="
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv
else
    echo "No NVIDIA GPU detected"
fi

echo -e "\n=== Storage Information ==="
df -h /

echo -e "\n=== CPU Extensions ==="
lscpu | grep -E "avx2|avx512"

echo -e "\n=== Power Management ==="
if [ -d "/sys/class/power_supply/BAT0" ]; then
    echo "System Type: Laptop"
    echo "Battery Status:"
    cat /sys/class/power_supply/BAT0/status
    echo "Battery Capacity:"
    cat /sys/class/power_supply/BAT0/capacity
else
    echo "System Type: Desktop/Server"
fi

echo -e "\n=== Temperature Information ==="
if command -v sensors &> /dev/null; then
    sensors
else
    echo "sensors command not found. Install with: sudo apt install lm-sensors"
fi
