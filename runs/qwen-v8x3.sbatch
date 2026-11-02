#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH -J cf-v8x3
#SBATCH -o /home2/akshithkandagatla/AUTOSE-Leaniers/runs/qwen-v8x3.log
# Baseline: the v8 code (commit 6fedcde) on gamma j, 3 repetitions. v8 sends no seed, so the
# server is restarted with --seed 42, 43, 44 (what v10 sends per repetition).
module load u22/cuda/12.4
nvidia-smi --query-gpu=name,memory.total --format=csv
WT=/tmp/cf-v8-$SLURM_JOB_ID
git -C /home2/akshithkandagatla/AUTOSE-Leaniers worktree add -f $WT 6fedcde
ln -s /home2/akshithkandagatla/AUTOSE-Leaniers/framework/.lake $WT/framework/.lake
OUT="/home2/akshithkandagatla/AUTOSE-Leaniers/runs/0000 - gamma j/qwen-v8x3"
for K in 1 2 3; do
  SEED=$((41 + K))
  $HOME/build/llama.cpp/build-cuda/bin/llama-server -m $HOME/llm-models/qwen2.5-7b-instruct/qwen2.5-7b-instruct-q4_k_m-00001-of-00002.gguf \
    --alias qwen2.5-7b-instruct --host 127.0.0.1 --port 8082 -c 16384 -ngl 99 --seed $SEED > /home2/akshithkandagatla/AUTOSE-Leaniers/runs/qwen-v8x3.server.log 2>&1 & SRV=$!
  until curl -s 127.0.0.1:8082/v1/models >/dev/null; do sleep 2; done
  cd $WT/harness
  python -u main.py "../Requirements/0000 - gamma j.xml" --model qwen --run-name "qwen-v8x3/rep$K" & PID=$!
  bash /home2/akshithkandagatla/AUTOSE-Leaniers/scripts/usage_guard.sh $PID /home2/akshithkandagatla/AUTOSE-Leaniers/runs/qwen-v8x3.usage.log &
  wait $PID; echo "EXIT rep$K seed $SEED $?"
  kill $SRV; wait $SRV 2>/dev/null
  mkdir -p "$OUT"; rm -rf "$OUT/rep$K"; cp -r "$WT/runs/0000 - gamma j/qwen-v8x3/rep$K" "$OUT/"
done
rm $WT/framework/.lake; git -C /home2/akshithkandagatla/AUTOSE-Leaniers worktree remove --force $WT
