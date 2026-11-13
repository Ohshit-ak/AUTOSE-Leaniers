"""Checks on a per-spec chain architecture: one L0 spec `Spec : Contract Input Output` split
into `A : Contract Input Mid` and `B : Contract Mid Output`. No model calls.

The model writes only `structure Mid` and the two contracts. Everything else is here:

    static (before Lean)   `static_check`
        shape        exactly two contracts whose types chain Input → Mid → Output
        visibility   a contract only reads fields of its own two records. The usual mistake
                     (the second contract reads an `Input` field) is reported with the
                     field to add to `Mid`, not as Lean's "unknown field"
        work         each component does something: a `post` made only of copies
                     (`m.f = i.f`) or of the restated precondition is an identity; a contract
                     equal to `Spec` up to variable names is a copy of `Spec`; the second
                     contract must use what the first one computes
        strength     the facts above as a record (`facts["strength"]`), so a run can report
                     how much a decomposition adds to `Spec`, not only that PO1/PO2 hold
    Lean (after the definitions compile)   `prove_obligations`
        realizable   what the first `post` claims about fields it only copies from `Input`
                     must follow from its `pre` (a component cannot change its input)
        PO1, PO2     stated and proved by the harness (framework tactics `discharge_po1`,
                     `discharge_po2`). When one fails, each conjunct is tried on its own and
                     the feedback names the part that does not follow

        constant     a first component whose results are the same for every input that
                     satisfies its `pre` (`m.ok = true`, `m.ok = true ↔ <the pre>`) decides
                     nothing: it is an identity with a constant added, and is rejected
        PO1 repair   the parts of the second `pre` that the first `post` does not give are
                     removed by the harness (the second component must accept every `Mid`
                     the first can produce); PO1 and PO2 are then proved for the result

`single_step` says which specs are not split at all (a data constraint, or a `post` in which
no output field is stated in terms of another, so there is no intermediate result): their
architecture is `Spec` itself and PO2 is `Refines Spec Spec`.

`trivial_witness` flags a weak L0 spec: one that an implementation made only of copied input
fields and constants satisfies.
"""
import itertools
import re
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple

import po
from validate import field_types

_COMMENT = re.compile(r"--.*$", re.MULTILINE)
_DEF_CONTRACT = re.compile(r"^def\s+(\w+)\s*:\s*Contract\s+([\w.]+)\s+([\w.]+)\s*(?:where|:=)(.*?)(?=^\S|\Z)",
                           re.MULTILINE | re.DOTALL)
_PRE = re.compile(r"\bpre\s*:=\s*fun\s+(.+?)\s*=>(.*?)(?=[\n,]\s*post\s*:=|\Z)", re.DOTALL)
_POST = re.compile(r"\bpost\s*:=\s*fun\s+(.+?)\s*=>(.*?)(?=[\n,]\s*pre\s*:=|\Z)", re.DOTALL)
_TOP_DECL = re.compile(r"^(?:theorem|lemma|example)\b.*?(?=^\S|\Z)", re.MULTILINE | re.DOTALL)
_BINDER = re.compile(r"(?:∀|∃|fun|λ)\s*((?:\(?\s*[\w']+\s*(?::[^,)=]*\))?\s*)+)")
CLOSERS = "first | done | (simp_all; done) | omega | grind"   # `done`: unfolding may already close the goal


@dataclass
class Contract:
    name: str
    dom: str
    cod: str
    pre_var: str
    pre: str
    in_var: str
    out_var: str
    post: str


def strip_comments(code: str) -> str:
    return _COMMENT.sub("", code)


def _vars(binders: str) -> List[str]:
    """`i`, `_ m`, `(i : Input) (m : Mid)` → variable names."""
    return re.findall(r"[\w']+", re.sub(r":[^)]*", "", binders))


def _body(text: str) -> str:
    return text.strip().rstrip("},").strip()


