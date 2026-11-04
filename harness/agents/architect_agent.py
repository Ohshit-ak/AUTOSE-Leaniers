"""L1 architect: one component group (a system) → component contracts + PO1/PO2 proofs.

The requirements graph decides WHAT is proved: which operations share a contract
(components), the chain order, and so the trace, PO1 and PO2 statements (arch_lean.py).
The model only writes, per operation a component owns, two Lean definitions
`<C>_pre_<op>` / `<C>_post_<op>` (and proof bodies if the harness's own proofs fail).

Modes (`CF_ARCH_MODE`):
    pipeline (default)  the harness calls the tools (agents/arch_tools.py) in a fixed order:
                        per component in chain order, per operation: write defs →
                        check_contract → check_trace (failures fed back, CF_MAX_RETRIES);
                        then PO1 for each consecutive pair, then PO2, then submit
    agent               the model calls the same tools itself (OpenAI tool calling; local
                        Qwen needs CF_QWEN_JINJA=1). Budget CF_ARCH_MAX_TOOL_CALLS. Malformed
                        calls or a loop switch to pipeline mode for whatever is left.
No-graph baseline (`no_graph=True`): the model gets every L0 spec of the group without
components, edges or order, proposes its own decomposition (checked: every operation exactly
once, at least two components), and then the same pipeline and checks run on it.
"""
import hashlib
import json
import os
import re
import time
from typing import Dict, List, Optional

import arch_lean as A
from agents.arch_tools import TOOLS, ArchSession, check_decomposition, def_names
from agents.base import _ask, generate_verified
from config import MAX_RETRIES, TEMPERATURE
from llm import extract_lean

ARCH_MODE = os.getenv("CF_ARCH_MODE", "pipeline")
MAX_TOOL_CALLS = int(os.getenv("CF_ARCH_MAX_TOOL_CALLS", "40"))
PROOF_RETRIES = int(os.getenv("CF_ARCH_PROOF_RETRIES", "2"))
MAX_BAD_CALLS = 3     # malformed tool calls before agent mode gives up
LOOP_REPEATS = 3      # the same call this many times in a row = a loop

WORKED_EXAMPLE = """\
Example (a toy shop, not your system). The locked L0 spec of operation `OP-sell` is
```lean
namespace L0_op_sell
structure Input where
  stock : Nat
  deriving DecidableEq, Repr
structure Output where
  stock : Nat
  sold : Bool
  deriving DecidableEq, Repr
def Spec : Contract Input Output where
  pre := fun i => 0 < i.stock
  post := fun i o => o.stock + 1 = i.stock ∧ o.sold = true
end L0_op_sell
```
Component `Stock` (first in the chain Stock → Audit) owns it, so the answer is
```lean
def Stock_pre_op_sell (i : L0_op_sell.Input) : Prop := 0 < i.stock
def Stock_post_op_sell (i : L0_op_sell.Input) (o : L0_op_sell.Output) : Prop :=
  o.stock + 1 = i.stock ∧ o.sold = true
```
and for `OP-audit`, owned by `Audit` (L0: `pre := fun _ => True`,
`post := fun i o => (o.ok = true ↔ i.stock ≤ 100)`):
```lean
def Audit_pre_op_audit (_ : L0_op_audit.Input) : Prop := True
def Audit_post_op_audit (i : L0_op_audit.Input) (o : L0_op_audit.Output) : Prop :=
  (o.ok = true ↔ i.stock ≤ 100)
```
The harness then builds `StockContract`, `AuditContract : Contract ShopMsg ShopMsg` from these
definitions and proves PO1 `Contract.Compatible StockContract AuditContract` and PO2
`Contract.Refines (StockContract.seq AuditContract) ShopSystemSpec` itself."""

