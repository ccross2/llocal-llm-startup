#!/bin/bash

# Get system info
total_ram=$(free -g | awk '/^Mem:/{print $2}')
gpu_memory=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | awk '{sum += $1} END {print sum}' || echo "0")
is_laptop=$(test -d "/sys/class/power_supply/BAT0" && echo "true" || echo "false")
cpu_threads=$(nproc)
has_avx2=$(lscpu | grep -q avx2 && echo "true" || echo "false")

# Print system information with emojis
echo "🖥️  System Information"
echo "===================="
echo "Total RAM: ${total_ram}GB"
echo "GPU Memory: ${gpu_memory}GB"
echo "Form Factor: $([ "$is_laptop" = "true" ] && echo "Laptop 💻" || echo "Desktop 🖥️")"
echo "CPU Threads: $cpu_threads"
echo "AVX2 Support: $([ "$has_avx2" = "true" ] && echo "Yes ✅" || echo "No ❌")"

echo -e "\n🎯 Recommended Models"
echo "===================="
echo "Based on your system specifications, here are your model options:"

echo -e "\n1️⃣  Safe Choice (Optimal Performance)"
if [ "$total_ram" -ge 16 ]; then
    echo "   Model: DeepSeek R1 8B"
    echo "   RAM Required: ~12GB"
    echo "   Current RAM: ${total_ram}GB ✅"
    echo "   Command: ollama pull deepseek-r1:8b"
    echo "   Best for: Balanced performance and resource usage"
    echo "   Expected Performance: Fast inference, stable operation"
elif [ "$total_ram" -ge 12 ]; then
    echo "   Model: DeepSeek Coder V2 7B"
    echo "   RAM Required: ~8GB"
    echo "   Current RAM: ${total_ram}GB ✅"
    echo "   Command: ollama pull deepseek-coder-v2:7b"
    echo "   Best for: Code completion and general tasks"
    echo "   Expected Performance: Good balance of speed and capability"
else
    echo "   Model: DeepSeek LLM 7B"
    echo "   RAM Required: ~6GB"
    echo "   Current RAM: ${total_ram}GB ✅"
    echo "   Command: ollama pull deepseek-llm:7b"
    echo "   Best for: Basic tasks with limited resources"
    echo "   Expected Performance: Basic but stable"
fi

echo -e "\n2️⃣  Pushing Boundaries (Maximum Capability)"
if [ "$total_ram" -ge 32 ]; then
    echo "   Model: DeepSeek R1 14B"
    echo "   RAM Required: ~16GB"
    echo "   Current RAM: ${total_ram}GB ✅"
    echo "   Command: ollama pull deepseek-r1:14b"
    echo "   Best for: Enhanced capabilities, complex tasks"
    echo "   Expected Performance: High quality, slower inference"
    echo "   Note: May cause thermal throttling on laptops"
elif [ "$total_ram" -ge 16 ]; then
    echo "   Model: DeepSeek R1 14B (Experimental)"
    echo "   RAM Required: ~16GB"
    echo "   Current RAM: ${total_ram}GB ⚠️"
    echo "   Command: ollama pull deepseek-r1:14b"
    echo "   Best for: Testing limits, occasional heavy tasks"
    echo "   Expected Performance: May be unstable, slower inference"
    echo "   Warning: Close other applications before running"
else
    echo "   Model: DeepSeek R1 8B (Experimental)"
    echo "   RAM Required: ~12GB"
    echo "   Current RAM: ${total_ram}GB ⚠️"
    echo "   Command: ollama pull deepseek-r1:8b"
    echo "   Best for: Testing system limits"
    echo "   Expected Performance: May be unstable"
    echo "   Warning: Close other applications before running"
fi

echo -e "\n3️⃣  Conservative Choice (Resource-Efficient)"
echo "   Model: DeepSeek Coder 6.7B"
echo "   RAM Required: ~6GB"
echo "   Current RAM: ${total_ram}GB ✅"
echo "   Command: ollama pull deepseek-coder:6.7b"
echo "   Best for: Development tasks, lightweight usage"
echo "   Expected Performance: Fast, stable, resource-efficient"

echo -e "\n⚙️  Recommended Settings"
echo "===================="
if [ "$is_laptop" = "true" ]; then
    echo "Environment Variables:"
    echo "   export OLLAMA_HOST_THREADS=4"
    echo "   export OLLAMA_BATCH_SIZE=8"
    echo -e "\nPower Management:"
    echo "   • Consider using power adapter"
    echo "   • Monitor CPU temperature"
    echo "   • Enable thermal management"
else
    echo "Environment Variables:"
    echo "   export OLLAMA_HOST_THREADS=$cpu_threads"
    echo "   export OLLAMA_BATCH_SIZE=16"
    echo -e "\nPerformance Settings:"
    echo "   • CPU Governor: performance"
    echo "   • Process Priority: high"
fi

echo -e "\n💡 Additional Notes"
echo "===================="
echo "• All RAM requirements are approximate"
echo "• Performance may vary based on workload"
echo "• Monitor system resources using './monitor.sh'"
echo "• Run benchmarks using 'python llm_benchmark.py'"
echo "• Use 'ollama rm <model>' to free up space"

echo -e "\n🔄 Next Steps"
echo "===================="
echo "1. Choose your preferred model from above"
echo "2. Run the corresponding 'ollama pull' command"
echo "3. Apply recommended environment variables"
echo "4. Start with a test prompt to verify performance"
echo "5. Monitor system resources during usage"
