import time
import json
import gc
import signal
from typing import Optional
from datetime import datetime
import ollama
import psutil

class TimeoutException(Exception):
    pass

def timeout(seconds):
    def decorator(func):
        def _handle_timeout(signum, frame):
            raise TimeoutException()

        def wrapper(*args, **kwargs):
            signal.signal(signal.SIGALRM, _handle_timeout)
            signal.alarm(seconds)
            try:
                result = func(*args, **kwargs)
            finally:
                signal.alarm(0)
            return result
        return wrapper
    return decorator

def run_with_timeout(prompt: str, model_name: str, timeout_seconds: int = 30) -> Optional[str]:
    """Run LLM inference with a timeout"""
    try:
        # Add a small delay between runs
        time.sleep(2)
        @timeout(timeout_seconds)
        def generate():
            response = ollama.generate(model=model_name, 
                                     prompt=prompt,
                                     options={
                                         "temperature": 0.7,
                                         "num_ctx": 2048,  # Updated for better context
                                         "repeat_penalty": 1.1,
                                         "num_predict": 256,  # Increased for better responses
                                         "top_k": 40,
                                         "top_p": 0.9
                                     })
            return response['response']
            
        return generate()
    except TimeoutException:
        print(f"⚠️ Inference timed out after {timeout_seconds} seconds")
        return None
    except Exception as e:
        print(f"⚠️ Error during inference: {str(e)}")
        if "loading model" in str(e).lower():
            print("Waiting for model to load...")
            time.sleep(5)
            try:
                return generate()
            except Exception as retry_e:
                print(f"⚠️ Retry failed: {str(retry_e)}")
        return None
    finally:
        gc.collect()

def benchmark_model(model_name: str, num_runs=2):
    print(f"\n🔄 Benchmarking {model_name}...")
    
    # Test prompts
    test_prompts = [
        # Basic Prompts
        "Hi.",
        "What is your name?",
        
        # Analytical Tasks (Simplified)
        "Explain what a binary search is in one sentence.",
        "Name three renewable energy sources.",
        
        # Creative Tasks
        "Write a haiku about coding.",
        "Describe a sunset on Mars in one sentence.",
        
        # Logic and Reasoning (Simplified)
        "Calculate: 60 mph × 2.5 hours = ?",
        "Is this valid logic: All birds fly, penguins are birds, so penguins fly?",
        
        # Knowledge Integration (Focused)
        "What is the main difference between photosynthesis and respiration?",
        "Give one example of supply and demand.",
        
        # Edge Cases (Simplified)
        "List 5 random numbers between 1-100.",
        "Translate 'Hello' into Spanish and French."
    ]
    
    results = []
    
    for i, prompt in enumerate(test_prompts, 1):
        print(f"\n📝 Test {i}/{len(test_prompts)}: {prompt}")
        
        prompt_results = []
        for run in range(num_runs):
            print(f"\n🔄 Run {run + 1}/{num_runs}")
            print("Starting inference...")
            
            start_time = time.time()
            response = run_with_timeout(prompt, model_name)
            
            if response is not None:
                end_time = time.time()
                duration = end_time - start_time
                tokens = len(response.split())
                tokens_per_second = tokens / duration if duration > 0 else 0
                
                result = {
                    "prompt": prompt,
                    "response": response,
                    "duration": duration,
                    "tokens": tokens,
                    "tokens_per_second": tokens_per_second
                }
                prompt_results.append(result)
                print(f"✓ Response: {response}")
                print(f"⏱️ Time: {duration:.2f}s")
                print(f"📊 Tokens/sec: {tokens_per_second:.2f}")
            else:
                print("Skipping this run due to error")
            
            # Force garbage collection
            gc.collect()
        
        if prompt_results:
            avg_duration = sum(r["duration"] for r in prompt_results) / len(prompt_results)
            avg_tokens = sum(r["tokens"] for r in prompt_results) / len(prompt_results)
            avg_tokens_per_second = sum(r["tokens_per_second"] for r in prompt_results) / len(prompt_results)
            
            results.append({
                "prompt": prompt,
                "avg_duration": avg_duration,
                "avg_tokens": avg_tokens,
                "avg_tokens_per_second": avg_tokens_per_second,
                "runs": prompt_results
            })
            
            print(f"\n📊 Average for prompt:")
            print(f"⏱️ Time: {avg_duration:.2f}s")
            print(f"📊 Tokens/sec: {avg_tokens_per_second:.2f}")
    
    # Save results to file
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results_file = f"benchmark_results_{model_name}_{timestamp}.json"
    with open(results_file, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\n💾 Results saved to {results_file}")

if __name__ == "__main__":
    # Get total system memory
    total_memory = psutil.virtual_memory().total / (1024**3)  # Convert to GB
    
    # Select appropriate model based on system memory
    if total_memory >= 32:
        model_name = "deepseek-r1:14b"
    elif total_memory >= 16:
        model_name = "deepseek-r1:8b"
    else:
        model_name = "deepseek-coder:6.7b"
    
    benchmark_model(model_name)
