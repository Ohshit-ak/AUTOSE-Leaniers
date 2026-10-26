"""Run Lean on generated code against the ContractForge framework."""
import os
import re
import subprocess
import tempfile

from config import FRAMEWORK_PATH, LEAN_TIMEOUT

HEADER = "import ContractForge\nopen ContractForge\n\n"
_IMPORT = re.compile(r"^\s*import\s+.*$", re.MULTILINE)


def build_framework() -> None:
    """Build the framework once so `import ContractForge` resolves."""
    subprocess.run(["lake", "build"], cwd=FRAMEWORK_PATH, check=True, capture_output=True)


def check_lean(code: str) -> dict:
    """Type-check `code` (with the framework imported). Returns success + output/error.

    Model-written `import` lines are dropped since imports must come first and
    the framework import is added here. A `sorry` counts as a failure.
    """
    code = HEADER + _IMPORT.sub("", code)
    with tempfile.NamedTemporaryFile(suffix=".lean", mode="w", delete=False) as f:
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
    if "declaration uses 'sorry'" in output:
        return {"success": False, "error": "proof incomplete (uses `sorry`)\n" + output}
    return {"success": True, "output": output}
