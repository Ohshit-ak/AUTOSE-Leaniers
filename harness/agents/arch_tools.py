"""L1 tools: what the architect may look at and the checks it must pass.

Each tool is a plain, deterministic Python method of `ArchSession` with a JSON schema
(`TOOLS`), returning short text (Lean errors cut to the first 3, like `repair.py`). No
model calls happen here. The same tools serve both modes:

    agent mode     the model calls the tools itself (needs a server with tool calling)
    pipeline mode  the harness calls them in a fixed order (agents/architect_agent.py)

Rules the model cannot bypass:
  - every theorem statement (trace, PO1, PO2, system_sound) is written by the harness
    (arch_lean.py); the model supplies only `<C>_pre_<op>` / `<C>_post_<op>` definitions
    (plus helper defs named `<C>_…`) and proof bodies;
  - Domain.lean, the L0 specs, the message type and the system spec are locked: hashed when
    the session starts and re-hashed by `submit_architecture`;
  - `submit_architecture` reruns every check itself and never trusts earlier results;
  - no `sorry`, `admit`, `axiom`, `native_decide`, and no new structures, instances,
    namespaces, options or macros in model code.
"""
import hashlib
import json
import re
from typing import Dict, List, Optional, Sequence, Tuple

import arch_lean as A
from agents.repair import closest, format_feedback, framework_helpers, parse_errors, _trim
from lean_runner import HEADER, check_lean, core_names
from validate import _mutants, example_witness, field_types, literal_fields, one_line

PRELUDE = "set_option linter.unusedSimpArgs false\nset_option linter.unusedVariables false\n"
MAX_ERRORS = 3
_DEF_ONLY = re.compile(r"^(?:@\[[^\]]*\]\s*)?(?:noncomputable\s+)?(?:def|abbrev)\s+([\w.']+)", re.MULTILINE)
_BANNED = [(re.compile(rf"^\s*{kw}\b", re.MULTILINE), kw) for kw in
           ("structure", "inductive", "class", "instance", "namespace", "section", "set_option",
            "attribute", "macro", "syntax", "elab", "axiom", "opaque", "import", "universe")]


def sha(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:12]


def _errors(output: str, n: int = MAX_ERRORS) -> List[str]:
    errs = parse_errors(output)
    if not errs:
        return [_trim(output.strip())] if output.strip() else []
    return [_trim(e["msg"]) for e in errs[:n]]


def def_names(code: str) -> List[str]:
    return _DEF_ONLY.findall(code)