def parse_contracts(code: str) -> List[Contract]:
    """Every `def X : Contract A B` with `pre := fun … => …` and `post := fun … … => …`."""
    out = []
    for m in _DEF_CONTRACT.finditer(strip_comments(code)):
        pre, post = _PRE.search(m.group(4)), _POST.search(m.group(4))
        if not pre or not post:
            continue
        pv, qv = _vars(pre.group(1)), _vars(post.group(1))
        if len(pv) != 1 or len(qv) != 2:
            continue
        out.append(Contract(m.group(1), m.group(2), m.group(3), pv[0], _body(pre.group(2)),
                            qv[0], qv[1], _body(post.group(2))))
    return out


def spec_contract(spec_code: str) -> Optional[Contract]:
    return next((c for c in parse_contracts(spec_code) if c.name == "Spec"), None)


def strip_theorems(code: str) -> str:
    """The definitions of a reply: theorems and examples are the harness's job."""
    return _TOP_DECL.sub("", code).strip()


def strip_examples(code: str) -> str:
    """`code` without its `example`s (they only cost Lean time once the code is locked)."""
    return re.sub(r"^example\b.*?(?=^\S|\Z)", "", code, flags=re.MULTILINE | re.DOTALL).strip()


def _unparen(text: str) -> str:
    text = text.strip()
    while text.startswith("(") and text.endswith(")"):
        depth = 0
        for k, c in enumerate(text):
            depth += c == "("
            depth -= c == ")"
            if depth == 0 and k < len(text) - 1:
                return text
        text = text[1:-1].strip()
    return text


def _mask(text: str) -> str:
    """`text` with everything inside brackets replaced by spaces (positions kept)."""
    out, depth = [], 0
    for c in text:
        if c in ")]}":
            depth -= 1
        out.append(c if depth == 0 else " ")
        if c in "([{":
            depth += 1
    return "".join(out)


def conjuncts(body: str) -> List[str]:
    """Top-level `∧` parts. `a ∧ b ↔ c` and `a ∧ b → c` are one condition (`∧` binds tighter),
    and a quantifier, `fun` or `if` takes everything to its right."""
    body = _unparen(body)
    if not body or body == "True":
        return []
    flat = _mask(body)
    if re.search(r"[↔→]", flat):
        return [body]
    binder = re.search(r"[∀∃λ]|\b(?:fun|if)\b", flat)
    end = binder.start() if binder else len(body)
    cuts = [k for k, c in enumerate(flat[:end]) if c == "∧"]
    parts = [body[x + 1:y] for x, y in zip([-1] + cuts, cuts + [len(body)])]
    if len(parts) == 1:
        return [body]
    return [c for p in parts for c in conjuncts(p)]


def canon(text: str, variables: List[str]) -> str:
    """Text up to variable names, spaces and outer brackets (alpha-equality, as far as text goes)."""
    for k, v in enumerate(variables):
        if v != "_":
            text = re.sub(rf"(?<![\w.']){re.escape(v)}(?![\w'])", f"«{k}»", text)
    return _unparen(re.sub(r"\s+", "", text))


def _refs(text: str, var: str) -> List[str]:
    """Fields read as `var.field` (first level)."""
    if var == "_":
        return []
    return re.findall(rf"(?<![\w.']){re.escape(var)}\.([A-Za-z_]\w*)", text)


def _mentions(text: str, var: str) -> bool:
    return var != "_" and bool(re.search(rf"(?<![\w.']){re.escape(var)}(?![\w'])", text))


def _copy(conj: str, out_var: str, in_var: str) -> Optional[Tuple[str, str]]:
    """(out field, in field) if `conj` is `out.f = in.g` (either way round)."""
    if "_" in (out_var, in_var):
        return None
    c = _unparen(conj)
    o, i = re.escape(out_var), re.escape(in_var)
    m = re.fullmatch(rf"{o}\.([\w.]+)\s*=\s*{i}\.([\w.]+)", c)
    if m:
        return m.group(1), m.group(2)
    m = re.fullmatch(rf"{i}\.([\w.]+)\s*=\s*{o}\.([\w.]+)", c)
    return (m.group(2), m.group(1)) if m else None


