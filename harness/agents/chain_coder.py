# Per-contract L2 coder (chain path: main.py --until chain, e2e_l1l2.py). The per-component coder
# of the graph path (--until code) lives in coding_agent.py.
"""L2: one locked contract → implementation. The model writes the function; the harness states
and proves PO3 (`<C>.Satisfies <C>Impl`) and, when it fails, names the `post` conjunct the
implementation does not establish. Before Lean, the fields of the record the function returns
are compared with the result structure (`record_problems`): a wrong, missing or repeated field
is reported with the exact field list, not as Lean's "is not a field of structure"."""
import hashlib
import os
import re

import chain_checks as C
import po
import skeleton as S
from validate import field_types
from agents.base import generate_verified

# v11 (issue 3): spec-directed skeleton. The harness derives what `post` fixes, tries its own
# implementation when nothing is left to fill, gives the rest to the model as a skeleton, and
# turns PO3 failures into actions. CF_SKELETON=0 = chain-v4 behaviour.
SKELETON = os.getenv("CF_SKELETON", "1") == "1"

SYSTEM_PROMPT_CODER = """\
You are a coding agent for ContractForge (Lean 4).

Given ONE component contract `C : Contract A B`, implement it as a plain function
`def <C>Impl (x : A) : B`. You write ONLY the function. The harness then proves PO3
(`<C>.Satisfies <C>Impl`: for every `x` with `C.pre x`, `C.post x (<C>Impl x)` holds)
itself and tells you which part of `post` your function does not establish.

Rules:
- The spec and all contracts are already in scope and LOCKED: never repeat or change
  them. No `structure`, no `theorem`, no `example`, no `import`, no `sorry`.
- Use exactly the signature you are given. Implement ONLY the contract you are asked for.
- The function is an ordinary term: a record `{ field := …, … }` with EVERY field of the
  result type, `if … then … else …`, list functions (`List.filter`, `List.map`,
  `List.take`). Never a tactic block (`:= by …`). Lean 4 core only, no Mathlib.
- The record has exactly the fields of the RESULT type (you are given the list). The
  fields of the argument type are what you read (`x.f`); do not copy them into the result
  unless the result type has a field of that name.
- A `Bool` field that `post` describes with `o.f = true ↔ P` is `f := decide (P)`.
- Helper functions are allowed (`def <C>Impl_<name> …`), written before the function.
- Output ONLY Lean 4 code in one ```lean block.

Example, for `CheckStockContract : Contract Input Mid` with
`post := fun i m => m.price = i.price ∧ m.qty = i.qty ∧ (m.inStock = true ↔ i.qty ≤ i.stock)`
and the signature `def CheckStockContractImpl (i : Input) : Mid`:
```lean
def CheckStockContractImpl (i : Input) : Mid :=
  { price := i.price, qty := i.qty, inStock := decide (i.qty ≤ i.stock) }
```
"""

_DEF = re.compile(r"^def\s+([\w.']+)", re.MULTILINE)


def prompt_hash() -> str:
    return hashlib.sha256(SYSTEM_PROMPT_CODER.encode("utf-8")).hexdigest()[:12]


def _signature(code: str, impl: str):
    """(argument type, result type) of `def <impl> (x : A) : B`, or None."""
    m = re.search(rf"^def\s+{re.escape(impl)}\s*\(\s*[\w']+\s*:\s*([\w.]+)\s*\)\s*:\s*([\w.]+)\s*:=",
                  C.strip_comments(code), re.MULTILINE)
    return (m.group(1), m.group(2)) if m else None


def _model_proof(reply: str, name: str):
    m = re.search(rf"^theorem\s+{re.escape(name)}\b.*?:=\s*(by\b.*?)(?=^\S|\Z)", reply, re.MULTILINE | re.DOTALL)
    return m.group(1).strip() if m else None


