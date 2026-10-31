import re, json, sys, collections
from pathlib import Path
run = Path("runs/0000 - gamma j/qwen-v6"); out = Path("runs/negdiag/compile_out")
specs = {r["id"].replace("/", "_"): r for r in json.load(open(run/"specs.json"))["results"]}
MSG = re.compile(r"^(.*?\.lean):(\d+):(\d+): (error|warning)(\([^)]*\))?: ?(.*)$")
def parse(txt):
    msgs, cur = [], None
    for line in txt.splitlines():
        m = MSG.match(line)
        if m:
            cur = {"line": int(m[2]), "col": int(m[3]), "sev": m[4], "kind": (m[5] or "").strip("()"), "text": [m[6]]}
            msgs.append(cur)
        elif cur: cur["text"].append(line)
    return msgs
def category(m):
    t = " ".join(m["text"])
    if m["kind"] == "lean.invalidField" or "is not a field" in t: return "unknown field / invented API"
    if "Unknown identifier" in t or "unknown constant" in t.lower(): return "unknown identifier"
    if "unexpected token" in t or "expected" in t and m["kind"] == "": 
        if "Type mismatch" not in t and "type mismatch" not in t: pass
    if "decide` proved that the proposition" in t or "decide` failed" in t: return "example false / decide failed"
    if "mismatch" in t: return "type mismatch"
    if "synthInstanceFailed" in m["kind"] or "failed to synthesize" in t or "deriving handlers" in t: return "missing instance"
    if "unexpected" in t: return "syntax"
    if "Function expected" in t: return "not a function"
    if "has already been declared" in t: return "duplicate declaration (harness joined 2 code blocks)"
    if "already been specified" in t or "Fields missing" in t: return "bad structure literal"
    return "other"
rows, sections, cats = [], [], collections.Counter()
for rc in sorted(out.glob("*.rc")):
    b = rc.stem; code = int(rc.read_text().strip()); txt = (out/f"{b}.txt").read_text()
    msgs = parse(txt); errs = [m for m in msgs if m["sev"] == "error"]; warns = [m for m in msgs if m["sev"] == "warning"]
    r = specs.get(b, {})
    rows.append((b, r.get("kind", "?"), "✅" if code == 0 else "❌", len(errs), len(warns), r.get("checked")))
    if code == 0 and not errs: continue
    for m in errs: cats[category(m)] += 1
    src = (run/"lean"/f"{b}.lean").read_text().splitlines()
    s = [f"### ❌ `{r.get('id', b)}` ({r.get('kind','?')})", "", f"> {r.get('requirement_text','').strip()[:300]}", ""]
    for i, m in enumerate(errs, 1):
        line = src[m["line"]-1].rstrip() if 0 < m["line"] <= len(src) else ""
        s += [f"**Error {i}** — line {m['line']}:{m['col']} · {category(m)}" + (f" · `{m['kind']}`" if m["kind"] else ""), "",
              "```lean", f"{m['line']:>3} | {line}", "```", "", "```text", "\n".join(m["text"]).strip(), "```", ""]
    if not errs:
        s += ["```text", txt.strip()[:3000], "```", ""]
    s += ["<details><summary>Full file</summary>", "", "```lean"] + [f"{n:>3} | {l}" for n, l in enumerate(src, 1)] + ["```", "", "</details>", ""]
    sections.append("\n".join(s))
ok = sum(r[2] == "✅" for r in rows)
md = ["# Lean compile errors — gamma j, Qwen v6", "",
      f"Each saved file in `runs/0000 - gamma j/qwen-v6/lean/` compiled on its own with `lake env lean <file>` "
      f"from `framework/` (Lean 4.29.1, `lake build` up to date). **{ok}/{len(rows)} compile, {len(rows)-ok} fail.**", "",
      "Compiling is not passing: 4 files compile but failed the L0.5 vacuity check (`post` accepts any output), "
      "so 60/75 count as checked.", "",
      "**Harness bug found here:** `llm.extract_lean` joins every fenced block in a reply. When the model writes "
      "the whole spec twice (e.g. a first and a corrected version), both copies are saved and Lean reports "
      "`Input has already been declared` (5.3/R5, DD-credit-card-expiry-date). These errors come from the harness, not the model.", "", "## Errors by category", "", "| Category | Errors |", "|---|---|"]
md += [f"| {c} | {n} |" for c, n in cats.most_common()]
md += ["", "## All files", "", "| File | Kind | Compiles | Errors | Warnings | Checked (L0 + L0.5) |", "|---|---|---|---|---|---|"]
md += [f"| `{b}` | {k} | {c} | {e} | {w} | {'yes' if ch else 'no'} |" for b, k, c, e, w, ch in rows]
md += ["", "## Errors per failing file", ""] + sections
Path(sys.argv[1]).write_text("\n".join(md) + "\n")
print(cats)
