#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH -J cf-v9
#SBATCH -o /home2/akshithkandagatla/AUTOSE-Leaniers/runs/qwen-v9.log
module load u22/cuda/12.4
nvidia-smi --query-gpu=name,memory.total --format=csv
cd /home2/akshithkandagatla/AUTOSE-Leaniers/harness
for DOC in "0000 - gamma j" "2009 - video search"; do
  echo "=== $DOC"
  python -u main.py "../Requirements/$DOC.xml" --model qwen --run-name qwen-v9 & PID=$!
  bash ../scripts/usage_guard.sh $PID "../runs/qwen-v9.usage.log" &
  wait $PID; echo "EXIT $DOC $?"
done
