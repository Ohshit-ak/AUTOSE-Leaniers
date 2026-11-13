#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=24:00:00
# v11: the fixes for the failure patterns (docs/failure_patterns.pdf), on a list of SRS documents.
#   1. L0 v11 (spec checks: output-mention / copy-satisfiable fed back; Lean doc lookup in repair
#      feedback; strategy ladder + early stop), 1 run, seed 42, with --on-l0-fail loop
#      -> runs/<doc>/qwen-v11/rep1
#   2. chain-v5 (Mid fields carried by the harness, identity split -> not decomposable,
#      spec-directed skeleton, ladder) x3 on the v11 L0, strict and --fallback-single
#      -> runs/<doc>/qwen-chain-v5, runs/<doc>/qwen-chain-v5-fallback
#   3. ablation: chain-v5 x3 strict on the FROZEN v10.1 L0 (what L1/L2 fixes do alone, on the
#      same specs as chain-v4)   -> runs/<doc>/qwen-chain-v5-on-v10.1
#   4. summaries (mean (min-max)) against chain-v4.
# Usage:  sbatch -J cf-v11-N -o runs/qwen-v11-N.log runs/qwen-v11.sbatch N "<doc stem>" ["<doc stem>" ...]
# N selects the server port (8090+N), so two jobs on one node do not share a server.
# Time: chain-v4 needed ~6 h of model time per pass for all 18 SRS, L0 v10.1 ~5.3 h, so all 18 SRS and
# all passes are ~25 h: split the documents over 4-5 jobs (24 h limit each), as with qwen-pure-all.
# Before submitting: `cd framework && lake build`, then once (writes framework/.lake/cf_core_docs.json
# and cf_core_names.json, so parallel jobs never write .lake at the same time):
#   cd harness && python -c "import lean_docs, lean_runner; lean_docs.index(); lean_runner.core_names()"
set -u
N=$1; shift
module load u22/cuda/12.4
nvidia-smi --query-gpu=name,memory.total --format=csv
ROOT=/home2/akshithkandagatla/AUTOSE-Leaniers
cd $ROOT/harness
export CF_HARNESS_VERSION=v11

export CF_QWEN_PORT=$((8090 + N))
export CF_QWEN_BASE_URL="http://127.0.0.1:$CF_QWEN_PORT/v1"
bash ../scripts/start_qwen_server.sh > ../runs/qwen_server_v11-$N.log 2>&1 & SRV=$!
trap "kill $SRV" EXIT
for i in $(seq 1 120); do curl -sf localhost:$CF_QWEN_PORT/v1/models >/dev/null && break; sleep 2; done

# The doc index must be there (lean_docs.index() returns {} silently if building it fails).
python -c "import lean_docs; n = len(lean_docs.index()); print('lean doc entries:', n); raise SystemExit(n == 0)" \
  || { echo "no Lean doc index (framework/.lake/cf_core_docs.json): build it first, see the header"; exit 1; }

# Most important first, so a timeout loses the ablation, not the headline numbers:
# pass 1 = L0 v11 + chain-v5 strict for every doc, pass 2 = fallback, pass 3 = ablation on v10.1.
for DOC in "$@"; do
  echo "=== strict $DOC  $(date -Is)"
  L0="runs/$DOC/qwen-v11/rep1"
  if [ ! -f "$ROOT/$L0/specs.json" ]; then
    python -u main.py "../Requirements/$DOC.xml" --until check --model qwen --repeat 1 --on-l0-fail loop
    echo "EXIT L0 $DOC $?"
  fi
  python -u main.py "../Requirements/$DOC.xml" --until chain --model qwen --repeat 3 \
      --l0-run "$ROOT/$L0"; echo "EXIT chain $DOC $?"
done
for DOC in "$@"; do
  echo "=== fallback $DOC  $(date -Is)"
  python -u main.py "../Requirements/$DOC.xml" --until chain --model qwen --repeat 3 \
      --l0-run "$ROOT/runs/$DOC/qwen-v11/rep1" --fallback-single --run-name qwen-chain-v5-fallback
  echo "EXIT chain-fallback $DOC $?"
done
for DOC in "$@"; do
  echo "=== ablation $DOC  $(date -Is)"
  python -u main.py "../Requirements/$DOC.xml" --until chain --model qwen --repeat 3 \
      --l0-run "$ROOT/runs/$DOC/qwen-v10.1/rep1" --run-name qwen-chain-v5-on-v10.1
  echo "EXIT chain-ablation $DOC $?"
done
for DOC in "$@"; do
  RUNS=(); for R in qwen-chain-v5 qwen-chain-v5-fallback qwen-chain-v5-on-v10.1 qwen-chain-v4; do
    [ -d "$ROOT/runs/$DOC/$R" ] && RUNS+=("runs/$DOC/$R"); done
  (cd $ROOT && python evaluation/summarize_e2e.py "${RUNS[@]}" -o "runs/$DOC/qwen-chain-v5/summary.md")
  echo "EXIT summary $DOC $?"
done
echo "=== all done  $(date -Is)"
