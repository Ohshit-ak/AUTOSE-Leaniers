#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH -J cf-l05loop-gj
#SBATCH -o /home2/akshithkandagatla/AUTOSE-Leaniers/runs/qwen-l05loop-gammaj.log
# gamma j only: L0 (v10.1 prompt, seed 42) + L0.5 with --on-l0-fail loop (CF_L05_ROUNDS, default 2),
# into a NEW folder (qwen-v10.1-l05loop) so the frozen qwen-v10.1 L0 is untouched.
# Then chain L1 + L2 (chain-v4) x3 on that L0, and a summary against the frozen-L0 chain-v4 run.
set -u
module load u22/cuda/12.4
nvidia-smi --query-gpu=name,memory.total --format=csv
ROOT=/home2/akshithkandagatla/AUTOSE-Leaniers
DOC="0000 - gamma j"
cd $ROOT/framework && lake build
cd $ROOT/harness

export CF_QWEN_PORT=8099
export CF_QWEN_BASE_URL="http://127.0.0.1:$CF_QWEN_PORT/v1"
bash ../scripts/start_qwen_server.sh > ../runs/qwen_server_l05loop.log 2>&1 & SRV=$!
trap "kill $SRV" EXIT
for i in $(seq 1 120); do curl -sf localhost:$CF_QWEN_PORT/v1/models >/dev/null && break; sleep 2; done

python -u main.py "../Requirements/$DOC.xml" --until check --model qwen --repeat 1 \
    --on-l0-fail loop --run-name qwen-v10.1-l05loop; echo "EXIT L0+loop $?"
python -u main.py "../Requirements/$DOC.xml" --until chain --model qwen --repeat 3 \
    --l0-run "$ROOT/runs/$DOC/qwen-v10.1-l05loop/rep1" --run-name qwen-chain-v4-l05loop; echo "EXIT chain $?"
(cd $ROOT && python evaluation/summarize_e2e.py "runs/$DOC/qwen-chain-v4-l05loop" "runs/$DOC/qwen-chain-v4" \
    -o "runs/$DOC/qwen-chain-v4-l05loop/summary.md"); echo "EXIT summary $?"