SYSTEM_PROMPT_ARCH = f"""\
You are the architecture agent of ContractForge (Lean 4.29, Lean core only).

A system is split into components; each component owns some operations, and each operation
has a locked L0 spec `L0_<op>.Spec : Contract L0_<op>.Input L0_<op>.Output`. For every
operation a component owns, you write its contract as two definitions:
    def <C>_pre_<op> (i : L0_<op>.Input) : Prop := …                 -- what C assumes
    def <C>_post_<op> (i : L0_<op>.Input) (o : L0_<op>.Output) : Prop := …  -- what C guarantees
The harness proves (trace) that `pre` assumes no more than the L0 `pre` and that, under the
L0 `pre`, `post` implies the L0 `post`. So: `pre` may be weaker than the L0 `pre`, `post`
may be stronger than the L0 `post`, and copying the L0 conditions is always correct.

Rules:
- Output ONLY the two definitions (plus helper `def`s you need, also named `<C>_…`) in ONE
  ```lean block. No `theorem`, `example`, `structure`, `namespace`, `import`, `open`.
- Never refer to `L0_<op>.Spec`: write the conditions on `i.<field>` / `o.<field>` yourself.
- Use only the fields declared in `L0_<op>.Input` (with `i.`) and `L0_<op>.Output` (with `o.`).
  Helper structures of the L0 spec are `L0_<op>.<Name>`.
- `Prop` connectives: `∧ ∨ ¬ → ↔ = ≠ ≤ <`; a Bool is compared with `= true`. No `sorry`.
- The conditions must hold for the L0 example values and must constrain the output.

{WORKED_EXAMPLE}
"""

SYSTEM_PROMPT_PROOF = """\
You write Lean 4 proofs (Lean core only, version 4.29). You get one theorem statement that
the harness wrote and the definitions it is about. Reply with ONE ```lean block containing
only the proof, starting with `by`. Do not restate or change the theorem. No `sorry`."""

SYSTEM_PROMPT_DECOMPOSE = """\
You are a software architect. Split the operations of one system into components (at least
two). Each component later gets one assume/guarantee contract; components run as a chain
in the order you list them. Group operations that work on the same data. Every operation
must be in exactly one component. Component names are CamelCase letters and digits.
Reply with ONLY a JSON object:
{"components": [{"name": "Accounts", "operations": ["<op id>", "..."]}, ...]}"""

AGENT_PROMPT = f"""\
You are the architecture agent of ContractForge (Lean 4.29). You work through tools.
Steps, one component at a time in chain order (get_graph_summary gives the order):
1. get_component, then get_l0_spec for each of its operations.
2. Write the component's definitions and call check_contract(component, code) until it passes.
   The code is ALL `<C>_pre_<op>` / `<C>_post_<op>` definitions of that component.
3. check_trace(component, operation) for each operation.
4. After each component except the first: check_po1(previous, component).
At the end: check_po2, then submit_architecture. Statements are written by the harness; you
only give definitions (and proof bodies if a check asks for one).

{SYSTEM_PROMPT_ARCH.split("Rules:", 1)[1]}"""


def prompt_hash() -> str:
    """sha256 (12 hex digits) of every fixed L1 prompt; recorded in each arch.json."""
    text = "\n\0".join([SYSTEM_PROMPT_ARCH, SYSTEM_PROMPT_PROOF, SYSTEM_PROMPT_DECOMPOSE, AGENT_PROMPT])
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:12]


# ---------------------------------------------------------------------------
# Pipeline mode
# ---------------------------------------------------------------------------

def op_prompt(s: ArchSession, comp: str, op: str, graph_info: bool) -> str:
    k = s.order.index(comp)
    parts = [f"System `{s.G}`, chain {' → '.join(s.order)}. Component `{comp}` "
             f"(position {k + 1} of {len(s.order)}) owns: {', '.join(next(c for c in s.components if c['id'] == comp)['operations'])}."]
    if graph_info:
        gc = next((x for x in s.graph["components"] if x["id"] == comp), {})
        if gc:
            parts.append(f"It reads {', '.join(gc.get('entities_read', [])) or 'no shared entity'} and writes "
                         f"{', '.join(gc.get('entities_written', [])) or 'no shared entity'}.")
    if k:
        prev = s.order[k - 1]
        prev_defs = "\n".join(ln for ln in s.code.get(prev, "").splitlines() if ln.startswith("def "))[:1500]
        if prev_defs:
            parts.append(f"The previous component `{prev}` has these contract definitions:\n```lean\n{prev_defs}\n```")
    parts.append(s.get_l0_spec(op))
    parts.append("Write exactly these two definitions (in one ```lean block):\n"
                 + A.owned_signatures(comp, [op]))
    return "\n\n".join(parts)