def _bound(text: str) -> set:
    return {v for b in _BINDER.findall(text) for v in _vars(b)}


def intermediate_results(spec_code: str) -> List[Tuple[str, List[str]]]:
    """[(condition, output fields in it)] for the conditions of `Spec.post` that relate two or
    more output fields: there one output is stated in terms of another, so the other one is
    an intermediate result a first component can compute (`o.message = … ↔ o.results = []`:
    the results come first)."""
    s = spec_contract(spec_code)
    if s is None:
        return []
    out = []
    for c in conjuncts(s.post):
        fs = list(dict.fromkeys(_refs(c, s.out_var)))
        if len(fs) >= 2:
            out.append((c, fs))
    return out


def single_step(spec_code: str, kind: Optional[str] = None) -> Optional[str]:
    """Why this spec is not split into two components, or None if it should be.

    A chain needs an intermediate result: something the first component computes and the
    second one uses. A data constraint is one validity rule. A `post` whose conditions each
    describe one output field from the input has independent parts, not stages: every split
    of it makes one component an identity (or an identity plus a constant field), which is
    what a small model produces when it is forced to split. Such specs are one component;
    their decomposition is the graph path's job (components from the requirements graph)."""
    if kind == "data_constraint":
        return "data constraint (one validity rule)"
    s = spec_contract(spec_code)
    if s is None:
        return None
    if len(conjuncts(s.post)) <= 1:
        return "`post` is a single condition"
    if not intermediate_results(spec_code):
        return "no intermediate result (no output field of `post` is stated in terms of another)"
    return None


# ---------------------------------------------------------------------------
# Static check
# ---------------------------------------------------------------------------

def _visibility(c: Contract, fields: Dict[str, dict], other_vars: Dict[str, str],
                first: Optional[Contract]) -> List[str]:
    """Problems with the fields `c` reads: each variable only has the fields of its record."""
    problems, seen = [], set()
    for var, struct, text in ((c.pre_var, c.dom, c.pre), (c.in_var, c.dom, c.post), (c.out_var, c.cod, c.post)):
        have = fields.get(struct)
        if have is None:
            continue
        for f in _refs(text, var):
            if f in have or (struct, f) in seen:
                continue
            seen.add((struct, f))
            inp = fields.get("Input", {})
            if first is not None and struct == c.dom and f in inp:
                problems.append(
                    f"`{c.name}` reads `{var}.{f}`, but `{struct}` has no field `{f}` (it is a field of "
                    f"`Input`, which `{c.name}` cannot see). Add `{f} : {inp[f]}` to `structure {struct}` "
                    f"and `{first.out_var if first.out_var != '_' else 'm'}.{f} = "
                    f"{first.in_var if first.in_var != '_' else 'i'}.{f}` to the `post` of `{first.name}`.")
            else:
                problems.append(f"`{c.name}` reads `{var}.{f}`, but `structure {struct}` has no field `{f}` "
                                f"(its fields: {', '.join(have) or 'none'}). Declare it or use an existing field.")
    own = {c.pre_var, c.in_var, c.out_var}
    local = _bound(c.pre) | _bound(c.post)
    for var, struct in sorted(other_vars.items()):
        if var in own or var in local or var == "_":
            continue
        for f in dict.fromkeys(_refs(c.pre + "\n" + c.post, var)):
            mine = c.in_var if c.in_var != "_" else c.pre_var
            typ = fields.get(struct, {}).get(f)
            fix = (f" Add `{f} : {typ}` to `structure {c.dom}`, copy it in the `post` of `{first.name}` "
                   f"and write `{mine}.{f}`." if typ and first is not None else "")
            problems.append(f"`{c.name}` uses `{var}.{f}`, but `{var}` is not one of its variables "
                            f"(`{c.name} : Contract {c.dom} {c.cod}` only sees `{c.dom}` and `{c.cod}`).{fix}")
    return problems


