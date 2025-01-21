#!/bin/bash

# Function to get CPU usage for Ollama process
get_ollama_cpu() {
    pid=$(pgrep ollama)
    if [ ! -z "$pid" ]; then
        ps -p $pid -o %cpu | tail -n 1
    else
        echo "0.0"
    fi
}

# Function to get memory usage for Ollama process
get_ollama_memory() {
    pid=$(pgrep ollama)
    if [ ! -z "$pid" ]; then
        ps -p $pid -o %mem | tail -n 1
    else
        echo "0.0"
    fi
}

# Function to get CPU temperature
get_cpu_temp() {
    if command -v sensors &> /dev/null; then
        sensors | grep -i "CPU" | awk '{print $2}' | tr -d '+°C' | head -n 1
    else
        echo "N/A"
    fi
}

# Main monitoring loop
while true; do
    clear
    echo "=== System Monitor for Ollama ==="
    date
    
    echo -e "\n=== CPU Usage ==="
    echo "Overall CPU Usage:"
    top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | awk '{print $1"%"}'
    echo "Ollama CPU Usage: $(get_ollama_cpu)%"
    
    echo -e "\n=== Memory Usage ==="
    free -h | grep -v +
    echo "Ollama Memory Usage: $(get_ollama_memory)%"
    
    echo -e "\n=== Temperature ==="
    cpu_temp=$(get_cpu_temp)
    echo "CPU Temperature: $cpu_temp°C"
    
    if command -v nvidia-smi &> /dev/null; then
        echo -e "\n=== GPU Usage ==="
        nvidia-smi --query-gpu=utilization.gpu,memory.used,temperature.gpu --format=csv,noheader
    fi
    
    echo -e "\n=== Process Status ==="
    if pgrep ollama > /dev/null; then
        echo "Ollama Status: Running"
    else
        echo "Ollama Status: Not Running"
    fi
    
    sleep 2
done
