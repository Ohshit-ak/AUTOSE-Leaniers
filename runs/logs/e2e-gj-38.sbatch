#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=3:00:00
#SBATCH -J cf-e2e-g38
#SBATCH -o /home2/akshithkandagatla/AUTOSE-Leaniers/runs/logs/e2e-gj-38.log
module load u22/cuda/12.4
export CF_QWEN_PORT=8088 CF_QWEN_BASE_URL=http://127.0.0.1:8088/v1
cd /home2/akshithkandagatla/AUTOSE-Leaniers/harness
bash ../scripts/start_qwen_server.sh > /home2/akshithkandagatla/AUTOSE-Leaniers/runs/logs/e2e-gj-38-server.log 2>&1 & SRV=$!
trap "kill $SRV" EXIT
for i in $(seq 120); do curl -sf localhost:8088/v1/models >/dev/null && break; sleep 2; done; echo "server up after $((i*2))s"
python -u e2e_l1l2.py "../runs/0000 - gamma j/qwen-e2e-v2" --model qwen --start 38 --end 49; echo "EXIT $?"
