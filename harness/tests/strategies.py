"""Hypothesis strategies shared by the property and metamorphic suites.

Everything here generates *text the harness reads*: Lean specs and contracts in the shape the
agents are asked for, Lean error output, SRS documents in the req_document.xsd layout, and
chain-run records in the l1l2.json layout. The generators are deliberately close to what the
pipeline sees in real runs; free-form `st.text()` is used only where a function must be total.
"""
import random
from dataclasses import dataclass, field
from typing import Dict, List
from xml.sax.saxutils import escape

from hypothesis import strategies as st

# ---------------------------------------------------------------------------
# Lean names and small expressions
# ---------------------------------------------------------------------------

_FIELD_NAMES = ["qty", "price", "stock", "total", "count", "limit", "amount", "name", "code", "items",
                "flag", "valid", "accepted", "level", "balance", "attempts", "userId", "maxLen"]
field_name = st.sampled_from(_FIELD_NAMES)
small_nat = st.integers(min_value=0, max_value=50)
var_name = st.sampled_from(["i", "o", "m", "x", "inp", "out", "req", "res", "a1", "s'"])


def fresh_vars(n: int):
    """`n` distinct variable names that are not field names."""
    return st.lists(st.sampled_from(["i", "o", "m", "x", "y", "inp", "out", "req", "res", "u", "v", "w"]),
                    min_size=n, max_size=n, unique=True)


@dataclass
class SpecModel:
    """A spec `Spec : Contract Input Output` with one defining condition per output field."""
    inputs: Dict[str, str]                 # field -> type (Nat | Bool | String)
    outputs: Dict[str, str]
    pre: List[str]                         # conditions on `i`
    post: Dict[str, str]                   # output field -> its condition (mentions `o.<field>`)
    value: Dict[str, str] = field(default_factory=dict)   # output field -> Lean expr over `x` that satisfies it

    def structures(self) -> str:
        def struct(name, fields):
            body = "\n".join(f"  {f} : {t}" for f, t in fields.items())
            return f"structure {name} where\n{body}\n  deriving DecidableEq, Repr"
        return struct("Input", self.inputs) + "\n\n" + struct("Output", self.outputs)

    def spec(self, i: str = "i", o: str = "o") -> str:
        ren = lambda t: _rename(_rename(t, "i", "\0"), "o", o).replace("\0", i)  # noqa: E731
        pre = " ∧ ".join(ren(c) for c in self.pre) or "True"
        post = " ∧ ".join(ren(c) for c in self.post.values())
        return (f"def Spec : Contract Input Output where\n  pre  := fun {i} => {pre}\n"
                f"  post := fun {i} {o} => {post}")

    def code(self, i: str = "i", o: str = "o") -> str:
        return self.structures() + "\n\n" + self.spec(i, o)


def _rename(text: str, old: str, new: str) -> str:
    import re
    return re.sub(rf"(?<![\w.']){re.escape(old)}(?![\w'])", new, text)


@st.composite
def nat_expr(draw, nats: List[str], var: str = "i") -> str:
    """A `Nat` expression over the fields `nats` of `var`."""
    kind = draw(st.sampled_from(["field", "plus", "times", "const", "sum"] if nats else ["const"]))
    f = lambda: f"{var}.{draw(st.sampled_from(nats))}"  # noqa: E731
    if kind == "field":
        return f()
    if kind == "plus":
        return f"{f()} + {draw(st.integers(1, 9))}"
    if kind == "times":
        return f"{f()} * {f()}"
    if kind == "sum":
        return f"{f()} + {f()}"
    return str(draw(small_nat))


@st.composite
def condition(draw, nats: List[str], var: str = "i") -> str:
    """A decidable condition on the `Nat` fields `nats` of `var`."""
    if not nats:
        return "True"
    f = lambda: f"{var}.{draw(st.sampled_from(nats))}"  # noqa: E731
    kind = draw(st.sampled_from(["le", "gt", "lek", "eqk"]))
    if kind == "le":
        return f"{f()} ≤ {f()}"
    if kind == "gt":
        return f"{f()} > {draw(small_nat)}"
    if kind == "lek":
        return f"{f()} ≤ {draw(small_nat)}"
    return f"{f()} = {draw(small_nat)}"


@st.composite
def spec_models(draw, min_out: int = 1, max_out: int = 4) -> SpecModel:
    """Specs in which every output field is fixed by exactly one condition of `post`."""
    in_names = draw(st.lists(field_name, min_size=1, max_size=4, unique=True))
    inputs = {f: draw(st.sampled_from(["Nat", "Nat", "Nat", "Bool", "String"])) for f in in_names}
    if "Nat" not in inputs.values():
        inputs[in_names[0]] = "Nat"
    nats = [f for f, t in inputs.items() if t == "Nat"]
    strs = [f for f, t in inputs.items() if t == "String"]
    out_names = draw(st.lists(field_name, min_size=min_out, max_size=max_out, unique=True))
    outputs, post, value = {}, {}, {}
    for f in out_names:
        kinds = ["nat", "bool"] + (["str"] if strs else [])
        k = draw(st.sampled_from(kinds))
        if k == "nat":
            e = draw(nat_expr(nats))
            outputs[f], post[f], value[f] = "Nat", f"o.{f} = {e}", _rename(e, "i", "x")
        elif k == "bool":
            c = draw(condition(nats))
            outputs[f], post[f], value[f] = "Bool", f"(o.{f} = true ↔ {c})", f"decide ({_rename(c, 'i', 'x')})"
        else:
            s = draw(st.sampled_from(strs))
            outputs[f], post[f], value[f] = "String", f"o.{f} = i.{s}", f"x.{s}"
    pre = draw(st.lists(condition(nats), max_size=2, unique=True))
    return SpecModel(inputs, outputs, [c for c in pre if c != "True"], post, value)


