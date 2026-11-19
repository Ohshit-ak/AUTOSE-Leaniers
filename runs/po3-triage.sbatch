#!/bin/bash
#SBATCH -p u22
#SBATCH -c 16
#SBATCH --mem=32G
#SBATCH --time=12:00:00
# P1 triage of the stored PO3 failures (Lean only, no GPU, no model): docs/analysis/po3_triage.md
set -u
ROOT=/home2/akshithkandagatla/AUTOSE-Leaniers
cd $ROOT
export CF_LEAN_TIMEOUT=300
python -u evaluation/po3_triage.py "runs/*/qwen-chain-v5" "runs/*/qwen-chain-v5-fallback" \
    -o docs/analysis/po3_triage.md --jobs 14
echo "EXIT triage $?"
