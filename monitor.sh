#!/bin/bash

# Function to get CPU usage for Ollama process
get_ollama_cpu() {
    pid=$(pgrep -x ollama)
    if [ ! -z "$pid" ]; then
        top -b -n1 -p "$pid" | tail -1 | awk '{print $9}'
    else
        echo "0.0"
    fi
}

# Function to get memory usage for Ollama process
get_ollama_memory() {
    pid=$(pgrep -x ollama)
    if [ ! -z "$pid" ]; then
        top -b -n1 -p "$pid" | tail -1 | awk '{print $10}'
    else
        echo "0.0"
    fi
}

# Function to get CPU temperature
get_cpu_temp() {
    if command -v sensors &> /dev/null; then
        sensors | grep -i "Package id 0:" | awk '{print $4}' | tr -d '+°C'
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
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo "Overall CPU Usage: ${cpu_usage}%"
    echo "Ollama CPU Usage: $(get_ollama_cpu)%"
    
    echo -e "\n=== Memory Usage ==="
    free -h | grep -v +
    echo "Ollama Memory Usage: $(get_ollama_memory)%"
    
    echo -e "\n=== Temperature ==="
    cpu_temp=$(get_cpu_temp)
    echo "CPU Temperature: ${cpu_temp}°C"
    
    if command -v nvidia-smi &> /dev/null; then
        echo -e "\n=== GPU Usage ==="
        nvidia-smi --query-gpu=utilization.gpu,memory.used,temperature.gpu --format=csv,noheader
    fi
    
    echo -e "\n=== Process Status ==="
    if pgrep -x ollama > /dev/null; then
        echo "Ollama Status: Running (PID: $(pgrep -x ollama))"
        echo "Memory Details:"
        ps -o pid,ppid,%mem,rss,cmd -p "$(pgrep -x ollama)" 2>/dev/null || echo "Process details unavailable"
    else
        echo "Ollama Status: Not Running"
    fi
    
    sleep 2
done