def _validator(s: ArchSession, comp: str, op: str):
    """Problems of one operation's definitions, via the same tools agent mode uses. Each
    operation's definitions are checked on their own (only its L0 spec as context), so a
    check costs the same for the first and the fiftieth operation of a component."""
    def validate(code: str) -> List[str]:
        before = s.code.get(comp)
        try:
            r = s.check_contract(comp, code)
            info = (r.get("ops") or {}).get(op)
            if info is None or not info.get("defined"):
                if r.get("stage") in ("lean", "check") and not r["ok"]:
                    return [r["text"]]
                return [f"define both `{A.pre_name(comp, op)}` and `{A.post_name(comp, op)}`"]
            if not r["ok"]:
                return [ln[2:] for ln in r["text"].splitlines() if ln.startswith("- ")] or [r["text"]]
            t = s.check_trace(comp, op)
            if not t["ok"]:
                return ["The harness could not prove that your contract covers the L0 spec "
                        "(`pre` must follow from the L0 `pre`; under the L0 `pre`, your `post` must "
                        "imply the L0 `post`):\n" + t["text"]]
            return []
        finally:
            if before is None:
                s.code.pop(comp, None)
            else:
                s.code[comp] = before
    return validate


def rename_clashes(accepted: str, code: str, op: str) -> str:
    """Helper defs of a new operation that clash with earlier ones get the operation's slug
    appended (mechanical, like agents/fixups.py)."""
    taken = set(def_names(accepted))
    for name in def_names(code):
        if name in taken:
            code = re.sub(rf"(?<![\w.]){re.escape(name)}\b", f"{name}_{A.slug(op)}", code)
    return code


def proof_body(code: str) -> str:
    """The proof of a reply: what follows `:=` if the model restated the theorem."""
    m = re.search(r"^\s*(?:theorem|lemma|example)\b.*?:=\s*", code, re.DOTALL | re.MULTILINE)
    body = code[m.end():] if m else code
    return body.strip()


def prove_loop(s: ArchSession, statement: str, about: str, check, model: str, retries: int) -> dict:
    """Ask the model for a proof body of a harness-written statement; `check(body)` → result."""
    prompt = (f"Prove this theorem:\n```lean\n{statement} := by\n  sorry\n```\n"
              f"It is about these definitions:\n```lean\n{about[:6000]}\n```")
    r = {"ok": False, "text": ""}
    for k in range(retries):
        reply = _ask(prompt if k == 0 else f"{prompt}\n\nYour last proof failed:\n{r['text'][:1500]}\n"
                     "Give a corrected proof.", SYSTEM_PROMPT_PROOF, model)
        r = check(proof_body(extract_lean(reply)))
        if r["ok"]:
            break
    return r


def build_component(s: ArchSession, comp: str, model: str, graph_info: bool, record: dict) -> None:
    ops = next(c for c in s.components if c["id"] == comp)["operations"]
    accepted = ""
    for op in ops:
        t0 = time.time()
        r = generate_verified(op_prompt(s, comp, op, graph_info), SYSTEM_PROMPT_ARCH, model,
                              context=s.op_context([op]), validate=_validator(s, comp, op))
        status = "ok" if r["success"] else "failed"
        code = rename_clashes(accepted, r.get("code") or "", op)
        if not r["success"] and code:
            # Keep the best attempt if it at least compiles; its failed checks are reported.
            before = s.code.get(comp)
            trial = s.check_contract(comp, code)
            status = "compiles" if (trial.get("ops") or {}).get(op, {}).get("defined") else "failed"
            s.code[comp] = before if before is not None else ""
        if status != "failed":
            accepted = (accepted + "\n\n" + code).strip()
        s.code[comp] = accepted
        record["operations"][op] = {"component": comp, "status": status, "attempts": r["attempts"],
                                    "seconds": round(time.time() - t0, 1), "log": r.get("log", []),
                                    **({"error": r["error"][:600]} if r.get("error") else {})}
    s.fill_missing(comp)
    s.check_contract(comp, s.code[comp])
    t = s.check_traces(comp, ops)
    if t["ok"] or not PROOF_RETRIES:
        return
    for (op, part), ok in sorted(t["parts"].items()):
        if ok or op in s.placeholders:
            continue
        stmt = A.trace_statements(comp, op)[part]
        about = s.get_l0_spec(op) + "\n" + s.code[comp]
        prove_loop(s, stmt, about, lambda body, o=op, p=part: s.check_trace(comp, o, **{f"proof_{p}": body}),
                   model, PROOF_RETRIES)


