"""Harness-side proof search for L1/L2 proof obligations (no model).

When the definitions compile and only the PO theorems fail, try a fixed list of
generic tactic scripts on each theorem before asking the model again.
"""
import re
from typing import Optional

from lean_runner import check_lean

_THEOREM = re.compile(r"^theorem\s+(\w+)\s*:(.*?):=\s*by\b", re.M | re.S)
_DEF_NAME = re.compile(r"^def\s+(\w+)", re.M)
_NEXT_TOP = re.compile(r"^\S", re.M)


def _scripts(names: str) -> list:
    """Candidate proofs; `names` are the user definitions to unfold (comma separated)."""
    u = f"unfold Contract.Compatible Contract.Refines Contract.seq Contract.Satisfies at *; " \
        f"unfold {names.replace(',', '')} at *"
    return [
        f"discharge_po [{names}]",
        f"(try {u}); intros; simp_all",
        f"(try {u}); refine ⟨?_, ?_⟩ <;> intros <;> simp_all",
        f"(try {u}); refine ⟨?_, ?_⟩ <;> intros <;> grind",
        f"(try {u}); intros; grind",
        f"(try {u}); intros; omega",
        f"(try {u}); refine ⟨?_, ?_⟩ <;> intros <;> omega",
    ]


def auto_prove(code: str, context: str) -> Optional[str]:
    """`code` with every PO theorem re-proved by a generic script, or None if some can't be."""
    names = sorted(set(_DEF_NAME.findall(code)) | set(_DEF_NAME.findall(context)))
    names = ", ".join(n for n in names if not n.startswith("_"))
    if not names:
        return None
    thms = list(_THEOREM.finditer(code))
    if not thms:
        return None
    head = code[:thms[0].start()].rstrip()
    proved = []
    for m in thms:
        stmt = f"theorem {m.group(1)} :{m.group(2)}:= by"
        for s in _scripts(names):
            attempt = f"{head}\n\n{stmt}\n  {s}"
            if check_lean(f"{context}\n\n{attempt}")["success"]:
                proved.append(f"{stmt}\n  {s}")
                break
        else:
            return None
    return head + "\n\n" + "\n\n".join(proved)