def static_check(code: str, spec_code: str) -> dict:
    """{"problems": [...], "facts": {...}} for an architect reply (definitions only).

    `facts` has the contract names (`a`, `b`), `mid`, the `carried` Mid fields (copies of an
    Input field), the `derived` ones (stated by the first `post` in some other way),
    `carried_claims` (to be checked in Lean) and the `strength` record."""
    problems: List[str] = [f"`{w}` is not allowed" for w in po.forbidden_words(code)]
    facts: dict = {}
    spec = spec_contract(spec_code)
    cs = [c for c in parse_contracts(code) if c.name != "Spec"]
    named = re.findall(r"^def\s+(\w+)\s*:\s*Contract\b", strip_comments(code), re.MULTILINE)
    if len(named) != 2 or len(cs) != 2:
        problems.append(f"write exactly two contracts, each as `def <Name>Contract : Contract X Y where` with "
                        f"`pre := fun x => …` and `post := fun x y => …` (found {len(named)} contract "
                        f"definitions, {len(cs)} in that form)")
        return {"problems": problems, "facts": facts}
    a, b = cs
    if a.dom != "Input" and b.dom == "Input":
        a, b = b, a
    fields = field_types(spec_code + "\n" + code)
    declared = field_types(code)
    if a.dom != "Input" or b.cod != "Output" or a.cod != b.dom or a.cod in ("Input", "Output"):
        problems.append(f"the types must chain `Input → Mid → Output`: `{a.name} : Contract Input Mid` and "
                        f"`{b.name} : Contract Mid Output` (found `Contract {a.dom} {a.cod}` and "
                        f"`Contract {b.dom} {b.cod}`)")
        return {"problems": problems, "facts": facts}
    mid = a.cod
    if mid not in declared:
        problems.append(f"declare `structure {mid}` (with `deriving DecidableEq, Repr`) before the contracts")
        return {"problems": problems, "facts": facts}
    facts.update(a=a.name, b=b.name, mid=mid)

    spec_vars = {v: "Input" for v in (spec.pre_var, spec.in_var)} if spec else {}
    if spec:
        spec_vars[spec.out_var] = "Output"
    a_vars = {a.pre_var: "Input", a.in_var: "Input", a.out_var: mid}
    problems += _visibility(a, fields, {}, None)
    problems += _visibility(b, fields, {**spec_vars, **a_vars}, a)

    # What the first component does: copies, restated/claimed facts about copies, real work.
    carried: Dict[str, str] = {}
    a_conj = conjuncts(a.post)
    for c in a_conj:
        cp = _copy(c, a.out_var, a.in_var)
        if cp:
            carried[cp[0]] = cp[1]
    pre_set = {canon(c, [a.pre_var]) for c in conjuncts(a.pre)}
    if spec:
        pre_set |= {canon(c, [spec.pre_var]) for c in conjuncts(spec.pre)}
    a_work, derived, claims, restated = [], [], [], []
    for c in a_conj:
        if _copy(c, a.out_var, a.in_var):
            continue
        on_input = c
        for mf, inf in sorted(carried.items(), key=lambda kv: -len(kv[0])):
            on_input = re.sub(rf"(?<![\w.']){re.escape(a.out_var)}\.{re.escape(mf)}(?![\w'])",
                              f"{a.in_var}.{inf}", on_input)
        if _mentions(c, a.out_var) and not _mentions(on_input, a.out_var):
            # Only about copied fields: a statement about the input itself.
            if canon(on_input, [a.in_var]) in pre_set:
                restated.append(c)
            else:
                claims.append({"conjunct": c, "on_input": on_input})
        elif _mentions(c, a.out_var):
            a_work.append(c)
            derived += [f for f in _refs(c, a.out_var) if f not in carried]
    derived = list(dict.fromkeys(derived))
    b_conj = conjuncts(b.post)
    b_work = [c for c in b_conj if _mentions(c, b.out_var) and not _copy(c, b.out_var, b.in_var)]
    b_reads = set(_refs(b.pre, b.pre_var)) | set(_refs(b.post, b.in_var))
    copies_of_spec = []
    if spec:
        key = (canon(spec.pre, [spec.pre_var]), canon(spec.post, [spec.in_var, spec.out_var]))
        copies_of_spec = [c.name for c in (a, b)
                          if (canon(c.pre, [c.pre_var]), canon(c.post, [c.in_var, c.out_var])) == key]
    strength = {
        "first_does_work": bool(a_work), "second_does_work": bool(b_work),
        "second_uses_first": bool(set(derived) & b_reads), "not_a_copy_of_spec": not copies_of_spec,
        "interface_assumption": bool(conjuncts(b.pre)),
    }
    strength["score"] = sum(strength.values())
    strength["of"] = 5
    facts.update(carried=carried, derived=derived, carried_claims=claims, restated_pre=restated,
                 first_work=a_work, second_work=b_work, copies_of_spec=copies_of_spec, strength=strength)

    m, i, o = (a.out_var if a.out_var != "_" else "m"), (a.in_var if a.in_var != "_" else "i"), \
              (b.out_var if b.out_var != "_" else "o")
    if copies_of_spec:
        problems.append(f"`{copies_of_spec[0]}` is `Spec` again (same `pre` and `post` up to variable names). "
                        "A component must be a part of the work, not the whole spec.")
    if not a_work:
        what = "only copies `Input` fields" + (" and restates the precondition" if restated or claims else "")
        problems.append(
            f"`{a.name}` is an identity: its `post` {what}, so `{b.name}` does all the work of `Spec`. "
            f"The first component must compute a result that is different for different inputs: give "
            f"`{mid}` a field for it and state it in the `post` of `{a.name}` in terms of `{i}`. A field "
            f"that is always the same (`{m}.ok = true`) does not count.")
    if not b_work:
        problems.append(
            f"`{b.name}` is an identity: its `post` only copies `{mid}` fields to `Output`, so `{a.name}` does "
            f"all the work of `Spec`. Leave part of the work to `{b.name}`: `{a.name}` states an intermediate "
            f"result in `{mid}`, and `{b.name}` states `{o}` in terms of it.")
    if a_work and b_work and not strength["second_uses_first"]:
        problems.append(
            f"`{b.name}` never reads what `{a.name}` computes ({', '.join(f'`{m}.{f}`' for f in derived) or 'nothing'}), "
            f"so the two are not a chain. State `{o}` in terms of the intermediate result.")
    return {"problems": problems, "facts": facts}


