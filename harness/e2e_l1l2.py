"""Chain L1 + L2 over the accepted L0 specs of one run folder (older CLI; `main.py --until chain`
is the main entry point and adds repetitions).

Usage (from harness/): python e2e_l1l2.py <run_dir> [--model qwen] [--limit N] [--start A --end B]
Reads <run_dir>/specs.json and review.json; writes <run_dir>/l1l2[.A-B].json (rewritten after every
entry) and <run_dir>/l1l2/<id>.lean, or the same under --out. --start/--end split a run into
shards for parallel jobs; evaluation/summarize_e2e.py merges them.
"""
import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))
import chain_pipeline


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("run_dir")
    ap.add_argument("--model", default="qwen")
    ap.add_argument("--out", help="output folder (default: run_dir)")
    ap.add_argument("--limit", type=int)
    ap.add_argument("--only", nargs="+", metavar="ID")
    ap.add_argument("--start", type=int, default=0, help="first entry index (for sharding)")
    ap.add_argument("--end", type=int, help="one past the last entry index (for sharding)")
    ap.add_argument("--split", choices=["auto", "always", "never"], default="auto")
    ap.add_argument("--fallback-single", action="store_true")
    ap.add_argument("--resume", action="store_true")
    ap.add_argument("--seed", type=int)
    a = ap.parse_args()
    if a.model == "qwen":
        from main import ensure_qwen_server
        ensure_qwen_server()
    if a.seed is not None:
        from llm import set_seed
        set_seed(a.seed)
    run = Path(a.run_dir)
    chain_pipeline.run(run, Path(a.out) if a.out else run, a.model, split=a.split,
                       fallback_single=a.fallback_single, only=a.only, limit=a.limit,
                       start=a.start, end=a.end, resume=a.resume)
    print("[chain] done", flush=True)


if __name__ == "__main__":
    main()
