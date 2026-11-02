"""Run from harness/:  python -m unittest discover -s tests

v9: parser keeps filter/sort/limit requirements and drops scope prose without a
quantity; L0.5 checks each vacuity mutant separately, rejects `Nat ≥ 0`, and
fails a spec whose negative check found a forbidden output it accepts."""
import shutil
import sys
import unittest
from pathlib import Path

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))

import req_parser  # noqa: E402
import validate  # noqa: E402

HAS_LEAN = shutil.which("lake") is not None
TEMPLATE = (Path(__file__).parent / "search_template.lean").read_text(encoding="utf-8")


def _doc(sections: str) -> bytes:
    return f"<srs><title><t>T</t></title>{sections}</srs>".encode()


def _sec(sid: str, title: str, body: str) -> str:
    return f'<p id="{sid}"><title>{title}</title><text_body>{body}</text_body></p>'


class ParserV9(unittest.TestCase):
    def parse(self, *secs):
        d = req_parser.parse_bytes(_doc("".join(secs)), "t.xml")
        return ({r["text"]: r for r in d["requirements"]}, {r["text"]: r for r in d["dropped"]})

    def test_filter_sort_limit_are_kept(self):
        texts = ["Any torrent result with 0 seeds will not be displayed.",
                 "Results will be arranged in size/date/alphabetical order.",
                 "A results page will display 100 results."]
        kept, _ = self.parse(_sec("3.1", "Functional Requirements", " ".join(texts)))
        for t in texts:
            self.assertIn(t, kept)
        self.assertEqual(kept[texts[2]]["quantities"][0]["value"], 100)

    def test_scope_prose_dropped_unless_quantified(self):
        vague = "The system will contain databases of the websites used in the search."
        counted = "The initial inventory will be 100 items."
        kept, dropped = self.parse(_sec("1.3", "Project Scope", f"{vague} {counted}"))
        self.assertIn(counted, kept)
        self.assertIn("overview section", dropped[vague]["reason"])


class TrivialBounds(unittest.TestCase):
    def test_nat_ge_zero_is_a_problem(self):
        code = ("structure Input where\n  q : String\n  deriving DecidableEq, Repr\n"
                "structure Output where\n  seeds : Nat\n  link : String\n  deriving DecidableEq, Repr\n"
                "def Spec : Contract Input Output where\n  pre := fun _ => True\n"
                "  post := fun i o => o.seeds ≥ 0 ∧ o.link ≠ \"\"\n"
                "example : Spec.pre { q := \"a\" } ∧ Spec.post { q := \"a\" } { seeds := 1, link := \"x\" } := by\n"
                "  unfold Spec; decide\n")
        self.assertEqual(validate.trivial_nat_bounds(code), ["o.seeds"])
        self.assertTrue(any("always true" in p for p in validate.check_housekeeping(code)))

    def test_template_has_no_trivial_bound(self):
        self.assertEqual(validate.trivial_nat_bounds(TEMPLATE), [])


class ReviewNegative(unittest.TestCase):
    def test_accepts_forbidden_output_fails(self):
        v = validate.review(TEMPLATE, True, {"kind": "requirement"}, False, "{ results := [] }")
        self.assertEqual(v["status"], "fail")
        self.assertTrue(any("forbids" in p for p in v["problems"]))


@unittest.skipUnless(HAS_LEAN, "lake not on PATH")
class VacuityPerMutant(unittest.TestCase):
    def test_many_mutants_not_reported_vacuous(self):
        # A single ¬(post m1 ∧ post m2 ∧ post m3) here fails Decidable synthesis.
        self.assertEqual(validate.check_vacuity(TEMPLATE), ([], []))


if __name__ == "__main__":
    unittest.main()
