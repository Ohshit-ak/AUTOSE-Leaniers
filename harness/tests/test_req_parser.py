"""Run from harness/:  python -m unittest discover -s tests"""
import os
import subprocess
import sys
import unittest
from pathlib import Path

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))

from req_parser import parse_file, to_json  # noqa: E402

GAMMA_J = HARNESS.parent / "Requirements" / "0000 - gamma j.xml"


class TestReqParser(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.doc = parse_file(GAMMA_J)
        cls.kept = {r["id"]: r for r in cls.doc["requirements"]}
        cls.dropped = {r["id"]: r for r in cls.doc["dropped"]}

    def test_deterministic_across_processes(self):
        # Different hash seeds would expose any set/dict-order dependence.
        outs = []
        for seed in ("0", "12345"):
            env = dict(os.environ, PYTHONHASHSEED=seed)
            outs.append(subprocess.run([sys.executable, "req_parser.py", str(GAMMA_J)],
                                       cwd=HARNESS, env=env, capture_output=True, check=True).stdout)
        self.assertEqual(outs[0], outs[1])
        self.assertEqual(outs[0].decode("utf-8"), to_json(self.doc))

    def test_ids_unique(self):
        ids = [x["id"] for k in ("requirements", "data_dictionary", "use_cases") for x in self.doc[k]]
        self.assertEqual(len(ids), len(set(ids)))

    def test_vague_and_platform_dropped(self):
        self.assertIn("non-normative", self.dropped["5.6/R1"]["reason"])    # easy to use
        self.assertIn("vague", self.dropped["5.2/R1"]["reason"])            # periodic backups
        self.assertIn("platform", self.dropped["OE-1"]["reason"])           # browsers
        self.assertIn("SLA", self.dropped["5.4/R1"]["reason"])              # 99.99% availability
        self.assertIn("vague", self.dropped["5.5/R3"]["reason"])            # "too large"

    def test_performance_kept_with_integer_bound(self):
        r = self.kept["5.1/R4"]                                            # add to cart < 2ms
        self.assertEqual(r["verification"], "lean+python_runtime")
        self.assertEqual(r["runtime_checks"][0]["bound"], 2000)
        self.assertEqual(r["runtime_checks"][0]["comparator"], "<")
        self.assertEqual(self.kept["5.1/R3"]["runtime_checks"][0]["metric"], "throughput")

    def test_data_dictionary(self):
        dd = {d["id"]: d["constraints"] for d in self.doc["data_dictionary"]}
        self.assertEqual(dd["DD-user-id"]["min_length"], 4)
        self.assertEqual(dd["DD-user-id"]["max_length"], 10)
        self.assertEqual(dd["DD-credit-card-no"], {"exact_length": 16, "charset": "numeric"})
        self.assertTrue(dd["DD-order-no"]["unique"])
        self.assertIn("DD-address", self.dropped)

    def test_use_case_drops_ui_steps(self):
        uc = next(u for u in self.doc["use_cases"] if u["id"] == "UC-customer-register-customer")
        texts = [s["text"] for s in uc["basic_scenario"]]
        self.assertIn("System creates a new account for the Customer.", texts)
        self.assertFalse(any("clicks" in t or "displays" in t for t in texts))
        goto = uc["alternative_scenarios"][0]["steps"][-1]["goto"]
        self.assertEqual(goto, {"step": 7, "resolves_to": "end"})


if __name__ == "__main__":
    unittest.main()
