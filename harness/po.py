"""Proof-obligation code shared by both L1/L2 paths (graph: architect_agent/arch_tools/
coding_agent; chain: chain_architect/chain_coder).

    forbidden_words   what model code may never contain (`sorry`, `admit`, `native_decide`, `axiom`)
    *_statement       PO1/PO2/PO3 statements. They are always written by the harness, so a
                      model cannot prove a weaker theorem under the right name
    run_theorems      check several theorems against one prefix in ONE Lean run and say
                      which of them failed (errors attributed by line)
    prove             first proof of a list that Lean accepts for one statement
"""
import re
from typing import List, Optional, Sequence, Tuple

from agents.repair import _trim, parse_errors
from lean_runner import HEADER, check_lean

FORBIDDEN = ("sorry", "admit", "native_decide")
MAX_ERRORS = 3


def forbidden_words(code: str) -> List[str]:
    found = [w for w in FORBIDDEN if re.search(rf"\b{w}\b", code)]
    if re.search(r"^\s*axiom\b", code, re.MULTILINE):
        found.append("axiom")
    return found


def po1_statement(a: str, b: str, name: str = "po1") -> str:
    return f"theorem {name} : Contract.Compatible {a} {b}"


def po2_statement(chain: str, spec: str = "Spec", name: str = "po2") -> str:
    return f"theorem {name} : Contract.Refines ({chain}) {spec}"


def po3_statement(contract: str, impl: str, name: Optional[str] = None) -> str:
    return f"theorem {name or impl + '_ok'} : {contract}.Satisfies {impl}"


def theorem(statement: str, proof: str) -> str:
    """`statement := proof`; a proof without a leading `by` is taken as a tactic block."""
    proof = proof.strip()
    if proof.startswith(":="):
        proof = proof[2:].strip()
    if not re.match(r"by\b", proof):
        proof = "by\n" + "\n".join("  " + ln for ln in proof.splitlines())
    return f"{statement} := {proof}"


def errors_of(output: str, n: int = MAX_ERRORS) -> List[str]:
    errs = parse_errors(output)
    if not errs:
        return [_trim(output.strip())] if output.strip() else []
    return [_trim(e["msg"]) for e in errs[:n]]


def run_theorems(prefix: str, theorems: Sequence[str]) -> List[Tuple[bool, List[str]]]:
    """[(proved, errors)] per theorem, from one Lean run of `prefix` + all theorems.

    An error before the first theorem (the prefix is broken) or a failure without a
    positioned error (e.g. a timeout) fails every theorem: nothing passes by default."""
    if not theorems:
        return []
    r = check_lean(prefix + "\n\n" + "\n\n".join(theorems))
    if r["success"]:
        return [(True, [])] * len(theorems)
    errs = parse_errors(r["error"])
    first = HEADER.count("\n") + prefix.count("\n") + 3
    if not errs or any(e["line"] < first for e in errs):
        return [(False, errors_of(r["error"]))] * len(theorems)
    starts, line = [], first
    for t in theorems:
        starts.append(line)
        line += t.count("\n") + 2
    msgs: List[List[str]] = [[] for _ in theorems]
    for e in errs:
        k = max(i for i, st in enumerate(starts) if e["line"] >= st)
        msgs[k].append(_trim(e["msg"]))
    return [(not m, m[:MAX_ERRORS]) for m in msgs]


def prove(prefix: str, statement: str, proofs: Sequence[str]) -> Tuple[Optional[str], List[str]]:
    """(the first proof Lean accepts, []) or (None, the errors of the first proof)."""
    first_errors: List[str] = []
    for k, p in enumerate(proofs):
        r = check_lean(prefix + "\n\n" + theorem(statement, p))
        if r["success"]:
            return p, []
        if k == 0:
            first_errors = errors_of(r["error"])
    return None, first_errors
