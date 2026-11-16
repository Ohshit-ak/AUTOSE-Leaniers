"""The recorded outputs under runs/ and Requirements/parsed/, loaded once per test session.

The contract and metamorphic suites use real pipeline outputs as their corpus: every chain
repetition that has both `chain_meta.json` and `l1l2.json`, with the L0 run it was built on.
"""
import functools
import json
import re
from pathlib import Path
from typing import Dict, Iterator, List, Tuple

ROOT = Path(__file__).resolve().parent.parent.parent
RUNS = ROOT / "runs"
REQUIREMENTS = ROOT / "Requirements"
CHAIN_RUNS = ["qwen-chain-v4", "qwen-chain-v4-fallback", "qwen-chain-v5-on-v10.1", "qwen-chain-v5",
              "qwen-chain-v5-fallback"]
LATEST_CHAIN, LATEST_L0 = "qwen-chain-v5-fallback", "qwen-v11"


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


@functools.lru_cache(maxsize=None)
def srs_documents() -> Tuple[Path, ...]:
    return tuple(sorted(REQUIREMENTS.glob("*.xml")))


@functools.lru_cache(maxsize=None)
def parsed_documents() -> Tuple[Path, ...]:
    return tuple(sorted((REQUIREMENTS / "parsed").glob("*.json")))


@functools.lru_cache(maxsize=None)
def chain_reps(names: Tuple[str, ...] = tuple(CHAIN_RUNS)) -> Tuple[Path, ...]:
    """Repetition folders of the named chain runs that finished (have l1l2.json)."""
    return tuple(p.parent for name in names for p in sorted(RUNS.glob(f"*/{name}/rep*/l1l2.json"))
                 if (p.parent / "chain_meta.json").exists())


@functools.lru_cache(maxsize=None)
def l0_reps() -> Tuple[Path, ...]:
    return tuple(p.parent for p in sorted(RUNS.glob("*/qwen-v1[01]*/rep*/specs.json")))


@functools.lru_cache(maxsize=None)
def records(rep: Path) -> List[dict]:
    return load(rep / "l1l2.json")


@functools.lru_cache(maxsize=None)
def meta(rep: Path) -> dict:
    return load(rep / "chain_meta.json")


@functools.lru_cache(maxsize=None)
def l0_specs(rep: Path) -> Dict[str, dict]:
    """The L0 results (by id) that the chain repetition `rep` was run on."""
    return {r["id"]: r for r in load(ROOT / meta(rep)["l0_run"] / "specs.json")["results"]}


def all_records(names: Tuple[str, ...] = tuple(CHAIN_RUNS)) -> Iterator[Tuple[Path, dict]]:
    for rep in chain_reps(names):
        for e in records(rep):
            yield rep, e


def lean_path(rep: Path, rid: str) -> Path:
    return rep / "l1l2" / (re.sub(r"[^\w.-]", "_", rid) + ".lean")


@functools.lru_cache(maxsize=None)
def checked_specs(run: str = LATEST_L0) -> Tuple[Tuple[str, str, str], ...]:
    """(run folder, id, Lean code) of every checked L0 spec of the named run (rep1 only)."""
    out = []
    for p in sorted(RUNS.glob(f"*/{run}/rep1/specs.json")):
        out += [(rel(p.parent), r["id"], r["lean_predicate"]) for r in load(p)["results"] if r.get("checked")]
    return tuple(out)


@functools.lru_cache(maxsize=None)
def chain_architectures(run: str = LATEST_CHAIN) -> Tuple[Tuple[str, str, str, str], ...]:
    """(rep, id, spec code, architecture code) of every accepted two-component architecture."""
    out = []
    for rep in chain_reps((run,)):
        specs = l0_specs(rep)
        for e in records(rep):
            l1 = e.get("l1") or {}
            if l1.get("success") and l1.get("mode") == "chain" and e["id"] in specs:
                out.append((rel(rep), e["id"], specs[e["id"]]["lean_predicate"], l1["code"]))
    return tuple(out)


def sample(items, n: int, seed: int = 0) -> list:
    """A deterministic sample of at most `n` items (evenly spread, not random)."""
    items = list(items)
    if len(items) <= n:
        return items
    step = len(items) / n
    return [items[int(k * step + seed) % len(items)] for k in range(n)]
