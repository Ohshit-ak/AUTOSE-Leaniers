"""Run from harness/:  python -m unittest discover -s tests

`--on-l0-fail loop`: L0.5 failures are regenerated with the reasons fed back, a new spec
is kept only if its L0.5 status improves, and what still fails is excluded."""
import argparse
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))

import main  # noqa: E402
import validate  # noqa: E402


def _result(i, code, status, error=None):
    r = {"id": i, "lean_predicate": code, "checked": status == "pass", "compiles": True,
         "l05": {"status": status, "problems": [] if status != "fail" else ["`post` is vacuous"],
                 "flags": []}}
    if error:
        r["error"] = error
    return r


def _fake_review_run(specs, entries):
    """Status from the code: GOOD → pass, FLAG → flag, anything else → fail."""
    counts = {"pass": 0, "flag": 0, "fail": 0}
    for r in specs["results"]:
        s = "pass" if "GOOD" in r["lean_predicate"] else "flag" if "FLAG" in r["lean_predicate"] else "fail"
        r["l05"] = {"status": s, "problems": ["`post` is vacuous"] if s == "fail" else [], "flags": []}
        counts[s] += 1
    specs["l05_summary"] = counts
    return counts


class Feedback(unittest.TestCase):
    def test_reasons_and_code_in_feedback(self):
        fb = main.l05_feedback(_result("a", "def Spec := 1", "fail"))
        self.assertIn("`post` is vacuous", fb)
        self.assertIn("def Spec := 1", fb)

    def test_compile_error_included(self):
        r = _result("a", "bad", "fail", error="unknown identifier 'foo'")
        r["l05"]["problems"] = ["does not compile"]
        self.assertIn("unknown identifier 'foo'", main.l05_feedback(r))

    def test_keep_better(self):
        old, flag, fail = _result("a", "x", "fail"), _result("a", "y", "flag"), _result("a", "z", "fail")
        self.assertIs(main.keep_better(old, flag), flag)
        self.assertIs(main.keep_better(old, fail), old)


class Loop(unittest.TestCase):
    def test_loop_keeps_improvements_and_restores_regressions(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)
            (out / "lean").mkdir()
            specs = {"results": [_result("ok", "GOOD", "pass"), _result("fixed", "BAD1", "fail"),
                                 _result("stuck", "BAD2", "fail")]}
            (out / "specs.json").write_text(json.dumps(specs))
            (out / "lean" / "stuck.lean").write_text("old stuck")
            seen = []

            def fake_stage_spec(doc, stem, args):
                seen.append((sorted(args.only), dict(args._feedback)))
                s = json.loads((out / "specs.json").read_text())
                for r in s["results"]:
                    if r["id"] not in args.only:
                        continue
                    if r["id"] == "fixed":
                        r.update(lean_predicate="FLAG", l05_feedback=args._feedback["fixed"])
                        r.pop("l05")
                    elif r["id"] == "stuck":
                        r.update(lean_predicate="STILL BAD")
                        r.pop("l05")
                        (out / "lean" / "stuck.lean").write_text("new stuck")
                (out / "specs.json").write_text(json.dumps(s))

            args = argparse.Namespace(model="qwen", only=None, resume=False, kinds=None, limit=None)
            with mock.patch.object(main, "run_dir", return_value=out), \
                 mock.patch.object(main, "stage_spec", fake_stage_spec), \
                 mock.patch.object(validate, "review_run", _fake_review_run), \
                 mock.patch.object(validate, "write_report", lambda s, o: o), \
                 mock.patch.dict(os.environ, {"CF_L05_ROUNDS": "2"}):
                counts = main._l05_loop({}, "doc", args, {})

            self.assertEqual(counts, {"pass": 1, "flag": 1, "fail": 1})
            self.assertEqual(seen[0][0], ["fixed", "stuck"])
            self.assertIn("BAD1", seen[0][1]["fixed"])          # old code fed back
            self.assertEqual(seen[1][0], ["stuck"])               # round 2 only retries what still fails
            res = {r["id"]: r for r in json.loads((out / "specs.json").read_text())["results"]}
            self.assertEqual(res["fixed"]["lean_predicate"], "FLAG")
            self.assertEqual(res["stuck"]["lean_predicate"], "BAD2")  # no improvement: old kept
            self.assertEqual(res["stuck"]["l05_rounds"], 2)
            self.assertEqual((out / "lean" / "stuck.lean").read_text(), "old stuck")


if __name__ == "__main__":
    unittest.main()