class ArchSession:
    """One component group (a system for L1): its locked context, the model's contract code
    per component, and the result of every obligation."""

    def __init__(self, graph: dict, group_id: str, l0_codes: Dict[str, str], domain_code: Optional[str],
                 components: Optional[List[dict]] = None, l0_texts: Optional[Dict[str, str]] = None):
        """`components` = [{"id", "operations"}] in chain order; default: the graph's
        components of the group in its topological order (no-graph mode passes the model's)."""
        self.graph, self.group = graph, next(g for g in graph["groups"] if g["id"] == group_id)
        self.G = group_id
        self.domain_code = domain_code
        gops = set(self.group["operations"])
        # Only L0 specs that compile can be part of a Lean system.
        self.l0 = {op: c for op, c in sorted(l0_codes.items()) if op in gops and c}
        self.l0_texts = l0_texts or {}
        if components is None:
            by_id = {c["id"]: c for c in graph["components"]}
            components = [{"id": c, "operations": by_id[c]["operations"]} for c in self.group["order"]]
        self.set_components(components)
        self.locked = self._locked_text()
        self.locked_hash = sha(self.locked)
        self.code: Dict[str, str] = {}               # component → model definitions
        self.proofs: Dict[str, str] = {}             # obligation → model proof body
        self.results: Dict[str, dict] = {}           # obligation → outcome
        self.calls: List[dict] = []                  # tool-call log
        self.placeholders: List[str] = []           # operations whose defs the harness filled in
        self.require_split = False                   # no-graph mode: one component is not allowed

    # -- setup ---------------------------------------------------------------------------

    def set_components(self, components: List[dict]) -> None:
        self.components = [{"id": c["id"], "operations": [o for o in c["operations"] if o in self.l0]}
                           for c in components]
        self.components = [c for c in self.components if c["operations"]]
        self.order = [c["id"] for c in self.components]
        self.owner = {o: c["id"] for c in self.components for o in c["operations"]}

    def _domain_block(self) -> str:
        if not self.domain_code:
            return ""
        body = re.sub(r"^\s*(?:import|open)\s+.*$\n?", "", self.domain_code, flags=re.MULTILINE)
        return f"namespace Domain\n{body.strip()}\nend Domain"

    def _locked_text(self) -> str:
        parts = [self._domain_block(), A.locked_context(self.G, self.l0)]
        return "\n\n".join(p for p in parts if p)

    def op_context(self, ops: Sequence[str]) -> str:
        """The smallest locked context for checks about `ops`: their L0 specs (and Domain)."""
        parts = [self._domain_block()] + [A.l0_block(o, self.l0[o]) for o in sorted(set(ops))]
        return PRELUDE + "\n\n".join(p for p in parts if p)

    def log(self, tool: str, args: dict, result: str) -> str:
        self.calls.append({"tool": tool, "args": {k: (v if len(str(v)) < 200 else str(v)[:200] + "…")
                                                  for k, v in args.items()}, "result": result[:300]})
        return result

    # -- read-only tools -------------------------------------------------------------------

    def get_graph_summary(self) -> str:
        g = self.group
        lines = [f"System {self.G}: {len(self.l0)} operations with a compiling L0 spec "
                 f"(of {len(g['operations'])} in the group)."]
        lines.append("Components in chain order (each gets one contract `<C>Contract`):")
        for c in self.components:
            lines.append(f"  {c['id']}: {len(c['operations'])} operations: {', '.join(c['operations'])}")
        for e in g.get("component_edges", []):
            lines.append(f"Edge {e['src']} → {e['dst']} ({len(e['reasons'])} reasons), e.g. {e['reasons'][0]}")
        if g.get("cycles"):
            lines.append(f"{len(g['cycles'])} cycles between provisional components were merged: "
                         f"{g.get('merged_cycles')}")
        return "\n".join(lines)

    def get_component(self, component: str) -> str:
        c = next((c for c in self.components if c["id"] == component), None)
        if c is None:
            return f"No component `{component}`. Components: {', '.join(self.order)}."
        k = self.order.index(component)
        gc = next((x for x in self.graph["components"] if x["id"] == component), {})
        lines = [f"Component {component} (position {k + 1} of {len(self.order)} in the chain).",
                 f"Previous: {self.order[k - 1] if k else 'none'}; next: "
                 f"{self.order[k + 1] if k + 1 < len(self.order) else 'none'}.",
                 f"Entities read: {', '.join(gc.get('entities_read', [])) or '-'}; "
                 f"written: {', '.join(gc.get('entities_written', [])) or '-'}.",
                 "You must define (Lean), one pair per operation it owns:",
                 A.owned_signatures(component, c["operations"])]
        return "\n".join(lines)

    def get_l0_spec(self, operation: str) -> str:
        if operation not in self.l0:
            return f"No compiling L0 spec `{operation}` in {self.G}."
        text = self.l0_texts.get(operation, "")
        return (f"Requirement {operation}: {text}\nIts L0 spec (locked, in namespace "
                f"`L0_{A.slug(operation)}`):\n```lean\n{A.l0_block(operation, self.l0[operation])}\n```")

    def get_domain_types(self) -> str:
        return self._domain_block() or "(no Domain.lean for this document)"

    def lookup_name(self, name: str) -> str:
        cands = [f"{ns}.{n}" for ns, ns_names in core_names().items() for n in ns_names]
        cands += framework_helpers() + re.findall(r"^(?:structure|def|inductive)\s+(\w+)", self.locked, re.MULTILINE)
        found = closest(name.split(".")[-1], [c.split(".")[-1] for c in cands])
        full = [next(c for c in cands if c.split(".")[-1] == f) for f in found]
        return f"Closest real names to `{name}`: {', '.join(f'`{f}`' for f in full) or 'none'}."

    def check_lean(self, code: str) -> str:
        r = check_lean(PRELUDE + self.locked + "\n\n" + code)
        return "ok" if r["success"] else "Lean errors:\n" + "\n".join(f"- {e}" for e in _errors(r["error"]))

    # -- contract checks --------------------------------------------------------------------

    def code_problems(self, component: str, code: str) -> List[str]:
        """Model code must only add `<component>_…` definitions: nothing locked, no escapes."""
        problems = [f"`{w}` is not allowed" for w in A.forbidden_words(code)]
        problems += [f"`{kw}` is not allowed in contract code (only `def`s)" for rx, kw in _BANNED
                     if rx.search(code)]
        for name in A.defined_names(code):
            if not name.startswith(f"{component}_"):
                problems.append(f"`{name}`: every definition must be named `{component}_…`")
        if re.search(r"\bL0_\w+\.Spec\b", code):
            problems.append("do not refer to `L0_….Spec`: state the conditions on the fields of `i` and `o` "
                            "yourself (the harness proves they imply the L0 spec)")
        return problems

    def fill_missing(self, component: str) -> List[str]:
        """Placeholder defs (`False`) for owned operations the model gave no valid contract for,
        so the component's contract still compiles; their traces then fail and are reported."""
        code = self.code.get(component, "")
        have, added = set(def_names(code)), []
        for op in next(c for c in self.components if c["id"] == component)["operations"]:
            s = A.slug(op)
            if A.pre_name(component, op) not in have or A.post_name(component, op) not in have:
                code += (f"\n\n-- harness placeholder: no valid contract from the model for {op}\n"
                         f"def {A.pre_name(component, op)} (_ : L0_{s}.Input) : Prop := False\n"
                         f"def {A.post_name(component, op)} (_ : L0_{s}.Input) (_ : L0_{s}.Output) : Prop := False")
                added.append(op)
        self.code[component] = code.strip()
        self.placeholders += [o for o in added if o not in self.placeholders]
        return added

    def _ops_in(self, component: str, code: str) -> List[str]:
        names = set(def_names(code))
        return [o for o in self.l0 if self.owner.get(o) == component
                and (A.pre_name(component, o) in names or A.post_name(component, o) in names)]

    def check_contract(self, component: str, code: str) -> dict:
        """Compiles? For each operation it defines: both defs present, satisfiable (the L0
        example's own input/output), `pre` not false on that input, `post` not vacuous (rejects
        some changed output that the L0 `post` rejects). Stores the code when it compiles."""
        if component not in self.order:
            return {"ok": False, "text": f"No component `{component}`."}
        problems = self.code_problems(component, code)
        if problems:
            return {"ok": False, "stage": "check", "text": "Rejected:\n" + "\n".join(f"- {p}" for p in problems)}
        ops = self._ops_in(component, code)
        if not ops:
            return {"ok": False, "stage": "names", "text":
                    f"No `{component}_pre_<op>`/`{component}_post_<op>` definitions found. Expected:\n"
                    + A.owned_signatures(component, [o for o in self.l0 if self.owner.get(o) == component])}
        ctx = self.op_context(ops)
        prefix = ctx + "\n\n" + code
        names, per_op, lines = set(def_names(code)), {}, []
        unfold = ", ".join(def_names(code))
        examples, index = [], []
        for op in ops:
            info = {"defined": A.pre_name(component, op) in names and A.post_name(component, op) in names}
            per_op[op] = info
            if not info["defined"]:
                lines.append(f"- {op}: define both `{A.pre_name(component, op)}` and `{A.post_name(component, op)}`")
                continue
            w = example_witness(self.l0[op])
            if not w:
                info["satisfiable"] = info["vacuous"] = None
                continue
            inp, out = w
            pre, post, s = A.pre_name(component, op), A.post_name(component, op), A.slug(op)
            tac = f"by first | (simp only [{unfold}, L0_{s}.Spec] <;> decide) | (unfold {pre} {post} <;> decide)"
            examples.append(f"example : {pre} {inp} := {tac}"); index.append((op, "pre"))
            examples.append(f"example : {post} {inp} {out} := {tac}"); index.append((op, "post"))
            outs = field_types(self.l0[op]).get("Output", {})
            fields = literal_fields(out)
            for f, v in fields.items():
                for m in _mutants(v, outs.get(f, "")):
                    if m.strip() == v.strip():
                        continue
                    mut = "{ " + ", ".join(f"{k} := {(m if k == f else x)}" for k, x in fields.items()) + " }"
                    examples.append(f"example : ¬ {post} {inp} {mut} := {tac}"); index.append((op, "c-mut"))
                    examples.append(f"example : ¬ L0_{s}.Spec.post {inp} {mut} := by simp only [L0_{s}.Spec] <;> decide")
                    index.append((op, "l0-mut"))
        # One Lean run: the code, then every example. Errors are attributed by line.
        r = check_lean(prefix + ("\n\n" + "\n\n".join(examples) if examples else ""))
        errs = [] if r["success"] else parse_errors(r["error"])
        first = HEADER.count("\n") + prefix.count("\n") + 3
        if not r["success"] and (not errs or any(e["line"] < first for e in errs)):
            r0 = r if not examples else check_lean(prefix)  # clean feedback without the examples
            if not r0["success"]:
                return {"ok": False, "stage": "lean", "error": r0["error"],
                        "text": format_feedback(code, r0["error"], ctx)}
        if examples:
            starts, line = [], first
            for ex in examples:
                starts.append(line)
                line += ex.count("\n") + 2
            failed = [False] * len(examples)
            if not r["success"] and not errs:  # e.g. a timeout: no example counts as passing
                failed = [True] * len(examples)
            for e in errs:
                k = max((i for i, st in enumerate(starts) if e["line"] >= st), default=None)
                if k is not None:
                    failed[k] = True
            for (op, kind), bad_ex in zip(index, failed):
                info, ok = per_op[op], not bad_ex
                if kind == "pre":
                    info["pre_holds"] = ok
                elif kind == "post":
                    info["post_holds"] = ok
                elif kind == "c-mut":
                    info["c_rejects"] = info.get("c_rejects", 0) + ok
                else:
                    info["l0_rejects"] = info.get("l0_rejects", 0) + ok
        bad = False
        for op in ops:
            info = per_op[op]
            if not info.get("defined"):
                bad = True
                continue
            if "pre_holds" in info:
                info["satisfiable"] = info["pre_holds"] and info["post_holds"]
                info["pre_false"] = not info["pre_holds"]
                info["vacuous"] = (info.get("l0_rejects", 0) > 0 and info.get("c_rejects", 0) == 0)
                if info["pre_false"]:
                    lines.append(f"- {op}: `pre` is false on the L0 example input "
                                 f"{example_witness(self.l0[op])[0]}; the L0 spec accepts it")
                elif not info["post_holds"]:
                    lines.append(f"- {op}: `post` rejects the L0 example (input, output) "
                                 f"{example_witness(self.l0[op])[0]} → {example_witness(self.l0[op])[1]}, "
                                 "which the L0 spec accepts")
                if info["vacuous"]:
                    lines.append(f"- {op}: `post` is vacuous: it accepts every changed output we tried, "
                                 "but the L0 `post` rejects some of them")
                bad = bad or not info["satisfiable"] or info["vacuous"]
        self.code[component] = code
        missing = [o for c in self.components if c["id"] == component for o in c["operations"] if o not in ops]
        head = "Contract compiles." + (f" Not yet defined: {', '.join(missing)}." if missing else "")
        text = head + ("\nProblems:\n" + "\n".join(lines) if lines else " Satisfiable and not vacuous.")
        return {"ok": not bad, "stage": "check" if bad else "ok", "text": text, "ops": per_op}

    # -- obligations --------------------------------------------------------------------------

    def _component_defs(self, component: str) -> str:
        return self.code.get(component, "")

    def trace_theorems(self, component: str, op: str, proofs: Optional[Dict[str, str]] = None) -> Dict[str, str]:
        st = A.trace_statements(component, op)
        helpers = def_names(self._component_defs(component))
        out = {}
        for part in ("pre", "post"):
            key = f"trace_{part}:{component}:{op}"
            proof = (proofs or {}).get(part) or self.proofs.get(key) or A.auto_trace_proof(component, op, helpers)
            out[part] = A.theorem(st[part], proof)
        return out

    def check_traces(self, component: str, ops: Sequence[str], proofs: Optional[Dict[str, Dict[str, str]]] = None) -> dict:
        """Trace obligations of several operations of one component in one Lean run (errors
        attributed by line). `proofs` = {op: {"pre"/"post": proof body}} replaces the automatic
        proof; a model proof that fails is retried with the automatic one."""
        code = self._component_defs(component)
        if not code:
            return {"ok": False, "text": f"No contract code for `{component}` yet: call check_contract first.",
                    "parts": {}}
        for op, ps in (proofs or {}).items():
            for part, body in ps.items():
                if body:
                    self.proofs[f"trace_{part}:{component}:{op}"] = body
        ctx = self.op_context(self._ops_in(component, code) or list(ops))
        prefix = ctx + "\n\n" + code
        todo = [(op, part) for op in ops for part in ("pre", "post")]
        outcome: Dict[Tuple[str, str], Tuple[bool, str, List[str]]] = {}
        for round_ in ("given", "auto"):
            if round_ == "auto":  # failed model proofs: try the automatic proof instead
                todo = [(op, p) for (op, p), (ok, by, _) in outcome.items() if not ok and by == "model"]
                if not todo:
                    break
            thms, keys = [], []
            for op, part in todo:
                key = f"trace_{part}:{component}:{op}"
                auto = round_ == "auto" or key not in self.proofs
                body = A.auto_trace_proof(component, op, def_names(code)) if auto else self.proofs[key]
                thms.append(A.theorem(A.trace_statements(component, op)[part], body))
                keys.append((op, part, "auto" if auto else "model"))
            r = check_lean(prefix + "\n\n" + "\n\n".join(thms))
            errs = [] if r["success"] else parse_errors(r["error"])
            first = HEADER.count("\n") + prefix.count("\n") + 3
            starts, line = [], first
            for t in thms:
                starts.append(line)
                line += t.count("\n") + 2
            msgs = [[] for _ in thms]
            context_error = not r["success"] and (not errs or any(e["line"] < first for e in errs))
            for e in errs:
                k = max((i for i, st in enumerate(starts) if e["line"] >= st), default=None)
                if k is not None:
                    msgs[k].append(_trim(e["msg"]))
            for (op, part, by), m in zip(keys, msgs):
                ok = r["success"] or (not m and not context_error)
                if context_error and not m:
                    m = _errors(r["error"])
                if round_ == "auto" and ok:
                    self.proofs.pop(f"trace_{part}:{component}:{op}", None)
                outcome[(op, part)] = (ok, by, m[:MAX_ERRORS])
        out, texts = {}, []
        for (op, part), (ok, by, m) in sorted(outcome.items()):
            key = f"trace_{part}:{component}:{op}"
            res = self.results.setdefault(key, {"attempts": 0})
            res.update(proved=ok, by=by, errors=[] if ok else m)
            res["attempts"] += 1
            out[(op, part)] = ok
            texts.append(f"{op} trace {part}: " + ("proved" if ok else "NOT proved:\n"
                                                   + "\n".join(f"  - {e}" for e in m)))
        return {"ok": all(out.values()), "text": "\n".join(texts), "parts": out}

    def check_trace(self, component: str, operation: str, proof_pre: str = "", proof_post: str = "") -> dict:
        """Does the contract cover that L0 spec (assume no more, guarantee at least as much)?
        The statements are the harness's; a proof body given here replaces the automatic one."""
        if self.owner.get(operation) != component:
            return {"ok": False, "text": f"`{operation}` is not owned by `{component}`.", "parts": {}}
        r = self.check_traces(component, [operation], {operation: {"pre": proof_pre, "post": proof_post}})
        r["parts"] = {part: ok for (_, part), ok in r["parts"].items()}
        return r

    def _full_text(self, upto: Optional[int] = None, with_traces: bool = True) -> str:
        """Locked context + contract code, contract definitions and proved trace theorems of
        the first `upto` components of the chain."""
        parts = [PRELUDE + self.locked]
        for c in self.components[:upto]:
            cid = c["id"]
            parts.append(self._component_defs(cid))
            parts.append(A.contract_def(self.G, cid, c["operations"], list(self.l0)))
            if with_traces:
                for op in c["operations"]:
                    for part, thm in self.trace_theorems(cid, op).items():
                        if self.results.get(f"trace_{part}:{cid}:{op}", {}).get("proved"):
                            parts.append(thm)
        return "\n\n".join(p for p in parts if p)

    def _needs_traces(self, keys: List[str]) -> List[str]:
        return [k for k in keys if not self.results.get(k, {}).get("proved")]

    def check_po1(self, a: str, b: str, proof: str = "") -> dict:
        """PO1 `Contract.Compatible aContract bContract` for consecutive components a, b."""
        if a not in self.order or b not in self.order or self.order.index(b) != self.order.index(a) + 1:
            return {"ok": False, "text": f"PO1 is checked for consecutive components of the chain {self.order}."}
        key = f"po1:{a}:{b}"
        missing = self._needs_traces([f"trace_pre:{b}:{o}" for o in self.components[self.order.index(b)]["operations"]])
        if proof:
            self.proofs[key] = proof
        auto = A.auto_po1_proof(self.G, a, b, self.owner, list(self.l0))
        stmt = A.po1_statement(a, b)
        ctx = self._full_text(self.order.index(b) + 1)
        tries = ([("model", self.proofs[key])] if key in self.proofs else []) + ([] if missing else [("auto", auto)])
        res = self.results.setdefault(key, {"attempts": 0})
        res["attempts"] += 1
        errors = [f"needs the trace `pre` lemmas of {b} first: {', '.join(missing)}"] if missing else []
        for by, p in tries:
            r = check_lean(ctx + "\n\n" + A.theorem(stmt, p))
            if r["success"]:
                res.update(proved=True, by=by, errors=[])
                return {"ok": True, "text": f"PO1 {a} → {b}: proved ({by})."}
            errors = _errors(r["error"])
        res.update(proved=False, by=None, errors=errors)
        return {"ok": False, "text": f"PO1 {a} → {b}: NOT proved.\nStatement:\n{stmt}\nErrors:\n"
                + "\n".join(f"- {e}" for e in errors)}

    def check_po2(self, proof: str = "") -> dict:
        """PO2 `Contract.Refines (chain) SystemSpec`, chain in the graph's order."""
        key = "po2"
        if proof:
            self.proofs[key] = proof
        need = [f"trace_{p}:{c['id']}:{o}" for c in self.components for o in c["operations"] for p in ("pre", "post")]
        need = [k for k in need if k.startswith("trace_post") or k.split(":")[1] == self.order[0]]
        missing = self._needs_traces(need)
        stmt = A.po2_statement(self.G, self.order)
        auto = A.auto_po2_proof(self.G, self.order, self.owner, list(self.l0))
        tries = ([("model", self.proofs[key])] if key in self.proofs else []) + ([] if missing else [("auto", auto)])
        res = self.results.setdefault(key, {"attempts": 0})
        res["attempts"] += 1
        errors = [f"needs {len(missing)} trace lemmas first, e.g. {missing[0]}"] if missing else []
        ctx = self._full_text()
        for by, p in tries:
            r = check_lean(ctx + "\n\n" + A.theorem(stmt, p))
            if r["success"]:
                res.update(proved=True, by=by, errors=[])
                return {"ok": True, "text": f"PO2: proved ({by})."}
            errors = _errors(r["error"])
        res.update(proved=False, by=None, errors=errors)
        return {"ok": False, "text": f"PO2: NOT proved.\nStatement:\n{stmt}\nErrors:\n"
                + "\n".join(f"- {e}" for e in errors)}

    # -- final -------------------------------------------------------------------------------

    def obligations(self) -> List[str]:
        keys = [f"trace_{p}:{c['id']}:{o}" for c in self.components for o in c["operations"] for p in ("pre", "post")]
        keys += [f"po1:{a}:{b}" for a, b in zip(self.order, self.order[1:])]
        return keys + ["po2"]

    def arch_file(self) -> str:
        """Arch.lean: everything proved, compiling on its own from the repo root. Obligations
        that are not proved appear as comments with their statement."""
        res = lambda k: self.results.get(k, {}).get("proved")  # noqa: E731
        parts = [HEADER.rstrip(), f"-- L1 architecture of {self.G} (generated; statements by the harness)",
                 f"-- locked context sha {self.locked_hash}; chain: {' → '.join(self.order)}",
                 PRELUDE + self.locked]
        for c in self.components:
            cid = c["id"]
            parts.append(f"-- ===== component {cid} =====")
            parts.append(self._component_defs(cid) or f"-- (no contract code for {cid})")
            if not self._component_defs(cid):
                continue
            parts.append(A.contract_def(self.G, cid, c["operations"], list(self.l0)))
            for op in c["operations"]:
                for part, thm in self.trace_theorems(cid, op).items():
                    if res(f"trace_{part}:{cid}:{op}"):
                        parts.append(thm)
                    else:
                        parts.append("-- NOT PROVED: " + A.trace_statements(cid, op)[part])
        for a, b in zip(self.order, self.order[1:]):
            k = f"po1:{a}:{b}"
            if res(k):
                proof = self.proofs.get(k) or A.auto_po1_proof(self.G, a, b, self.owner, list(self.l0))
                parts.append(A.theorem(A.po1_statement(a, b), proof))
            else:
                parts.append("-- NOT PROVED: " + A.po1_statement(a, b))
        if res("po2"):
            proof = self.proofs.get("po2") or A.auto_po2_proof(self.G, self.order, self.owner, list(self.l0))
            parts.append(A.theorem(A.po2_statement(self.G, self.order), proof))
            if all(res(f"po1:{a}:{b}") for a, b in zip(self.order, self.order[1:])):
                parts.append(A.system_sound_theorem(self.G, self.order))
        else:
            parts.append("-- NOT PROVED: " + A.po2_statement(self.G, self.order))
        return "\n\n".join(p for p in parts if p) + "\n"

    def submit_architecture(self, expected_locked_hash: Optional[str] = None) -> dict:
        """Final verdict. Rebuilds the locked context from its sources and compares the hash,
        re-checks every component's code, reruns every obligation from scratch (earlier results
        are discarded), then compiles the whole Arch.lean once."""
        problems = []
        rebuilt = sha(self._locked_text())
        if rebuilt != self.locked_hash or (expected_locked_hash and expected_locked_hash != self.locked_hash):
            problems.append("locked context changed (Domain.lean, an L0 spec or the system spec)")
        if self.require_split and len(self.order) < 2 and len(self.l0) > 1:
            problems.append("a single component is not a decomposition")
        if self.placeholders:
            problems.append(f"{len(self.placeholders)} operations have no contract from the model "
                            f"(harness placeholders): {', '.join(self.placeholders[:5])}")
        old_proofs = dict(self.proofs)
        self.results = {}
        contracts = {}
        for c in self.components:
            cid = c["id"]
            code = self.code.get(cid, "")
            r = self.check_contract(cid, code) if code else {"ok": False, "text": "no code"}
            contracts[cid] = {"ok": r["ok"], "ops": r.get("ops", {}), "text": r["text"][:500]}
            if code:
                self.code[cid] = code
                given = {op: {p: old_proofs.get(f"trace_{p}:{cid}:{op}", "") for p in ("pre", "post")}
                         for op in c["operations"]}
                self.check_traces(cid, c["operations"], given)
        for a, b in zip(self.order, self.order[1:]):
            self.check_po1(a, b, old_proofs.get(f"po1:{a}:{b}", ""))
        if len(self.order) >= 1 and all(self.code.get(c) for c in self.order):
            self.check_po2(old_proofs.get("po2", ""))
        text = self.arch_file()
        whole = check_lean(text)
        if not whole["success"]:
            problems.append("Arch.lean does not compile: " + "; ".join(_errors(whole["error"], 2)))
        proved = {k: bool(self.results.get(k, {}).get("proved")) for k in self.obligations()}
        ok = not problems and all(proved.values()) and all(v["ok"] for v in contracts.values())
        return {"ok": ok, "problems": problems, "contracts": contracts, "proved": proved,
                "arch_compiles": whole["success"], "arch": text,
                "text": ("ACCEPTED" if ok else "REJECTED") + f": {sum(proved.values())}/{len(proved)} obligations proved"
                        + ("; " + "; ".join(problems) if problems else "")}

    # -- agent-mode dispatch -----------------------------------------------------------------

    def call(self, name: str, args: dict) -> str:
        """Run tool `name` for the model; always returns text (errors included)."""
        try:
            fn = {
                "get_graph_summary": lambda: self.get_graph_summary(),
                "get_component": lambda: self.get_component(args["component"]),
                "get_l0_spec": lambda: self.get_l0_spec(args["operation"]),
                "get_domain_types": lambda: self.get_domain_types(),
                "lookup_name": lambda: self.lookup_name(args["name"]),
                "check_lean": lambda: self.check_lean(args["code"]),
                "check_contract": lambda: self.check_contract(args["component"], args["code"])["text"],
                "check_trace": lambda: self.check_trace(args["component"], args["operation"],
                                                        args.get("proof_pre", ""), args.get("proof_post", ""))["text"],
                "check_po1": lambda: self.check_po1(args["a"], args["b"], args.get("proof", ""))["text"],
                "check_po2": lambda: self.check_po2(args.get("proof", ""))["text"],
                "submit_architecture": lambda: self.submit_architecture()["text"],
            }[name]
            out = fn()
        except KeyError as e:
            out = f"error: unknown tool or missing argument {e}"
        except Exception as e:  # a tool must never crash the agent loop
            out = f"error: {type(e).__name__}: {e}"
        return self.log(name, args, out)


