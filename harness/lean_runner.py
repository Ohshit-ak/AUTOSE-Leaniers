"""Run Lean on generated code against the ContractForge framework."""
import json
import os
import re
import subprocess
import tempfile

from config import FRAMEWORK_PATH, LEAN_TIMEOUT

HEADER = "import ContractForge\nopen ContractForge\n\n"
_IMPORT = re.compile(r"^\s*import\s+.*$", re.MULTILINE)
# Lean 4 quotes it with backticks ("declaration uses `sorry`"); older versions used '…'.
_SORRY = re.compile(r"declaration uses [`']sorry[`']")


def build_framework() -> None:
    """Build the framework once so `import ContractForge` resolves."""
    subprocess.run(["lake", "build"], cwd=FRAMEWORK_PATH, check=True, capture_output=True)


def check_lean(code: str) -> dict:
    """Type-check `code` (with the framework imported). Returns success + output/error.

    Model-written `import` lines are dropped since imports must come first and
    the framework import is added here. A `sorry` counts as a failure.
    """
    code = HEADER + _IMPORT.sub("", code)
    with tempfile.NamedTemporaryFile(suffix=".lean", mode="w", encoding="utf-8", delete=False) as f:
        f.write(code)
        filepath = f.name

    try:
        result = subprocess.run(
            ["lake", "env", "lean", filepath],
            capture_output=True, text=True, timeout=LEAN_TIMEOUT, cwd=FRAMEWORK_PATH,
        )
    except subprocess.TimeoutExpired:
        return {"success": False, "error": f"Lean timed out after {LEAN_TIMEOUT}s"}
    finally:
        os.unlink(filepath)

    # Lean prints errors to stdout; stderr is mostly lake noise.
    output = (result.stdout + result.stderr).replace(filepath, "<generated>")
    if result.returncode != 0:
        return {"success": False, "error": output}
    if _SORRY.search(output):
        return {"success": False, "error": "proof incomplete (uses `sorry`)\n" + output}
    return {"success": True, "output": output}


# ---------------------------------------------------------------------------
# Real names in Lean core, for "did you mean" hints when a model invents one.
# ---------------------------------------------------------------------------

NAME_SPACES = ["List", "String", "Char", "Nat", "Int", "Option", "Bool", "Prod", "Array",
               "Decidable", "And", "Or", "Iff", "Not", "Eq", "Function"]
_NAMES_CACHE = FRAMEWORK_PATH / ".lake" / "cf_core_names.json"  # rebuilt with the framework
_NAMES_SCRIPT = """import Lean
import ContractForge
open Lean Meta

#eval show MetaM Unit from do
  let env ← getEnv
  let spaces : List Name := [%s]
  for (n, ci) in env.constants.toList do
    if n.isInternal || isPrivateName n then continue
    let some idx := env.getModuleIdxFor? n | continue
    unless (env.header.moduleNames[idx.toNat]!).getRoot == `Init do continue
    match n, ci with
    | .str p s, .defnInfo _ | .str p s, .opaqueInfo _ | .str p s, .ctorInfo _
    | .str p s, .inductInfo _ =>
        if spaces.contains p && !s.startsWith "_" then IO.println n
    | _, _ => pure ()
"""


def core_names() -> dict:
    """{namespace: [names]} of the definitions Lean core provides, e.g. {"Char": ["isAlpha", ...]}.

    Read from Lean once (about 20 s) and cached next to the framework build.
    """
    if _NAMES_CACHE.exists():
        cached = json.loads(_NAMES_CACHE.read_text(encoding="utf-8"))
        if set(cached) == set(NAME_SPACES):
            return cached
    script = _NAMES_SCRIPT % ", ".join(f"`{n}" for n in NAME_SPACES)
    with tempfile.NamedTemporaryFile(suffix=".lean", mode="w", encoding="utf-8", delete=False) as f:
        f.write(script)
        filepath = f.name
    try:
        result = subprocess.run(["lake", "env", "lean", filepath], capture_output=True,
                                text=True, timeout=300, cwd=FRAMEWORK_PATH)
    finally:
        os.unlink(filepath)
    names = {ns: [] for ns in NAME_SPACES}
    for line in result.stdout.split():
        ns, _, name = line.partition(".")
        if ns in names and name:
            names[ns].append(name)
    if not any(names.values()):
        return names  # don't cache a failed dump
    _NAMES_CACHE.parent.mkdir(parents=True, exist_ok=True)
    _NAMES_CACHE.write_text(json.dumps({k: sorted(v) for k, v in names.items()}), encoding="utf-8")
    return names
