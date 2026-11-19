"""P8: compare the generated L0 specs of gamma j with the hand-written gold specs
(benchmark/gammaj/GammaJ_L0.lean, 25 `Spec_<id>`). No model.

Classes, in contract terms (gen = generated spec, gold = gold spec):

    equivalent  same `pre` and the same `post` under it
    stronger    gen refines gold: gold.pre → gen.pre, and under gold.pre gen.post → gold.post
                (gen accepts fewer implementations)
    weaker      gold refines gen
    different   neither
    missing     no accepted generated spec for the gold entry

Method per row:

    lean-proved       Lean proves `∀ s b, (gold.pre s ↔ gen.pre {f := s}) ∧ (gold.post s b ↔
                      gen.post {f := s} {g := b})` (validator pairs: gold `Contract String Bool`,
                      gen with one `String` input field and one `Bool` output field)
    lean-tested (N)   the same pairs, evaluated by Lean (`#eval decide …`) on N generated strings
                      (lengths around every bound, letters / digits / spaces / '@' / '/', the
                      MM/YY and MM/DD/YYYY shapes). Agreement on all N is evidence, not proof.
                      Three gold predicates have an `∃` and no `Decidable` instance
                      (ValidEmail, ValidExpiry, ValidShipDate); for them the gold side is a
                      Python transcription of the Lean definition (marked `gold via Python`)
    manual            the types differ (tuples / lists of records vs generated structures), so
                      the row was classified by reading both specs. These rows were written by
                      Claude (a closed model) and need a human check before they are reported.

python evaluation/p8_gold_compare.py [-o docs/analysis/p8_gold.md]
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "harness"))

import chain_checks as C  # noqa: E402
from lean_runner import check_lean  # noqa: E402
from validate import code_defs_only, field_types  # noqa: E402

GOLD = ROOT / "benchmark" / "gammaj" / "GammaJ_L0.lean"
RUN = ROOT / "runs" / "0000 - gamma j" / "qwen-v11" / "rep1"

# gold name → generated id (same requirement). The gold names are not parser ids.
GOLD_TO_ID = {
    "DD_user_id": "DD-user-id", "DD_password": "DD-password", "DD_item_name": "DD-item-name",
    "DD_item_id": "DD-item-id", "DD_text_description": "DD-text-description",
    "DD_quantity": "DD-quantity", "DD_name": "DD-name", "DD_city": "DD-city", "DD_state": "DD-state",
    "DD_zip_code": "DD-zip-code", "DD_email": "DD-e-mail-id", "DD_credit_card_no": "DD-credit-card-no",
    "DD_credit_card_expiry": "DD-credit-card-expiry-date", "DD_order_no": "DD-order-no",
    "DD_tracking_no": "DD-tracking-no", "DD_shipping_date": "DD-shipping-date",
    "FR_cart_display": "3.3.3/S2", "FR_cart_add": "3.3.3/S1", "FR_cart_remove": "3.3.3/S3",
    "UC_register": "UC-customer-register-customer", "UC_login": "UC-customer-login-customer",
    "UC_logout": "UC-customer-logout-customer", "UC_checkout": "UC-customer-checkout-an-order",
    "BR_out_of_stock": None, "NFR_failed_logins": "5.3/R5",
}

# Rows whose types differ: classified by reading both specs (Claude; needs a human check).
MANUAL = {
    "DD_quantity": ("different", "gold computes the quantity used (`q = req.getD 1`: default 1, pre 1 ≤ q ≤ stock); "
                    "gen only validates `1 ≤ value ≤ max_ref`: the default = 1 rule is missing"),
    "FR_cart_display": ("weaker", "same two sums (item count = Σ qty, total = Σ qty·price); gen adds `pre: items.Nodup`, "
                        "so it says nothing for carts with repeated lines"),
    "FR_cart_add": ("different", "gen: cart length + 1 and contains the product; it allows other lines to be dropped or "
                    "replaced (gold: every other product's quantity unchanged) and has no quantity / stock bound; gold "
                    "allows merging into an existing line (length unchanged), which gen forbids"),
    "FR_cart_remove": ("different", "gen not accepted (L0.5 fail, does not compile: `(i.added.getD 0).length`); it also "
                       "adds and removes in one step and never says the removed product is gone"),
    "UC_register": ("weaker", "gen has no account store: `registered = true` always and a cookie iff the e-mail is "
                    "non-empty; gold adds the account, keeps all others and requires a unique valid e-mail. Every "
                    "gold-correct implementation can be mapped to one gen accepts, not the reverse (weak spec)"),
    "UC_login": ("different", "gen succeeds iff the input equals the hard-coded strings \"registeredUsername\" / "
                 "\"registeredPassword\" / \"registeredEmail\" (no account list); gold: iff a registered account "
                 "matches. Ungrounded constants (see p8_grounding)"),
    "UC_logout": ("equivalent", "pre: logged in (gen `signedIn = true`, gold `session.isSome`); post: logged out "
                  "(gen `signedIn = false`, gold `session = none`). Equivalent up to Bool flag vs Option e-mail"),
    "UC_checkout": ("different", "gen not accepted (L0.5 fail); it fixes `order = \"Order confirmed\"`, copies the cart "
                    "and sets flags to true; no total, no recipient. Gold: order lines = cart, total = cost, "
                    "confirmation to the session e-mail"),
    "BR_out_of_stock": ("missing", "glossary business rule; the parser has no entry for it, so there is no generated spec"),
    "NFR_failed_logins": ("different", "gold: flagged iff the last k attempts all failed (k is a parameter: the SRS gives "
                          "no threshold). gen: a login acceptance spec with an invented threshold 3, and its last conjunct "
                          "`a.failedAttempts = a.failedAttempts + (if accepted then 0 else 1)` forces "
                          "`accepted = true` whenever an account is returned"),
}

# Python transcriptions of the three gold validators that Lean cannot `decide` (an ∃).
def _alnum_dot(c):
    return c.isascii() and (c.isalnum() or c == ".")


def _dig(cs):
    return all(c.isascii() and c.isdigit() for c in cs)


def py_valid_email(s):
    cs = list(s)
    if len(cs) > 50 or cs.count("@") < 1:
        return False
    for k, c in enumerate(cs):          # ∃ l d, s = l ++ '@' :: d with l, d non-empty and EmailChar
        if c == "@":
            left, right = cs[:k], cs[k + 1:]
            if left and right and all(map(_alnum_dot, left)) and all(map(_alnum_dot, right)):
                return True
    return False


def py_valid_expiry(s):
    cs = list(s)
    if len(cs) != 5 or cs[2] != "/" or not _dig(cs[:2] + cs[3:]):
        return False
    m = int(cs[0]) * 10 + int(cs[1])
    return 1 <= m <= 12


def py_valid_ship_date(s):
    cs = list(s)
    if len(cs) != 10 or cs[2] != "/" or cs[5] != "/" or not _dig(cs[:2] + cs[3:5] + cs[6:]):
        return False
    m, d = int(cs[0]) * 10 + int(cs[1]), int(cs[3]) * 10 + int(cs[4])
    return 1 <= m <= 12 and 1 <= d <= 31


PY_GOLD = {"ValidEmail": py_valid_email, "ValidExpiry": py_valid_expiry, "ValidShipDate": py_valid_ship_date}


def samples():
    lens = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15, 16, 17, 19, 20, 21, 49, 50, 51, 99, 100, 101]
    pats = ["a", "1", "a1", "ab c", "A", "a-b"]
    out = []
    for n in lens:
        for p in pats:
            out.append((p * (n // len(p) + 1))[:n])
    out += ["1234", "abcd", "ab12", "a@b.in", "x@y", "@b.in", "a@", "ab@cd@ef", "a.b@c.d",
            "x" * 46 + "@b.in", "x" * 47 + "@b.in", "09/27", "13/27", "00/27", "12/99", "9/27x", "ab/cd",
            "0927/", "10/31/2026", "13/31/2026", "10/32/2026", "00/10/2026", "1/31/2026x", "10-31-2026",
            "1234567890", "12/34/5678"]
    return list(dict.fromkeys(out))


def lean_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def gold_parts():
    text = GOLD.read_text(encoding="utf-8")
    body = re.sub(r"^\s*(import|open)\b.*$", "", text, flags=re.MULTILINE)
    validators = dict(re.findall(r"def Spec_(\w+) : Contract String Bool := validator (\w+)", text))
    names = re.findall(r"def Spec_(\w+)", text)
    return body, validators, names


def gen_adapter(code):
    """(string input field, Bool output field, Contract) for a validator-shaped generated spec."""
    defs = code_defs_only(code)
    f = field_types(defs)
    s = C.spec_contract(defs)
    if s is None:
        return None
    strs = [k for k, t in f.get("Input", {}).items() if t.split("--")[0].split(":=")[0].strip() == "String"]
    bools = [k for k, t in f.get("Output", {}).items() if t.strip() == "Bool"]
    if len(strs) != 1 or len(f.get("Output", {})) != 1 or len(bools) != 1:
        return None
    return strs[0], bools[0], s, defs


def classify(rows):
    """rows = [(goldPost(true) i.e. V(s), genPre, genPost(true), genPost(false))]; gold pre = True."""
    def gold_post(v, b):
        return b == v
    stronger = all(gp for _, gp, _, _ in rows) and all(
        not gen or gold_post(v, b) for v, _, pt, pf in rows for b, gen in ((True, pt), (False, pf)))
    weaker = all(
        not gp or (not gold_post(v, b) or gen) for v, gp, pt, pf in rows for b, gen in ((True, pt), (False, pf)))
    if stronger and weaker:
        return "equivalent"
    return "stronger" if stronger else "weaker" if weaker else "different"


def witness(ss, rows):
    for s, (v, gp, pt, pf) in zip(ss, rows):
        gen_ok = [b for b, x in ((True, pt), (False, pf)) if x]
        if not gp:
            return f"{lean_str(s)}: outside gen `pre` (gold accepts it, valid = {str(v).lower()})"
        if gen_ok != [v]:
            g = "no output" if not gen_ok else "valid = " + "/".join(str(b).lower() for b in gen_ok)
            return f"{lean_str(s)}: gold valid = {str(v).lower()}, gen allows {g}"
    return ""


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("-o", "--out", default=str(ROOT / "docs" / "analysis" / "p8_gold.md"))
    args = ap.parse_args(argv)
    body, validators, names = gold_parts()
    specs = {r["id"]: r for r in json.loads((RUN / "specs.json").read_text(encoding="utf-8"))["results"]}
    review = json.loads((RUN / "review.json").read_text(encoding="utf-8"))
    ss = samples()
    sample_list = "[" + ", ".join(lean_str(s) for s in ss) + "]"

    pairs, blocks = {}, []
    for k, g in enumerate(names):
        gid = GOLD_TO_ID.get(g)
        r = specs.get(gid) if gid else None
        if g not in validators or r is None or g in MANUAL:
            continue
        ad = gen_adapter(r["lean_predicate"])
        if ad is None:
            continue
        f, b, s, defs = ad
        if not check_lean(defs)["success"]:
            pairs[g] = {"gen_compiles": False}
            continue
        ns = f"Gen{k}"
        pv = s.pre_var if s.pre_var != "_" else "_"
        iv, ov = s.in_var, s.out_var
        v = validators[g]
        gold_eval = f"decide (GammaJ.{v} s)" if v not in PY_GOLD else "true"
        blocks.append(
            f"namespace {ns}\n{defs}\n"
            f"def genPre ({pv} : Input) : Bool := decide ({s.pre})\n"
            f"def genPost ({iv} : Input) ({ov} : Output) : Bool := decide ({s.post})\n"
            f"#eval IO.println (\"ROW {g} \" ++ toString ({sample_list}.map fun (s : String) =>\n"
            f"  ({gold_eval}, genPre {{ {f} := s }}, genPost {{ {f} := s }} {{ {b} := true }}, "
            f"genPost {{ {f} := s }} {{ {b} := false }})))\n"
            f"end {ns}")
        pairs[g] = {"ns": ns, "field": f, "bool": b, "validator": v, "gen_compiles": True}

    out = check_lean(body + "\n\n" + "\n\n".join(blocks))
    text = out.get("output") or out.get("error") or ""
    if not out["success"]:
        print(text[:3000])
        return 1
    for line in text.splitlines():
        m = re.match(r"ROW (\w+) \[(.*)\]$", line.strip())
        if not m:
            continue
        g = m.group(1)
        # Lean prints (a, b, c, d) as (a, (b, (c, d)))
        tuples = re.findall(r"\((true|false), \(?(true|false), \(?(true|false), (true|false)\)", m.group(2))
        rows = [tuple(x == "true" for x in t) for t in tuples]
        v = pairs[g]["validator"]
        if v in PY_GOLD:
            rows = [(PY_GOLD[v](s), *row[1:]) for s, row in zip(ss, rows)]
        pairs[g]["rows"] = rows
        pairs[g]["class"] = classify(rows)
        pairs[g]["witness"] = witness(ss, rows)

    # Lean proofs of equivalence for the pairs that agree on every sample.
    proofs = []
    for g, p in pairs.items():
        if p.get("class") != "equivalent":
            continue
        v, ns, f, b = p["validator"], p["ns"], p["field"], p["bool"]
        unfold = f"GammaJ.Spec_{g}, GammaJ.validator, GammaJ.{v}, GammaJ.AllAlnum, GammaJ.AllDigits, " \
                 f"GammaJ.AllAlphaSpace, {ns}.Spec"
        proofs.append((g, f"theorem eq_{g} : ∀ (s : String) (b : Bool), (GammaJ.Spec_{g}.pre s ↔ "
                          f"{ns}.Spec.pre {{ {f} := s }}) ∧ (GammaJ.Spec_{g}.post s b ↔ "
                          f"{ns}.Spec.post {{ {f} := s }} {{ {b} := b }}) := by\n"
                          f"  intro s b\n  simp only [{unfold}]\n"
                          f"  first | done | (simp [String.length]; done) | (simp; done) | "
                          f"(constructor <;> simp [String.length] <;> omega) | (simp_all; done)"))
    import po
    if proofs:
        defs_only = re.sub(r"^#eval.*?(?=^end Gen)", "", "\n\n".join(blocks), flags=re.MULTILINE | re.DOTALL)
        res = po.run_theorems(body + "\n\n" + defs_only, [t for _, t in proofs])
        for (g, _), (ok, _) in zip(proofs, res):
            pairs[g]["proved"] = ok

    rows_md = []
    counts = {}
    for g in names:
        gid = GOLD_TO_ID.get(g)
        r = specs.get(gid) if gid else None
        acc = bool(r and r.get("checked") and review.get(gid, {}).get("decision") == "accept")
        status = "–" if r is None else ("accepted" if acc else f"not accepted (L0.5 {r['l05']['status']})")
        p = pairs.get(g, {})
        if g in MANUAL:
            cls, note = MANUAL[g]
            method = "manual (by Claude, needs human check)"
        elif p.get("gen_compiles") is False:
            cls, note, method = "different", "the generated spec does not compile", "–"
        elif "class" in p:
            cls = p["class"]
            n = len(p["rows"])
            method = ("lean-proved" if p.get("proved") else f"lean-tested ({n})") + \
                     (", gold via Python" if p["validator"] in PY_GOLD else "")
            note = p["witness"] or "agrees on every tested string"
        else:
            cls, note, method = "?", "not compared", "–"
        if not acc and cls != "missing":
            cls_counted = "not accepted"
        else:
            cls_counted = cls
        counts[cls_counted] = counts.get(cls_counted, 0) + 1
        rows_md.append(f"| `Spec_{g}` | {('`' + gid + '`') if gid else '–'} | {status} | **{cls}** | {method} | "
                       f"{note.replace('|', '\\|')} |")

    lines = [
        "# P8: generated gamma j specs vs the gold specs",
        "",
        "Generated by `evaluation/p8_gold_compare.py`. Gold: `benchmark/gammaj/GammaJ_L0.lean` (25 `Spec_<id>`).",
        "Generated: `runs/0000 - gamma j/qwen-v11/rep1` (L0 v11, seed 42). Classes and methods are defined in the",
        "script docstring: *stronger* = the generated spec refines the gold one (accepts fewer implementations).",
        "",
        "**Provenance of the gold file.** Committed in `7cc48e2` (4 Nov 2026) as \"hand-written gold L0\", and",
        "MEMORY.md calls it hand-written; the commit has no co-author line. Its authorship is not otherwise",
        "recorded. If any of it was drafted with a closed model (Claude), the project rule (open-weight models only)",
        "makes using it as the reference a rules question for the team: confirm before reporting these numbers.",
        "",
        "**Counts** (accepted specs only; `not accepted` = the generated spec failed L0.5): " +
        ", ".join(f"{k} {v}" for k, v in sorted(counts.items(), key=lambda kv: -kv[1])) + ".",
        "",
        "| gold | generated id | generated status | class | method | why / distinguishing input |",
        "|---|---|---|---|---|---|",
    ] + rows_md + [
        "",
        "Reading the table:",
        "- For validators (`valid = true ↔ rule`), two different rules are *different*, never stronger or weaker:",
        "  the output is a function of the input. A validator pair is *weaker* only through `pre`.",
        "- `lean-tested` rows that agree on every string are equivalent on the test set only; `lean-proved` rows",
        "  are proved equivalent for every string.",
        "- The manual rows are Claude's reading and are not evidence until a team member confirms them.",
    ]
    Path(args.out).write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