def _fn(name: str, desc: str, props: Optional[dict] = None, required: Sequence[str] = ()) -> dict:
    return {"type": "function", "function": {
        "name": name, "description": desc,
        "parameters": {"type": "object", "properties": props or {}, "required": list(required)}}}


_S = {"type": "string"}
TOOLS = [
    _fn("get_graph_summary", "Components of this system in chain order, edges between them, merged cycles."),
    _fn("get_component", "One component: its operations, entities, neighbours and the defs it must provide.",
        {"component": _S}, ["component"]),
    _fn("get_l0_spec", "The locked L0 spec (Lean) of one operation and its requirement sentence.",
        {"operation": _S}, ["operation"]),
    _fn("get_domain_types", "The locked Domain.lean types."),
    _fn("lookup_name", "The 3 closest real Lean names to a name you are unsure of.", {"name": _S}, ["name"]),
    _fn("check_lean", "Type-check Lean code after the locked context. Returns ok or the first 3 errors.",
        {"code": _S}, ["code"]),
    _fn("check_contract", "Check a component's contract code (its `<C>_pre_<op>`/`<C>_post_<op>` defs): "
        "compiles, satisfiable on the L0 example, `pre` not false, `post` not vacuous.",
        {"component": _S, "code": _S}, ["component", "code"]),
    _fn("check_trace", "Prove the component covers one L0 spec (harness-written statements). Optional "
        "proof bodies replace the automatic proof.",
        {"component": _S, "operation": _S, "proof_pre": _S, "proof_post": _S}, ["component", "operation"]),
    _fn("check_po1", "Prove PO1 Contract.Compatible aContract bContract for consecutive components.",
        {"a": _S, "b": _S, "proof": _S}, ["a", "b"]),
    _fn("check_po2", "Prove PO2: the chain of contracts refines the system spec.", {"proof": _S}),
    _fn("submit_architecture", "Final check: reruns every check and obligation and gives the verdict."),
]


def check_decomposition(components: List[dict], ops: Sequence[str]) -> List[str]:
    """No-graph mode: the model's decomposition must cover every operation exactly once, use
    Lean-safe distinct names, and have at least two components when there are two operations."""
    problems, seen = [], {}
    names = [c.get("id") or c.get("name") for c in components]
    for n in names:
        if not n or not re.fullmatch(r"[A-Z][A-Za-z0-9]*", str(n)):
            problems.append(f"component name `{n}` must be CamelCase letters/digits")
    if len(set(names)) != len(names):
        problems.append("component names must be distinct")
    for c, n in zip(components, names):
        for o in c.get("operations", []):
            if o not in ops:
                problems.append(f"`{o}` is not an operation of this system")
            elif o in seen:
                problems.append(f"`{o}` is in both {seen[o]} and {n}")
            else:
                seen[o] = n
    missing = [o for o in ops if o not in seen]
    if missing:
        problems.append(f"operations in no component: {', '.join(missing)}")
    if len(ops) > 1 and len([c for c in components if c.get("operations")]) < 2:
        problems.append("a single component is not a decomposition: use at least two")
    return problems
