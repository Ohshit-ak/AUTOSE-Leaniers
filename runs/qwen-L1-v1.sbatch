#!/bin/bash
#SBATCH -p u22
#SBATCH --gres=gpu:1
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH -J cf-L1-v1
#SBATCH -o /home2/akshithkandagatla/AUTOSE-Leaniers/runs/qwen-L1-v1.log
# L1 v1 on gamma j: graph, then L1 with the graph x3 and --no-graph x3 (seeds 42-44),
# pipeline mode; one agent-mode run only if the tool-calling smoke test passes.
# L0 is frozen: everything reads runs/0000 - gamma j/qwen-v10.1/rep1.
set -u
module load u22/cuda/12.4
nvidia-smi --query-gpu=name,memory.total --format=csv
ROOT=/home2/akshithkandagatla/AUTOSE-Leaniers
cd $ROOT/harness
DOC="../Requirements/0000 - gamma j.xml"

# spaCy for req_graph.py (once; the graph records the versions it used)
python -c "import spacy; spacy.load('en_core_web_sm')" 2>/dev/null || {
  python -m pip install --user -q spacy && python -m spacy download en_core_web_sm; }

# One server for the whole job, with --jinja so tool calls can be parsed (main.py reuses it).
CF_QWEN_JINJA=1 bash ../scripts/start_qwen_server.sh > ../runs/qwen_server_L1.log 2>&1 & SRV=$!
trap "kill $SRV" EXIT
for i in $(seq 1 120); do curl -s localhost:8082/v1/models >/dev/null && break; sleep 2; done

python -u main.py "$DOC" --until graph; echo "EXIT graph $?"

# Tool-calling smoke test: does Qwen return a well-formed call?
python - <<'EOF' > ../runs/qwen-L1-v1.toolsmoke.txt 2>&1
import json
from llm import call_llm_tools
tools = [{"type": "function", "function": {"name": "get_component", "description": "Look up a component",
          "parameters": {"type": "object", "properties": {"component": {"type": "string"}}, "required": ["component"]}}}]
r = call_llm_tools([{"role": "user", "content": "Call get_component for component Account."}], tools, "qwen")
ok = bool(r["tool_calls"]) and json.loads(r["tool_calls"][0]["arguments"]).get("component") == "Account"
print("TOOLSMOKE", "PASS" if ok else "FAIL", json.dumps(r))
EOF
cat ../runs/qwen-L1-v1.toolsmoke.txt

python -u main.py "$DOC" --until arch --model qwen --repeat 3; echo "EXIT graph-mode $?"
python -u main.py "$DOC" --until arch --model qwen --repeat 3 --no-graph; echo "EXIT no-graph $?"
cd $ROOT && python evaluation/compare_runs.py "runs/0000 - gamma j/qwen-L1-v1-nograph" \
    "runs/0000 - gamma j/qwen-L1-v1" -o "runs/0000 - gamma j/qwen-L1-v1/comparison.md"; cd harness

if grep -q "TOOLSMOKE PASS" ../runs/qwen-L1-v1.toolsmoke.txt; then
  python -u main.py "$DOC" --until arch --model qwen --arch-mode agent --run-name qwen-L1-v1-agent
  echo "EXIT agent $?"
fi
# If Qwen proves no PO2, run Gemma once by hand (API key in .env, slow):
#   python main.py "$DOC" --until arch --model gemma --run-name gemma-L1-v1
