#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=00:30:00
#SBATCH -J cf-negdiag
#SBATCH -o /home2/akshithkandagatla/AUTOSE-Leaniers/runs/negdiag/negdiag.log
module load u22/cuda/12.4
cd /home2/akshithkandagatla/AUTOSE-Leaniers
bash scripts/start_qwen_server.sh > /home2/akshithkandagatla/AUTOSE-Leaniers/runs/negdiag/server.log 2>&1 &
until curl -s 127.0.0.1:8082/health | grep -q ok; do sleep 2; done
python -u /home2/akshithkandagatla/AUTOSE-Leaniers/runs/negdiag/negdiag.py
kill %1
