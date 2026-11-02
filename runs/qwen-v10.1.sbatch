#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH -J cf-v10.1
#SBATCH -o /home2/akshithkandagatla/AUTOSE-Leaniers/runs/qwen-v10.1.log
# L0 v10.1: gamma j x3 (seeds 42-44), then the held-out doc once (seed 42).
module load u22/cuda/12.4
nvidia-smi --query-gpu=name,memory.total --format=csv
cd /home2/akshithkandagatla/AUTOSE-Leaniers/harness
python -u main.py "../Requirements/0000 - gamma j.xml" --model qwen --repeat 3 & PID=$!
bash ../scripts/usage_guard.sh $PID ../runs/qwen-v10.1.usage.log &
wait $PID; echo "EXIT gamma $?"
python -u main.py "../Requirements/2009 - video search.xml" --model qwen --repeat 1 & PID=$!
bash ../scripts/usage_guard.sh $PID ../runs/qwen-v10.1.usage.log &
wait $PID; echo "EXIT video $?"
