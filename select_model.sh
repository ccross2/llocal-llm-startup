#!/bin/bash

# Get system info
total_ram=$(free -g | awk '/^Mem:/{print $2}')
gpu_memory=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null || echo "0")
is_laptop=$(test -d "/sys/class/power_supply/BAT0" && echo "true" || echo "false")
cpu_threads=$(nproc)
has_avx2=$(lscpu | grep -q avx2 && echo "true" || echo "false")

echo "=== System Information ==="
echo "Total RAM: ${total_ram}GB"
echo "GPU Memory: ${gpu_memory}GB"
echo "Is Laptop: $is_laptop"
echo "CPU Threads: $cpu_threads"
echo "Has AVX2: $has_avx2"

echo -e "\n=== Recommended Model ==="
if [ "$is_laptop" = "true" ]; then
    if [ "$total_ram" -lt 12 ]; then
        echo "Recommended Model: deepseek-llm:7b-q4_0"
        echo "Reason: Optimized for laptop with limited RAM"
        echo "Command: ollama pull deepseek-llm:7b-q4_0"
    else
        echo "Recommended Model: deepseek-r1:8b"
        echo "Reason: Balanced for laptop performance"
        echo "Command: ollama pull deepseek-r1:8b"
    fi
else
    if [ "$total_ram" -lt 16 ]; then
        echo "Recommended Model: deepseek-llm:7b-q4_0"
        echo "Reason: Suitable for systems with limited RAM"
        echo "Command: ollama pull deepseek-llm:7b-q4_0"
    elif [ "$total_ram" -lt 32 ]; then
        echo "Recommended Model: deepseek-r1:8b"
        echo "Reason: Good balance of performance and resource usage"
        echo "Command: ollama pull deepseek-r1:8b"
    else
        echo "Recommended Model: deepseek-r1:14b"
        echo "Reason: Best performance for high-resource systems"
        echo "Command: ollama pull deepseek-r1:14b"
    fi
fi

echo -e "\n=== Recommended Settings ==="
if [ "$is_laptop" = "true" ]; then
    echo "OLLAMA_HOST_THREADS=4"
    echo "OLLAMA_BATCH_SIZE=8"
else
    echo "OLLAMA_HOST_THREADS=$cpu_threads"
    echo "OLLAMA_BATCH_SIZE=16"
fi