def _records(body: str) -> list:
    """[(field names, has `with`)] for the record literals of `body` that are not inside
    another bracket (the value the function returns, in each `if` branch)."""
    out, depth, start, in_str = [], 0, None, False
    for k, ch in enumerate(body):
        if ch == '"' and body[k - 1:k] != "\\":
            in_str = not in_str
        if in_str:
            continue
        if ch in "([{":
            if ch == "{" and depth == 0:
                start = k
            depth += 1
        elif ch in ")]}":
            depth -= 1
            if ch == "}" and depth == 0 and start is not None:
                inner = body[start + 1:k]
                flat = C._mask(inner)
                out.append((re.findall(r"(?:^|,|\bwith\b)\s*([A-Za-z_][\w']*)\s*:=", flat),
                            bool(re.search(r"\bwith\b", flat))))
                start = None
    return out


def record_problems(code: str, impl: str, dom: str, cod: str, fields: dict) -> list:
    """Problems with the fields of the record(s) `impl` returns, against `structure cod`."""
    want = fields.get(cod)
    m = re.search(rf"^def\s+{re.escape(impl)}\b[^\n]*?:=(.*?)(?=^\S|\Z)", C.strip_comments(code),
                  re.MULTILINE | re.DOTALL)
    if want is None or not m:
        return []
    listing = ", ".join(f"`{f} : {t}`" for f, t in want.items())
    problems = []
    for names, has_with in _records(m.group(1)):
        unknown = [f for f in dict.fromkeys(names) if f not in want]
        repeated = [f for f in dict.fromkeys(names) if names.count(f) > 1]
        missing = [] if has_with else [f for f in want if f not in names]
        if not (unknown or repeated or missing):
            continue
        parts = []
        if unknown:
            src = [f for f in unknown if f in fields.get(dom, {})]
            parts.append(", ".join(f"`{f}`" for f in unknown) + f" {'is not a' if len(unknown) == 1 else 'are not'} "
                         f"field{'' if len(unknown) == 1 else 's'} of `{cod}`"
                         + (f" ({', '.join(f'`{f}`' for f in src)} belong{'s' if len(src) == 1 else ''} to "
                            f"`{dom}`, the argument: read as `x.{src[0]}`, never set)" if src else ""))
        if repeated:
            parts.append(", ".join(f"`{f}`" for f in repeated) + " is set more than once")
        if missing:
            parts.append("missing: " + ", ".join(f"`{f}`" for f in missing))
        problems.append(f"the record `{impl}` returns does not match `structure {cod}`: " + "; ".join(parts)
                        + f". `{cod}` has exactly these fields: {listing}. Write "
                        "`{ " + ", ".join(f"{f} := …" for f in want) + " }` and nothing else.")
        break
    return problems


def diagnose_po3(prefix: str, c: C.Contract, impl: str, unfold: str) -> list:
    """The conjuncts of `c.post` that `impl` does not establish."""
    i = c.in_var if c.in_var != "_" else "x__"
    parts = C.conjuncts(c.post)
    thms = []
    for part in parts:
        goal = part if c.out_var == "_" else re.sub(
            rf"(?<![\w.']){re.escape(c.out_var)}(?![\w'])", f"({impl} {i})", part)
        thms.append(f"example : ∀ ({i} : {c.dom}), {c.name}.pre {i} → ({goal}) := by\n"
                    f"  intro {i} hpre\n  (try simp only [{c.name}] at hpre)\n  (try simp only [{unfold}])\n"
                    f"  first | done | (simp_all; done) | omega | grind | (split <;> simp_all; done)")
    return [p for p, (ok, _) in zip(parts, po.run_theorems(prefix, thms)) if not ok]