def run_pipeline(s: ArchSession, model: str, graph_info: bool, record: dict,
                 start: int = 0) -> None:
    for k, comp in enumerate(s.order):
        if k < start:
            continue
        build_component(s, comp, model, graph_info, record)
        if k:
            r = s.check_po1(s.order[k - 1], comp)
            if not r["ok"] and "needs the trace" not in r["text"] and PROOF_RETRIES:
                stmt = A.po1_statement(s.order[k - 1], comp)
                prove_loop(s, stmt, s.code[s.order[k - 1]] + "\n" + s.code[comp],
                           lambda body: s.check_po1(s.order[k - 1], comp, body), model, PROOF_RETRIES)
    r = s.check_po2()
    if not r["ok"] and "needs" not in r["text"] and PROOF_RETRIES:
        prove_loop(s, A.po2_statement(s.G, s.order), "\n".join(s.code.values()),
                   lambda body: s.check_po2(body), model, PROOF_RETRIES)


# ---------------------------------------------------------------------------
# Agent mode
# ---------------------------------------------------------------------------

def run_agent(s: ArchSession, model: str, record: dict) -> str:
    """The model drives the tools. Returns 'agent' or 'agent→pipeline' (fallback)."""
    from llm import call_llm_tools
    messages = [{"role": "system", "content": AGENT_PROMPT},
                {"role": "user", "content": f"Build the architecture of system `{s.G}`. "
                                            "Start with get_graph_summary."}]
    bad, recent, calls = 0, [], 0
    while calls < MAX_TOOL_CALLS:
        try:
            reply = call_llm_tools(messages, TOOLS, model, temperature=TEMPERATURE)
        except NotImplementedError as e:
            record["agent_stop"] = str(e)
            return "agent→pipeline"
        if not reply["tool_calls"]:
            messages.append({"role": "assistant", "content": reply["content"]})
            bad += 1
            if bad >= MAX_BAD_CALLS:
                record["agent_stop"] = "no tool calls"
                return "agent→pipeline"
            messages.append({"role": "user", "content": "Use the tools. Finish with submit_architecture."})
            continue
        messages.append({"role": "assistant", "content": reply["content"] or None,
                         "tool_calls": [{"id": c["id"], "type": "function",
                                         "function": {"name": c["name"], "arguments": c["arguments"]}}
                                        for c in reply["tool_calls"]]})
        for c in reply["tool_calls"]:
            calls += 1
            try:
                args = json.loads(c["arguments"] or "{}")
            except json.JSONDecodeError:
                bad += 1
                out = "error: arguments are not valid JSON"
            else:
                sig = (c["name"], json.dumps(args, sort_keys=True))
                recent = (recent + [sig])[-LOOP_REPEATS:]
                out = s.call(c["name"], args)
                if c["name"] == "submit_architecture":
                    messages.append({"role": "tool", "tool_call_id": c["id"], "content": out})
                    return "agent"
            messages.append({"role": "tool", "tool_call_id": c["id"], "content": out[:3000]})
        if bad >= MAX_BAD_CALLS or (len(recent) == LOOP_REPEATS and len(set(recent)) == 1):
            record["agent_stop"] = "malformed calls" if bad >= MAX_BAD_CALLS else "loop"
            return "agent→pipeline"
    record["agent_stop"] = f"budget of {MAX_TOOL_CALLS} tool calls used"
    return "agent (budget)"


# ---------------------------------------------------------------------------
# No-graph decomposition
# ---------------------------------------------------------------------------

