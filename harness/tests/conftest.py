"""Shared pytest setup for the property / metamorphic / contract suites.

Hypothesis profiles (pick one with HYPOTHESIS_PROFILE=<name>):
    default    derandomized, 100 examples per property: the same run every time
    thorough   1000 examples, random seed: for hunting new counterexamples
    quick      25 examples

Markers (see pytest.ini):
    lean   the test runs Lean (skipped when `lake` is not installed)
    slow   re-checks recorded Lean files or runs many Lean jobs; deselect with -m "not slow"
"""
import os
import shutil
import sys
from pathlib import Path

import pytest
from hypothesis import HealthCheck, settings

HARNESS = Path(__file__).resolve().parent.parent
ROOT = HARNESS.parent
for p in (HARNESS, ROOT / "evaluation"):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

_COMMON = dict(deadline=None, suppress_health_check=[HealthCheck.too_slow, HealthCheck.filter_too_much])
settings.register_profile("default", max_examples=100, derandomize=True, **_COMMON)
settings.register_profile("thorough", max_examples=1000, **_COMMON)
settings.register_profile("quick", max_examples=25, derandomize=True, **_COMMON)
settings.load_profile(os.getenv("HYPOTHESIS_PROFILE", "default"))

HAS_LEAN = shutil.which("lake") is not None


def pytest_collection_modifyitems(config, items):
    if HAS_LEAN:
        return
    skip = pytest.mark.skip(reason="`lake` is not installed")
    for item in items:
        if "lean" in item.keywords:
            item.add_marker(skip)
