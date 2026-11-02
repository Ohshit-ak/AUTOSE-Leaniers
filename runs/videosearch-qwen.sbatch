#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH -J cf-vs
#SBATCH -o /home2/akshithkandagatla/AUTOSE-Leaniers/runs/videosearch-qwen.log
module load u22/cuda/12.4
nvidia-smi --query-gpu=name,memory.total --format=csv
cd /home2/akshithkandagatla/AUTOSE-Leaniers/harness
python -u main.py "../Requirements/2009 - video search.xml" --model qwen --run-name qwen-v8 & PID=$!
bash ../scripts/usage_guard.sh $PID ../runs/videosearch-qwen.usage.log &
wait $PID; echo "EXIT $?"