# ---------------------------------------------------------------------------
# Lean: realizability, PO1, PO2
# ---------------------------------------------------------------------------

def po_theorems(a: str, b: str) -> Dict[str, Tuple[str, List[str]]]:
    """{po: (statement, proofs to try)} for a two-component chain."""
    names = f"{a}, {b}, Spec"
    old = f"discharge_po [{names}]"
    return {"po1": (po.po1_statement(a, b), [f"discharge_po1 [{names}]", old]),
            "po2": (po.po2_statement(f"{a}.seq {b}"), [f"discharge_po2 [{names}]", old])}


def _var(v: str, fallback: str) -> str:
    return fallback if v == "_" else v


def diagnose_po1(prefix: str, a: Contract, b: Contract) -> List[str]:
    """The conjuncts of `b.pre` that `a` does not guarantee."""
    m = _var(b.pre_var, "m")
    parts = conjuncts(b.pre)
    thms = [f"example : ∀ (x__ : {a.dom}) ({m} : {a.cod}), {a.name}.pre x__ → {a.name}.post x__ {m} → ({c}) := by\n"
            f"  intro x__ {m} hpre hpost\n  simp only [{a.name}] at hpre hpost\n  {CLOSERS}" for c in parts]
    return [c for c, (ok, _) in zip(parts, po.run_theorems(prefix, thms)) if not ok]


