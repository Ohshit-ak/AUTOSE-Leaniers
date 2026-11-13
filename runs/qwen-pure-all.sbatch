#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=24:00:00
# Full pipeline on a list of SRS documents (PURE dataset XMLs in Requirements/):
#   L0 (v10.1, 1 run, seed 42) unless runs/<doc>/qwen-v10.1/rep1 already exists (gamma j and
#   video search keep their frozen L0), then chain L1 + L2 (chain-v4) x3 (seeds 42-44),
#   the same with --fallback-single, and the summary with spread.
# Usage:  sbatch -J cf-pure-N -o runs/qwen-pure-N.log runs/qwen-pure-all.sbatch N "<doc stem>" ["<doc stem>" ...]
# N selects the server port (8090+N), so two jobs placed on one node do not share a server.
# The framework must already be built (`cd framework && lake build`); jobs do not build it,
# so parallel jobs never write .lake at the same time.
set -u
N=$1; shift
module load u22/cuda/12.4
nvidia-smi --query-gpu=name,memory.total --format=csv
ROOT=/home2/akshithkandagatla/AUTOSE-Leaniers
cd $ROOT/harness

export CF_QWEN_PORT=$((8090 + N))
export CF_QWEN_BASE_URL="http://127.0.0.1:$CF_QWEN_PORT/v1"
bash ../scripts/start_qwen_server.sh > ../runs/qwen_server_pure-$N.log 2>&1 & SRV=$!
trap "kill $SRV" EXIT
for i in $(seq 1 120); do curl -sf localhost:$CF_QWEN_PORT/v1/models >/dev/null && break; sleep 2; done

for DOC in "$@"; do
  echo "=== $DOC  $(date -Is)"
  if [ ! -f "$ROOT/runs/$DOC/qwen-v10.1/rep1/specs.json" ]; then
    python -u main.py "../Requirements/$DOC.xml" --until check --model qwen --repeat 1; echo "EXIT L0 $DOC $?"
  fi
  python -u main.py "../Requirements/$DOC.xml" --until chain --model qwen --repeat 3; echo "EXIT chain $DOC $?"
  python -u main.py "../Requirements/$DOC.xml" --until chain --model qwen --repeat 3 \
      --fallback-single --run-name qwen-chain-v4-fallback; echo "EXIT chain-fallback $DOC $?"
  BASE=(); [ -d "$ROOT/runs/$DOC/qwen-chain-v3" ] && BASE=("runs/$DOC/qwen-chain-v3")
  (cd $ROOT && python evaluation/summarize_e2e.py "runs/$DOC/qwen-chain-v4" "runs/$DOC/qwen-chain-v4-fallback" \
      "${BASE[@]}" -o "runs/$DOC/qwen-chain-v4/summary.md"); echo "EXIT summary $DOC $?"
  echo "=== done $DOC  $(date -Is)"
done