# Conditions that are one top-level part: no `∧`, `↔`, `→`, binder or `if` outside brackets.
@st.composite
def atom(draw, var: str = "i") -> str:
    f = lambda: f"{var}.{draw(field_name)}"  # noqa: E731
    return draw(st.sampled_from([
        f"{f()} ≤ {f()}", f"{f()} > {draw(small_nat)}", f"{f()} = {f()} + {draw(st.integers(1, 9))}",
        f"({f()} = true ↔ {f()} ≤ {draw(small_nat)})", f"({f()} > 0 ∧ {f()} < 9)",
        f"{f()}.length ≤ {draw(small_nat)}", f"(∀ e ∈ {f()}, e > {draw(small_nat)})",
        f"({f()} > 0 → {f()} = {draw(small_nat)})", f"¬ ({f()} = {draw(small_nat)})",
    ]))


# ---------------------------------------------------------------------------
# Lean error output
# ---------------------------------------------------------------------------

_MESSAGES = [
    "unexpected token ','; expected term",
    "Unknown identifier `foo`",
    "Unknown constant `String.isNumeric`",
    "Type mismatch\n  o.total\nhas type\n  Nat\nbut is expected to have type\n  Prop",
    "unsolved goals\ni : Input\n⊢ i.qty > 0",
    "Tactic `decide` proved that the proposition\n  2 + 2 = 5\nis false",
    "failed to synthesize\n  Decidable (Spec.post i o)",
    "Invalid field `foo`: The environment does not contain `Input.foo`",
    "`price` is not a field of structure `Output`",
    "`Spec` has already been declared",
]


@st.composite
def lean_errors(draw, min_size: int = 0, max_size: int = 6) -> List[dict]:
    """[{line, col, msg}] in ascending position order (as Lean prints them)."""
    n = draw(st.integers(min_size, max_size))
    lines = sorted(draw(st.lists(st.integers(1, 400), min_size=n, max_size=n)))
    return [{"line": ln, "col": draw(st.integers(0, 80)), "msg": draw(st.sampled_from(_MESSAGES))} for ln in lines]


def render_lean_output(errors: List[dict], noise: bool = False) -> str:
    out = []
    for k, e in enumerate(errors):
        if noise and k % 2 == 0:
            out.append(f"<generated>:{e['line']}:0: warning: unused variable `h`")
        out.append(f"<generated>:{e['line']}:{e['col']}: error: {e['msg']}")
    return "\n".join(out) + ("\n" if out else "")


# ---------------------------------------------------------------------------
# SRS documents (req_document.xsd layout, the part req_parser.py reads)
# ---------------------------------------------------------------------------

SENTENCES = [
    # kept: modal + state change / data relation / quantity
    "The system shall store the order in the database.",
    "The system shall validate the password before login.",
    "The system must send a confirmation to the customer.",
    "The system shall calculate the total price of the order.",
    "If the account is locked, the system shall block the login.",
    "The system shall be able to add a product in less than 2 seconds.",
    "The system shall handle 500 requests per second.",
    "The system shall support at least 100 concurrent users.",
    "Each user shall have a unique identifier.",
    "Only registered users can update the profile.",
    # dropped: no modal, vague, technology, UI, availability
    "This document describes the product.",
    "The system shall be easy to use.",
    "The interface must be user-friendly and intuitive.",
    "The system shall run on Linux with Apache.",
    "The user clicks the Add button.",
    "The system shall be available 99.9% of the time.",
    "The system shall display the home page.",
    "None",
]
SECTION_TITLES = ["Functional Requirements", "Order Processing", "Security", "Performance Requirements",
                  "Purpose", "References", "Glossary", "Product Scope", "System Overview", "User Interfaces",
                  "Accounts", "Reporting"]