def diagnose_po2(prefix: str, a: Contract, b: Contract, spec: Contract) -> Tuple[bool, List[str]]:
    """(does `Spec.pre` give `a.pre`?, the conjuncts of `Spec.post` the chain does not give)."""
    i, o = _var(spec.in_var, "i"), _var(spec.out_var, "o")
    parts = conjuncts(spec.post)
    thms = [f"example : ∀ ({i} : Input), Spec.pre {i} → {a.name}.pre {i} := by\n"
            f"  intro {i} h\n  simp only [Spec, {a.name}] at *\n  first | done | exact h | (simp_all; done) | omega | grind"]
    thms += [f"example : ∀ ({i} : Input) ({o} : Output), Spec.pre {i} → "
             f"(∃ y__, {a.name}.post {i} y__ ∧ {b.name}.post y__ {o}) → ({c}) := by\n"
             f"  intro {i} {o} hpre h\n  obtain ⟨y__, hA, hB⟩ := h\n"
             f"  simp only [Spec, {a.name}, {b.name}] at hpre hA hB\n"
             f"  first | done | (simp_all; done) | omega | grind | (cases {i}; cases y__; cases {o}; simp_all; done)"
             for c in parts]
    res = po.run_theorems(prefix, thms)
    return res[0][0], [c for c, (ok, _) in zip(parts, res[1:]) if not ok]


def constant_fields(prefix: str, a: Contract, fields: List[str]) -> List[str]:
    """The `fields` of the first component's result that Lean proves equal for any two inputs
    that satisfy `a.pre`: they do not depend on the input, so computing them is no work."""
    thms = [f"example : ∀ (i1__ i2__ : {a.dom}) (m1__ m2__ : {a.cod}), {a.name}.pre i1__ → {a.name}.pre i2__ → "
            f"{a.name}.post i1__ m1__ → {a.name}.post i2__ m2__ → m1__.{f} = m2__.{f} := by\n"
            f"  intro i1__ i2__ m1__ m2__ hp1 hp2 hq1 hq2\n  simp only [{a.name}] at hp1 hp2 hq1 hq2\n"
            f"  first | (simp_all; done) | omega | grind" for f in fields]
    return [f for f, (ok, _) in zip(fields, po.run_theorems(prefix, thms)) if ok]


def copied_fields(prefix: str, a: Contract, fields: List[str]) -> List[str]:
    """The `fields` of the first component's result that Lean proves equal to an `Input` field
    of the same type: copies that the text check missed (e.g. `m.f = i.f ∧ m.ok = true ↔ P`,
    which is one `↔` condition, not a copy and a decision)."""
    types = field_types(prefix)
    inp, mid = types.get(a.dom, {}), types.get(a.cod, {})
    norm = lambda t: " ".join((t or "").split())  # noqa: E731
    pairs = [(f, g) for f in fields
             for g in sorted((g for g, t in inp.items() if norm(t) == norm(mid.get(f))), key=lambda g: g != f)[:3]]
    thms = [f"example : ∀ (i__ : {a.dom}) (m__ : {a.cod}), {a.name}.pre i__ → {a.name}.post i__ m__ → "
            f"m__.{f} = i__.{g} := by\n  intro i__ m__ hp hq\n  simp only [{a.name}] at hp hq\n"
            f"  first | (simp_all; done) | omega | grind" for f, g in pairs]
    return list(dict.fromkeys(f for (f, _), (ok, _) in zip(pairs, po.run_theorems(prefix, thms)) if ok))


def contract_text(c: Contract) -> str:
    return (f"def {c.name} : Contract {c.dom} {c.cod} where\n"
            f"  pre  := fun {c.pre_var} => {c.pre}\n"
            f"  post := fun {c.in_var} {c.out_var} => {c.post}")


