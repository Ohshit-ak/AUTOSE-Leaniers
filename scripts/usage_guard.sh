#!/usr/bin/env bash
# Stop a pipeline run if GPU memory or the job's RAM goes above a limit (default 75%).
# GPU utilization is not checked: inference keeps it near 100% while generating.
#
#   python main.py ... & bash scripts/usage_guard.sh $! [log] [limit]
#
# On a breach it sends Ctrl-C to main.py (specs.json is saved after every entry, so
# --resume continues), then stops this user's llama-server.
PID=$1; LOG=${2:-/dev/stdout}; LIMIT=${3:-75}
MEM_MB=${SLURM_MEM_PER_NODE:-16384}
peak_g=0; peak_r=0
while kill -0 "$PID" 2>/dev/null; do
  read used total < <(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | head -1 | tr -d ',')
  g=$(( used * 100 / total ))
  rss_kb=$(ps -u "$USER" -o rss= | awk '{s+=$1} END {print s+0}')
  r=$(( rss_kb / 1024 * 100 / MEM_MB ))
  (( g > peak_g )) && peak_g=$g; (( r > peak_r )) && peak_r=$r
  if (( g > LIMIT || r > LIMIT )); then
    echo "$(date +%T) STOP: gpu_mem=${g}% ram=${r}% (limit ${LIMIT}%)" >> "$LOG"
    kill -INT "$PID"; sleep 10; kill -0 "$PID" 2>/dev/null && kill "$PID"
    pkill -u "$USER" -f llama-server
    exit 1
  fi
  sleep 5
done
echo "$(date +%T) run ended; peak gpu_mem=${peak_g}% ram=${peak_r}%" >> "$LOG"