def decompose(s: ArchSession, model: str, record: dict) -> Optional[List[dict]]:
    from validate import field_types
    ops = list(s.l0)
    lines = []
    for op in ops:
        ft = field_types(s.l0[op])
        lines.append(f"- {op}: {s.l0_texts.get(op, '')[:160]}\n  Input fields: "
                     f"{', '.join(ft.get('Input', {})) or '-'}; Output fields: {', '.join(ft.get('Output', {})) or '-'}")
    prompt = (f"The system has {len(ops)} operations (id: requirement; L0 spec fields):\n"
              + "\n".join(lines))
    history, attempts = [], []
    for k in range(MAX_RETRIES):
        reply = _ask(prompt, SYSTEM_PROMPT_DECOMPOSE, model, history=history or None)
        m = re.search(r"\{.*\}", reply, re.DOTALL)
        try:
            comps = json.loads(m.group(0))["components"] if m else None
            comps = [{"id": c.get("name") or c.get("id"), "operations": list(c.get("operations", []))}
                     for c in comps]
            problems = check_decomposition(comps, ops)
        except (json.JSONDecodeError, KeyError, TypeError, AttributeError):
            comps, problems = None, ["the reply is not the JSON object asked for"]
        attempts.append({"attempt": k + 1, "problems": problems})
        if comps and not problems:
            record["decomposition"] = {"components": comps, "attempts": attempts}
            return comps
        if not history:
            history = [{"role": "user", "content": prompt}]
        history += [{"role": "assistant", "content": reply[:3000]},
                    {"role": "user", "content": "Problems:\n" + "\n".join(f"- {p}" for p in problems)
                     + "\nReply with the corrected JSON only."}]
        history = history[:1] + history[1:][-4:]
        prompt = "Reply with the corrected JSON only."
    record["decomposition"] = {"components": None, "attempts": attempts}
    return None


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def run_group(graph: dict, group_id: str, l0_codes: Dict[str, str], domain_code: Optional[str],
              model: str, no_graph: bool = False, mode: Optional[str] = None,
              l0_texts: Optional[Dict[str, str]] = None) -> dict:
    """Run L1 on one group. Returns {"arch": Arch.lean text, "record": arch.json content}."""
    t0 = time.time()
    mode = mode or ARCH_MODE
    s = ArchSession(graph, group_id, l0_codes, domain_code, l0_texts=l0_texts)
    record = {"group": group_id, "graph_mode": "no-graph" if no_graph else "graph", "model": model,
              "requested_mode": mode, "operations": {}, "locked_hash": s.locked_hash,
              "l0_operations": list(s.l0),
              "excluded_operations": [o for o in s.group["operations"] if o not in s.l0]}
    if no_graph:
        comps = decompose(s, model, record)
        if comps is None:
            record.update(mode_used="none", verdict="no valid decomposition", seconds=round(time.time() - t0, 1))
            return {"arch": "", "record": record}
        s.set_components(comps)
        s.require_split = True
    record["components"] = [{"id": c["id"], "operations": c["operations"]} for c in s.components]
    record["order"] = list(s.order)

    used = "pipeline"
    if mode == "agent":
        used = run_agent(s, model, record)
        if used == "agent→pipeline":
            done = sum(1 for c in s.order if s.code.get(c))
            run_pipeline(s, model, not no_graph, record, start=max(0, done - 1))
    else:
        run_pipeline(s, model, not no_graph, record)

    final = s.submit_architecture(expected_locked_hash=record["locked_hash"])
    record.update(
        mode_used=used, verdict="accepted" if final["ok"] else "rejected", problems=final["problems"],
        arch_compiles=final["arch_compiles"], obligations={k: s.results.get(k, {}) for k in s.obligations()},
        proved=final["proved"], contracts=final["contracts"], placeholders=s.placeholders,
        code=dict(s.code), proofs=dict(s.proofs), tool_calls=s.calls, n_tool_calls=len(s.calls),
        seconds=round(time.time() - t0, 1))
    return {"arch": final["arch"], "record": record}


def extract_contracts(arch_code: str) -> List[str]:
    """Names of the component contracts in an Arch.lean (for L2)."""
    return re.findall(r"^def\s+(\w+Contract)\b", arch_code, re.MULTILINE)