def replace_contract(code: str, c: Contract) -> str:
    """`code` (comments removed) with the definition of `c.name` rewritten from `c`."""
    code = strip_comments(code)
    for m in _DEF_CONTRACT.finditer(code):
        if m.group(1) == c.name:
            return code[:m.start()] + contract_text(c) + "\n\n" + code[m.end():].lstrip("\n")
    return code


def prove_obligations(spec_code: str, code: str, facts: dict) -> dict:
    """Realizability, the constant-result check, PO1 (with repair) and PO2 for definitions
    that compile.

    Returns {"problems": [...], "theorems": Lean text of po1/po2 (when both are proved),
    "proved": {"po1": bool, "po2": bool}, "code": the definitions the theorems are about
    (differs from `code` when the second `pre` was repaired), "repairs": [...],
    "constant": [first-component result fields that do not depend on the input],
    "results": [the ones that are neither constant nor copies: the real intermediate results]}."""
    prefix = strip_examples(spec_code) + "\n\n" + code
    cs = {c.name: c for c in parse_contracts(code)}
    a, b, spec = cs[facts["a"]], cs[facts["b"]], spec_contract(spec_code)
    problems: List[str] = []
    repairs: List[str] = []

    claims = facts.get("carried_claims") or []
    if claims:
        i = _var(a.in_var, "i")
        thms = [f"example : ∀ ({i} : Input), {a.name}.pre {i} → ({c['on_input']}) := by\n"
                f"  intro {i} hpre\n  simp only [{a.name}] at hpre\n  {CLOSERS}" for c in claims]
        for c, (ok, _) in zip(claims, po.run_theorems(prefix, thms)):
            c["follows_from_pre"] = ok
            if not ok:
                problems.append(
                    f"`{a.name}` cannot guarantee `{c['conjunct']}`: the fields in it are copies of `Input` "
                    f"fields, so this says `{c['on_input']}` about the input, and `{a.name}.pre` does not "
                    "ensure that. A component cannot change its input: remove this condition from "
                    f"`{a.name}.post`.")

    derived = facts.get("derived") or []
    constant = constant_fields(prefix, a, derived) if derived else []
    rest = [f for f in derived if f not in constant]
    copied = copied_fields(prefix, a, rest) if rest else []
    results = [f for f in rest if f not in copied]
    if derived and not results:
        m = _var(a.out_var, "m")
        what = []
        if constant:
            what.append(", ".join(f"`{m}.{f}`" for f in constant) + " always has the same value")
        if copied:
            what.append(", ".join(f"`{m}.{f}`" for f in copied) + " is a copy of an `Input` field")
        problems.append(
            f"`{a.name}` computes nothing: for every input that satisfies its `pre`, "
            + " and ".join(what) + ", so it is an identity "
            f"with a constant added and `{b.name}` does all the work of `Spec`. The first component must "
            f"produce a result that is different for different inputs (a filtered list, a computed value, "
            f"a decision that can be true or false under `{a.name}.pre`).")

    proved, lines = {}, []
    for key, (stmt, proofs) in po_theorems(a.name, b.name).items():
        proof, errors = po.prove(prefix, stmt, proofs)
        if not proof and key == "po1":
            # The second component must accept every Mid the first can produce: drop what
            # the first `post` does not give from the second `pre` (PO2 does not use it).
            bad = diagnose_po1(prefix, a, b)
            keep = [c for c in conjuncts(b.pre) if c not in bad]
            if bad:
                fixed = Contract(b.name, b.dom, b.cod, b.pre_var, " ∧ ".join(f"({c})" for c in keep) or "True",
                                 b.in_var, b.out_var, b.post)
                new_code = replace_contract(code, fixed)
                new_prefix = strip_examples(spec_code) + "\n\n" + new_code
                proof, errors = po.prove(new_prefix, stmt, proofs)
                if proof:
                    repairs.append(f"removed from `{b.name}.pre` (not guaranteed by `{a.name}.post`): "
                                   + "; ".join(f"`{c}`" for c in bad))
                    code, prefix, b = new_code, new_prefix, fixed
        proved[key] = proof is not None
        if proof:
            lines.append(po.theorem(stmt, proof))
            continue
        if key == "po1":
            what = ("these parts of its `pre`: " + "; ".join(f"`{c}`" for c in bad)) if bad else "its `pre`"
            problems.append(
                f"PO1 fails: `{b.name}` assumes more than `{a.name}` guarantees. `{a.name}.post` does not give "
                f"{what}. `{b.name}` must accept every `{a.cod}` that `{a.name}` can produce: remove that part "
                f"of `{b.name}.pre` (write `pre := fun _ => True` if nothing is left).")
        else:
            pre_ok, bad = diagnose_po2(prefix, a, b, spec) if spec else (True, [])
            if not pre_ok:
                problems.append(f"PO2 fails: `{a.name}.pre` must follow from `Spec.pre` (`{spec.pre}`); "
                                f"it assumes more. Use the `pre` of `Spec` for `{a.name}`.")
            if bad:
                problems.append(
                    "PO2 fails: the two contracts together do not give these parts of `Spec.post`: "
                    + "; ".join(f"`{c}`" for c in bad) + f". Whatever `Spec.post` says about the input must "
                    f"pass through `{a.cod}`: `{a.name}.post` relates `{a.cod}` to `Input` (copy a field with "
                    f"`m.f = i.f`, or state a result with `↔`), and `{b.name}.post` relates `Output` to "
                    f"`{a.cod}`. A condition that is only in `{b.name}.pre` is not guaranteed by the chain.")
            if pre_ok and not bad:
                problems.append("PO2 could not be proved: " + "; ".join(errors[:2]))
    return {"problems": problems, "proved": proved, "code": code, "repairs": repairs, "constant": constant, "results": results,
            "theorems": "\n\n".join(lines) if all(proved.values()) and not problems else ""}