@dataclass
class Section:
    sid: str
    title: str
    reqs: List[str]                      # one <req> each
    prose: List[str]                     # sentences of one <text_body>
    items: List[str]                     # <itemize> items of the same <text_body>
    children: List["Section"] = field(default_factory=list)

    def xml(self, pad: random.Random = None) -> str:
        ws = (lambda: " " * pad.randint(1, 3) + "\n" * pad.randint(0, 2)) if pad else (lambda: "")
        esc = lambda t: f"{ws()}{escape(t)}{ws()}"  # noqa: E731
        parts = [f'<p id="{self.sid}"><title>{esc(self.title)}</title>']
        if self.prose or self.items:
            body = " ".join(escape(s) for s in self.prose)
            if self.items:
                body += "<itemize>" + "".join(f"<item>{esc(t)}</item>" for t in self.items) + "</itemize>"
            parts.append(f"<text_body>{ws()}{body}{ws()}</text_body>")
        for k, r in enumerate(self.reqs, 1):
            parts.append(f'<req id="{k}"><text_body>{esc(r)}</text_body></req>')
        parts += [c.xml(pad) for c in self.children]
        parts.append("</p>")
        return "".join(parts)

    def walk(self):
        yield self
        for c in self.children:
            yield from c.walk()


@st.composite
def sections(draw, sid: str = "1", depth: int = 0) -> Section:
    s = Section(sid, draw(st.sampled_from(SECTION_TITLES)),
                draw(st.lists(st.sampled_from(SENTENCES), max_size=4)),
                draw(st.lists(st.sampled_from(SENTENCES), max_size=3)),
                draw(st.lists(st.sampled_from(SENTENCES), max_size=3)))
    if depth < 2:
        n = draw(st.integers(0, 2))
        s.children = [draw(sections(f"{sid}.{k}", depth + 1)) for k in range(1, n + 1)]
    return s


@st.composite
def documents(draw) -> List[Section]:
    n = draw(st.integers(1, 3))
    return [draw(sections(str(k))) for k in range(1, n + 1)]


def render_document(secs: List[Section], pad: random.Random = None, xmlns: str = "",
                    extra: str = "") -> bytes:
    ns = f' xmlns="{xmlns}"' if xmlns else ""
    body = "".join(s.xml(pad) for s in secs)
    return (f'<?xml version="1.0" encoding="UTF-8"?><req_document{ns}><title><title>Test SRS</title></title>'
            f"{body}{extra}</req_document>").encode("utf-8")


# ---------------------------------------------------------------------------
# Chain-run records (l1l2.json layout, with the invariants chain_pipeline.run_entry keeps)
# ---------------------------------------------------------------------------

_MODES = ["chain", "single", "single-fallback", "single-not-decomposable"]
_L1_ERRORS = ["L1: `A` is an identity: its `post` only copies `Input` fields", "L1: PO1 fails: `B` assumes more",
              "L1: PO2 fails: the two contracts together do not give", "static: write exactly two contracts"]
_L2_ERRORS = ["L2: PO3 fails: `SpecImpl` does not establish `o.total = i.price`",
              "L2: write exactly this signature", "<generated>:9:2: error: unsolved goals\n⊢ False"]


@st.composite
def l2_record(draw, contract: str, success: bool) -> dict:
    from chain_failures import classify
    err = "" if success else draw(st.sampled_from(_L2_ERRORS))
    harness_only = success and draw(st.booleans())
    fields = draw(st.lists(field_name, min_size=1, max_size=4, unique=True))
    k = len(fields) if harness_only else draw(st.integers(0, len(fields)))
    return {"contract": contract, "success": success, "attempts": 0 if harness_only else draw(st.integers(1, 5)),
            "error": err, "error_class": classify(err), "stages": ["ok"] if success else ["proof"],
            "code": f"def {contract}Impl (x : Input) : Output := sorry_free", "harness_only": harness_only,
            "fields": {"harness": fields[:k], "model": fields[k:]}}


@st.composite
def chain_record(draw, rid: str) -> dict:
    from chain_failures import classify
    from chain_pipeline import system_theorem
    kind = draw(st.sampled_from(["requirement", "data_constraint", "use_case"]))
    mode = draw(st.sampled_from(_MODES))
    ok = True if mode != "chain" else draw(st.booleans())
    contracts = (["AContract", "BContract"] if mode == "chain" else ["Spec"]) if ok else []
    err = "" if ok else draw(st.sampled_from(_L1_ERRORS))
    trivial = draw(st.booleans())
    e = {"id": rid, "kind": kind, "requirement_text": "The system shall …",
         "spec_check": {"trivial": trivial, **({"witness": "{ a := x.a }"} if trivial else {}),
                        "copy_ok": trivial and draw(st.booleans()), "l05_class": "weak" if trivial else "strong"},
         "l1": {"success": ok, "mode": mode, "attempts": draw(st.integers(0, 5)), "contracts": contracts,
                "strength": ({"score": draw(st.integers(3, 5)), "of": 5} if ok and mode == "chain" else None),
                "error": err, "error_class": classify(err), "stages": [], "code": "-- …"},
         "l2": [], "seconds": float(draw(st.integers(0, 600)))}
    if ok:
        e["l2"] = [draw(l2_record(c, draw(st.booleans()))) for c in contracts]
        if all(x["success"] for x in e["l2"]):
            e["system_theorem"] = system_theorem(contracts)
            e["full_check"] = draw(st.sampled_from([True, True, True, False]))
    return e


@st.composite
def chain_runs(draw, min_size: int = 0, max_size: int = 12) -> List[dict]:
    n = draw(st.integers(min_size, max_size))
    return [draw(chain_record(f"R{k}")) for k in range(n)]