def run_coder(contract_name: str, locked_code: str, model: str) -> dict:
    impl, ok_name = f"{contract_name}Impl", f"{contract_name}Impl_ok"
    contract = next((c for c in C.parse_contracts(locked_code) if c.name == contract_name), None)
    dom, cod = (contract.dom, contract.cod) if contract else ("A", "B")
    sig = f"def {impl} (x : {dom}) : {cod}"
    statement = po.po3_statement(contract_name, impl, ok_name)
    locked_defs = C.strip_examples(locked_code)
    fields = field_types(locked_code)
    state = {"model_proof": None}

    def prepare(code: str) -> str:
        state["model_proof"] = _model_proof(code, ok_name) or state["model_proof"]
        return C.strip_theorems(code)

    def precheck(code: str) -> list:
        problems = [f"`{w}` is not allowed" for w in po.forbidden_words(code)]
        if impl not in _DEF.findall(code):
            return problems + [f"define the function with exactly this signature: `{sig} := …`"]
        got = _signature(code, impl)
        if contract and got and got != (dom, cod):
            problems.append(f"`{impl}` has type `{got[0]} → {got[1]}`, but `{contract_name} : Contract {dom} {cod}` "
                            f"needs `{dom} → {cod}`. Use exactly: `{sig} := …`")
        if re.search(rf"^def\s+{re.escape(impl)}\b[^\n]*:=\s*by\b", code, re.MULTILINE):
            problems.append("the implementation must be a term (a record, `if … then … else`), not `:= by …`")
        return problems + record_problems(code, impl, dom, cod, fields)

    def validate(code: str) -> list:
        prefix = locked_defs + "\n\n" + code
        unfold = ", ".join(dict.fromkeys([contract_name] + _DEF.findall(code)))
        proofs = [f"discharge_po3 [{unfold}]", f"discharge_po [{unfold}]"]
        if state["model_proof"]:
            proofs.append(state["model_proof"])
        proof, errors = po.prove(prefix, statement, proofs)
        if proof:
            state["proved"] = (code, po.theorem(statement, proof))
            return []
        bad = diagnose_po3(prefix, contract, impl, unfold) if contract else []
        state["bad"] = bad
        if bad:
            msg = (f"PO3 fails: for an input that satisfies `{contract_name}.pre`, `{impl}` does not establish "
                   f"these parts of `{contract_name}.post`: " + "; ".join(f"`{c}`" for c in bad)
                   + ". Change the function so that they hold (the contract is locked).")
            if SKELETON:
                msg += " What to do: " + " ".join(
                    f"({k}) {S.action_for(c, contract, fields)}." for k, c in enumerate(bad[:3], 1))
            return [msg]
        return ["PO3 could not be proved: " + "; ".join(errors[:2])]

    sk = S.build(contract, fields, impl) if (SKELETON and contract) else None

    def strategy_hint(code: str, error: str):
        """Ladder strategy (2): start again from the harness skeleton, with the actions."""
        text = S.prompt_text(sk) if sk else ""
        if state.get("bad"):
            text += ("\n\nEvery previous attempt failed on: " + "; ".join(f"`{c}`" for c in state["bad"][:3])
                     + ". " + " ".join(S.action_for(c, contract, fields) + "." for c in state["bad"][:3]))
        return text.strip() or None

    # Nothing left to fill: the harness's own implementation (correct by construction for the
    # conjuncts it came from) goes to PO3 first, without a model call.
    if sk is not None and sk.complete and sk.values:
        own = S.render(sk)
        if not precheck(own) and not validate(own):
            code, thm = state["proved"]
            return {"name": contract_name, "impl": impl, "success": True, "code": code + "\n\n" + thm,
                    "attempts": 0, "log": [{"attempt": 0, "stage": "ok", "fixups": ["harness skeleton"]}],
                    "harness_only": True, "fields": S.provenance(code, sk)}

    prompt = (f"Code already in scope (LOCKED, do not repeat it):\n\n{locked_code}\n\n"
              f"Implement ONLY `{contract_name}` with exactly this signature:\n`{sig} := …`"
              + (f"\nThe result type `{cod}` has exactly these fields: "
                 + ", ".join(f"`{f} : {t}`" for f, t in fields[cod].items()) + "." if fields.get(cod) else ""))
    if sk is not None:
        text = S.prompt_text(sk)
        if text:
            prompt += "\n\n" + text
    result = generate_verified(prompt, SYSTEM_PROMPT_CODER, model, context=locked_code, validate=validate,
                               precheck=precheck, prepare=prepare, check_weakened=False, check_label="L2",
                               strategy_hint=strategy_hint if sk is not None else None)
    if result["success"]:
        code, thm = state["proved"]
        result["code"] = code + "\n\n" + thm
        result["fields"] = S.provenance(code, sk)
    result["harness_only"] = False
    return {"name": contract_name, "impl": impl, **result}
