#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH -J cf-chain-v3
#SBATCH -o /home2/akshithkandagatla/AUTOSE-Leaniers/runs/qwen-chain-v3.log
# Chain L1 + L2 (chain-v3) on both SRSs, 3 repetitions each (seeds 42-44), then the summary
# with spread. L0 is frozen: gamma j reads runs/0000 - gamma j/qwen-v10.1/rep1, video search
# reads runs/2009 - video search/qwen-v10.1/rep1.
# A second pass with --fallback-single gives the "every accepted spec gets verified code" number;
# it is a separate run folder so the two are never mixed.
set -u
module load u22/cuda/12.4
nvidia-smi --query-gpu=name,memory.total --format=csv
ROOT=/home2/akshithkandagatla/AUTOSE-Leaniers
cd $ROOT/framework && lake build      # Tactics.lean changed (discharge_po1/2/3)
cd $ROOT/harness

bash ../scripts/start_qwen_server.sh > ../runs/qwen_server_chain.log 2>&1 & SRV=$!
trap "kill $SRV" EXIT
for i in $(seq 1 120); do curl -sf localhost:8082/v1/models >/dev/null && break; sleep 2; done

for DOC in "0000 - gamma j" "2009 - video search"; do
  python -u main.py "../Requirements/$DOC.xml" --until chain --model qwen --repeat 3; echo "EXIT chain $DOC $?"
  python -u main.py "../Requirements/$DOC.xml" --until chain --model qwen --repeat 3 \
      --fallback-single --run-name qwen-chain-v3-fallback; echo "EXIT chain-fallback $DOC $?"
  (cd $ROOT && python evaluation/summarize_e2e.py "runs/$DOC/qwen-chain-v3" "runs/$DOC/qwen-chain-v3-fallback" \
      "runs/$DOC/qwen-e2e-v2" -o "runs/$DOC/qwen-chain-v3/summary.md")
done