# ---------------------------------------------------------------------------
# L0 strength: is the spec satisfied by copies and constants?
# ---------------------------------------------------------------------------

_DEFAULTS = {"Nat": ["0", "1"], "Int": ["0", "1"], "Bool": ["true", "false"], "String": ['""', '"x"'],
             "Float": ["0.0"]}
MAX_WITNESSES = 48


def _candidates(typ: str, inp: Dict[str, str], name: str) -> List[str]:
    typ = " ".join(typ.split())
    same = [f"x.{f}" for f, t in inp.items() if " ".join(t.split()) == typ]
    same.sort(key=lambda e: e != f"x.{name}")          # the field of the same name first
    if typ.startswith("List "):
        consts = ["[]"]
    elif typ.startswith("Option "):
        consts = ["none"]
    else:
        consts = _DEFAULTS.get(typ, [])
    return same[:3] + consts


def trivial_witness(spec_code: str) -> Optional[str]:
    """An implementation of `Spec` in which every output field is a copied input field or a
    constant, if Lean accepts one (at most MAX_WITNESSES are tried, in one Lean run). A spec
    with such a witness asks for no computation: verified code for it can be a stub. None
    when there is no witness among the candidates (or an output field has no candidate)."""
    fields = field_types(spec_code)
    inp, out = fields.get("Input"), fields.get("Output")
    if spec_contract(spec_code) is None or inp is None or not out:
        return None
    options = [_candidates(t, inp, f) for f, t in out.items()]
    if not all(options):
        return None
    bodies = ["{ " + ", ".join(f"{f} := {v}" for f, v in zip(out, combo)) + " }"
              for combo in itertools.islice(itertools.product(*options), MAX_WITNESSES)]
    thms = [f"def Trivial__{k} (x : Input) : Output :=\n  {body}\n"
            f"example : Spec.Satisfies Trivial__{k} := by\n  discharge_po3 [Spec, Trivial__{k}]"
            for k, body in enumerate(bodies)]
    for body, (ok, _) in zip(bodies, po.run_theorems(strip_examples(spec_code), thms)):
        if ok:
            return body
    return None
