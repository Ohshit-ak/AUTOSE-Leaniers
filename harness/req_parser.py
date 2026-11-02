"""Deterministic requirements parser: SRS XML (req_document.xsd) -> JSON.

No model calls. The same XML bytes always give the same JSON bytes: output
order follows document order, ids come from the document, and nothing depends
on time, randomness, hash seeds or the input's location.

Statements that cannot be stated as a Lean proposition (vague quality words,
platform/technology choices, UI steps, non-normative sections) are moved to
`dropped` with the rule that removed them, so the filter can be audited.

Usage (from harness/):
    python req_parser.py "../Requirements/0000 - gamma j.xml" -o out.json
"""
import argparse
import hashlib
import json
import re
import sys
import unicodedata
import xml.etree.ElementTree as ET
from decimal import Decimal
from pathlib import Path
from typing import Dict, List, Optional, Tuple

SCHEMA_VERSION = "1.0"

# ---------------------------------------------------------------------------
# Filter vocabulary. Every keep/drop decision is made from these lists.
# ---------------------------------------------------------------------------

# Sections (matched as substrings of any ancestor title) that describe the
# document, the product or the project rather than system behaviour.
EXCLUDED_SECTIONS = (
    "purpose",
    "document conventions",
    "intended audience",
    "references",
    "product perspective",
    "product features",
    "user classes",
    "user documentation",
    "assumptions and dependencies",
    "description and priority",
    "stimulus/response",
    "user interfaces",
    "hardware interfaces",
    "usability requirements",
    "portability requirements",
    "testability requirements",
    "analysis models",
    "issues list",
    "glossary",
)

# Sections that summarise the product (scope, overview). Their sentences repeat
# the requirements in general terms, so only the ones with a quantity or a data
# relation ("the initial inventory will be 100 items") are kept.
OVERVIEW_SECTIONS = re.compile(r"\b(scope|overview)\b", re.I)

MODAL = re.compile(r"\b(shall|must|will|should|can|(?:is|are) required to)\b", re.I)

# Platform and technology choices: true or false of a deployment, not of the
# system's behaviour, so there is nothing for Lean to prove.
TECH = re.compile(
    r"\b(internet explorer|netscape|mozilla|firefox|opera|safari|web browsers?|"
    r"browsers?|linux|slackware|apache|sql|usb|yoggie|intel|xscale|sdram|flash ram|"
    r"chipset|firestarter|firewall|https|ssl|secure socket layer|operating system|cpu)\b",
    re.I,
)

# Words with no measurable meaning. A statement containing one is dropped
# unless it also carries a quantity or a data relation (DATA_RELATION).
VAGUE = re.compile(
    r"\b(easy to \w+|easy|easily|easier|user[- ]friendly|friendly|intuitive|unambiguous|"
    r"clearly|clear|consistent|quickly|quick|faster|fast|well[- ]documented|extremely|"
    r"simple|flexible|reliable|reliability|robust|efficiently|efficient|appropriate|"
    r"adequate|various|variety|generally|significant|portable|interchangeable|periodic|"
    r"too large|major|basic|advanced|in the future|plug and play|may|might|could|"
    r"suggested|etc)\b",
    re.I,
)

# State changes, checks and data relations: the things a Contract's pre/post
# can talk about.
STATE_OP = re.compile(
    r"\b(creates?|created|add(?:s|ed)?|remov(?:e|es|ed)|delet(?:e|es|ed|ion)|"
    r"stor(?:e|es|ed)|updat(?:e|es|ed)|alter(?:s|ed)?|chang(?:e|es|ed)|edit(?:s|ed)?|"
    r"revis(?:e|es|ed)|validat(?:e|es|ed)|verif(?:y|ies|ied)|encrypt(?:s|ed)?|"
    r"calculat(?:e|es|ed)|comput(?:e|es|ed)|terminat(?:e|es|ed)|install(?:s|ed)?|"
    r"sends?|sent|receiv(?:e|es|ed)|transmit(?:s|ted)?|detect(?:s|ed)?|block(?:s|ed)?|"
    r"logs|log(?:ged)?[- ]?in|log(?:ged)?[- ]?out|logout|login|compress(?:es|ed)?|"
    r"restor(?:e|es|ed)|retriev(?:e|es|ed)|search(?:es|ed)?|confirm(?:s|ed)?|"
    r"confirmation|register(?:s|ed)?|contain(?:s|ed)?|includ(?:e|es|ed)|"
    r"recogniz(?:e|es|ed)|reserv(?:e|es|ed)|approv(?:e|es|ed)|transfer(?:s|red)?|"
    r"append(?:s|ed)?|unique(?:ly)?|total|number of|sum|"
    # filtering, ordering and limiting what is returned or shown
    r"not be (?:displayed|shown|listed|included|returned)|filter(?:s|ed)?|"
    r"exclud(?:e|es|ed)|sort(?:s|ed)?|arranged in|order(?:ed)? by|in (?:\w+/)*\w+ order|"
    r"ascending|descending|alphabetical(?:ly)?)\b",
    re.I,
)
# Words that make a requirement conditional on the input or the state: `pre` should say
# something. Without them `pre := True` is expected (e.g. "the system shall encrypt …").
PRECONDITION_CUE = re.compile(
    r"\b(if|when|whenever|only|unless|once|provided(?: that)?|as long as|in case|"
    r"logged[- ]?in|signed[- ]?in|authenticated|authori[sz]ed|registered)\b", re.I)

DATA_RELATION = re.compile(r"\b(total|number of|sum|unique(?:ly)?)\b", re.I)
# Nouns that look like STATE_OP verbs ("Web Store"); blanked before matching.
NOT_AN_OP = re.compile(r"\b(?:web|online) store\b", re.I)

# Use-case steps.
UI_SYSTEM_VERB = re.compile(r"^(?:the )?system (displays|prompts|presents|shows)\b", re.I)
SYSTEM_STEP = re.compile(r"^(?:the )?system\b", re.I)
CLICK = re.compile(r"\bclicks?\b", re.I)
USER_EVENT = re.compile(r"\b(incorrect|invalid|terminates|confirms|cancels)\b", re.I)
GOTO = re.compile(r"\bgo(?:es)? to step (\d+)", re.I)
STEP_LABEL = re.compile(r"^(?:([A-Z])(\d+)|(\d+))\.\s*")
STEP_SPLIT = re.compile(r"\s+(?=(?:[A-Z]\d+|\d+)\.\s+[A-Z])")

ITEM_LABEL = re.compile(r"^([A-Z]{1,4}-\d+(?:\.\d+)*)\s*:\s*(.+)$")
SENTENCE_SPLIT = re.compile(r"(?:(?<=[.!?])|(?<=[.!?][\"')]))\s+(?=[A-Z\"'(])")

# Quantities.
_NUM = r"(\d{1,3}(?:,\d{3})+|\d+(?:\.\d+)?)"
_CMP = (r"(?:(less than|fewer than|under|within|at most|no more than|up to|"
        r"more than|greater than|at least|no less than)\s+)?")
TIME_RE = re.compile(_CMP + _NUM + r"\s*(ms|milliseconds?|seconds?|secs?|minutes?|mins?|hours?)\b", re.I)
RATE_RE = re.compile(_NUM + r"\s+([a-z]+)\s+per\s+(second|minute|hour)\b", re.I)
COUNT_RE = re.compile(_CMP + _NUM + r"\s+(customers|users|products|items|records|requests|orders|sessions|results|entries|"
                      r"rows|pages|files|messages|documents|accounts|transactions|attempts)\b", re.I)
PERCENT_RE = re.compile(_NUM + r"\s*%")

CMP_SYMBOL = {
    "less than": "<", "fewer than": "<", "under": "<",
    "within": "<=", "at most": "<=", "no more than": "<=", "up to": "<=",
    "more than": ">", "greater than": ">",
    "at least": ">=", "no less than": ">=",
}
MICROS = {"ms": 1000, "millisecond": 1000, "milliseconds": 1000,
          "s": 10**6, "sec": 10**6, "secs": 10**6, "second": 10**6, "seconds": 10**6,
          "min": 60 * 10**6, "mins": 60 * 10**6, "minute": 60 * 10**6, "minutes": 60 * 10**6,
          "hour": 3600 * 10**6, "hours": 3600 * 10**6}
PER_SECOND = {"second": 1, "minute": 60, "hour": 3600}

RUNTIME_FIELD = {"latency": "elapsedMicros", "throughput": "perSecond", "concurrency": "concurrentUsers"}

# ---------------------------------------------------------------------------
# Text helpers
# ---------------------------------------------------------------------------

_PUNCT = str.maketrans({"‘": "'", "’": "'", "“": '"', "”": '"',
                        "–": "-", "—": "-"})


def clean(s: Optional[str]) -> str:
    s = unicodedata.normalize("NFKC", s or "").translate(_PUNCT)
    return " ".join(s.split())


def slug(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")


def tag(e: ET.Element) -> str:
    return e.tag.rsplit("}", 1)[-1]


def children(e: ET.Element, name: str) -> List[ET.Element]:
    return [c for c in e if tag(c) == name]


def text_of(e: ET.Element) -> str:
    return clean("".join(e.itertext()))


def title_of(p: ET.Element) -> str:
    t = children(p, "title")
    return text_of(t[0]).rstrip(":").strip() if t else ""


def is_empty(text: str) -> bool:
    return not text or text.lower().rstrip(".") == "none"


def segments(body: ET.Element) -> List[Tuple[str, str]]:
    """Split a <text_body> into ordered ("prose", text) / ("item", text) parts."""
    out, buf = [], [body.text or ""]
    for c in body:
        if tag(c) in ("itemize", "enum", "description"):
            out.append(("prose", clean("".join(buf))))
            buf = []
            out.extend(("item", text_of(it)) for it in children(c, "item"))
        else:
            buf.append("".join(c.itertext()))
        buf.append(c.tail or "")
    out.append(("prose", clean("".join(buf))))
    return [(k, t) for k, t in out if t]


def sentences(text: str) -> List[str]:
    return [s for s in SENTENCE_SPLIT.split(text) if s]


def unique_matches(pattern: re.Pattern, text: str) -> List[str]:
    seen: List[str] = []
    for m in pattern.finditer(text):
        w = m.group(0).lower()
        if w not in seen:
            seen.append(w)
    return seen


def _number(s: str):
    d = Decimal(s.replace(",", ""))
    return int(d) if d == d.to_integral_value() else float(d)


# ---------------------------------------------------------------------------
# Quantity extraction
# ---------------------------------------------------------------------------

def quantities(text: str) -> List[dict]:
    """Numbers with units, ordered by position. Spans already claimed by an
    earlier pattern (rate before time/count) are not matched twice."""
    found: List[Tuple[int, dict]] = []
    taken: List[Tuple[int, int]] = []
    low = text.lower()
    default_cmp = ">=" if re.search(r"\b(minimum|at least|able to|handle|concurrent)", low) else "="
    if re.search(r"\bmaximum\b", low):
        default_cmp = "<="

    def free(m):
        return all(m.end() <= a or m.start() >= b for a, b in taken)

    for m in RATE_RE.finditer(text):
        taken.append(m.span())
        per = PER_SECOND[m.group(3).lower()]
        found.append((m.start(), {
            "kind": "throughput", "value": _number(m.group(1)),
            "unit": f"{m.group(2).lower()}/{m.group(3).lower()}", "comparator": ">=",
            "per_second": _number(str(Decimal(m.group(1).replace(",", "")) / per)),
        }))
    for m in TIME_RE.finditer(text):
        if not free(m):
            continue
        taken.append(m.span())
        unit = m.group(3).lower()
        found.append((m.start(), {
            "kind": "time", "value": _number(m.group(2)), "unit": unit,
            "comparator": CMP_SYMBOL.get((m.group(1) or "").lower(), "<="),
            "micros": int(Decimal(m.group(2).replace(",", "")) * MICROS[unit]),
        }))
    for m in COUNT_RE.finditer(text):
        if not free(m):
            continue
        taken.append(m.span())
        found.append((m.start(), {
            "kind": "count", "value": _number(m.group(2)), "unit": m.group(3).lower(),
            "comparator": CMP_SYMBOL.get((m.group(1) or "").lower(), default_cmp),
        }))
    for m in PERCENT_RE.finditer(text):
        if not free(m):
            continue
        found.append((m.start(), {"kind": "percent", "value": _number(m.group(1)), "unit": "%",
                                  "comparator": default_cmp}))
    return [q for _, q in sorted(found, key=lambda x: x[0])]


def operation_phrase(text: str) -> str:
    m = re.search(r"\bable to (.+)", text, re.I)
    op = m.group(1) if m else text
    op = re.split(r"\s+(?:in|within)\s+(?:less than|under)\b|\s+(?:in|within)\s+\d|\s+\d", op)[0]
    return op.rstrip(" .")


def runtime_checks(text: str, qs: List[dict]) -> List[dict]:
    """Bounds that a Python benchmark measures and Lean checks with `decide`.
    All bounds are integers so they drop straight into a `Nat` comparison."""
    checks = []
    concurrent = re.search(r"\b(concurrent(?:ly)?|simultaneous(?:ly)?|at the same time)\b", text, re.I)
    for q in qs:
        if q["kind"] == "time":
            metric, bound, unit = "latency", q["micros"], "us"
        elif q["kind"] == "throughput":
            metric, bound, unit = "throughput", q["value"], q["unit"]
        elif q["kind"] == "count" and concurrent:
            metric, bound, unit = "concurrency", q["value"], q["unit"]
        else:
            continue
        checks.append({"metric": metric, "operation": operation_phrase(text),
                       "comparator": q["comparator"], "bound": bound, "unit": unit,
                       "lean_field": RUNTIME_FIELD[metric]})
    return checks


# ---------------------------------------------------------------------------
# Data dictionary
# ---------------------------------------------------------------------------

def data_constraints(desc: str) -> dict:
    low = desc.lower()
    c: Dict[str, object] = {}
    m = re.search(r"minimum (\d+) to maximum (\d+) characters?", low)
    if m:
        c["min_length"], c["max_length"] = int(m.group(1)), int(m.group(2))
    m = re.search(r"maximum (\d+)(?: \w+)? characters?", low)
    if m and "max_length" not in c:
        c["max_length"] = int(m.group(1))
    m = re.search(r"(\d+)[- ]digit", low)
    if m:
        c["exact_length"] = int(m.group(1))
    m = re.search(r"(\d+) characters?", low)
    if m and not {"min_length", "max_length", "exact_length"} & set(c):
        c["exact_length"] = int(m.group(1))
    if "alphanumeric" in low:
        c["charset"] = "alphanumeric"
    elif "alphabetic" in low:
        c["charset"] = "alphabetic"
    elif "numeric" in low:
        c["charset"] = "numeric"
    if re.search(r"\bunique(ly)?\b", low):
        c["unique"] = True
    if "system generated" in low:
        c["generated_by"] = "system"
    m = re.search(r"format ([A-Za-z/]+)", desc)
    if m:
        c["format"] = m.group(1)
    if "dollars and cents" in low:
        c["type"] = "money"
        c["precision"] = "cents"
    m = re.search(r"default\s*=\s*(\d+)", low)
    if m:
        c["default"] = int(m.group(1))
    m = re.search(r"maximum\s*=\s*([a-z][a-z ]*[a-z])", low)
    if m:
        c["max_ref"] = m.group(1)
    m = re.search(r"in the form of \(([^)]+)\)", low)
    if m:
        c["tuple_fields"] = [f.strip() for f in m.group(1).split(",")]
    return c


# ---------------------------------------------------------------------------
# Parser
# ---------------------------------------------------------------------------

class _Parser:
    def __init__(self):
        self.glossary: List[dict] = []
        self.requirements: List[dict] = []
        self.data_dictionary: List[dict] = []
        self.use_cases: List[dict] = []
        self.dropped: List[dict] = []
        self._ids: Dict[str, int] = {}

    # -- ids ----------------------------------------------------------------

    def _uid(self, base: str) -> str:
        n = self._ids.get(base, 0) + 1
        self._ids[base] = n
        return base if n == 1 else f"{base}#{n}"

    @staticmethod
    def _section_id(path: List[Tuple[str, str]]) -> str:
        parts: List[str] = []
        for sid, title in path:
            if sid:
                parts = [sid]
            elif title:
                parts.append(slug(title))
        return "/".join(parts)

    @staticmethod
    def _excluded(path: List[Tuple[str, str]]) -> Optional[str]:
        for _, title in path:
            low = title.lower()
            if any(s in low for s in EXCLUDED_SECTIONS):
                return title
        return None

    def _drop(self, rid: str, source: str, section: str, text: str, reason: str):
        self.dropped.append({"id": rid, "source": source, "section": section,
                             "text": text, "reason": reason})

    # -- document walk ----------------------------------------------------------

    def run(self, root: ET.Element) -> None:
        for gi in root.iter():
            if tag(gi) != "glossary_item":
                continue
            term = clean("".join(t for e in children(gi, "term") for t in e.itertext())).rstrip(":")
            meaning = clean("".join(t for e in children(gi, "meaning") for t in e.itertext()))
            if term:
                self.glossary.append({"term": term, "meaning": meaning})
        self._walk(root, [])

    def _walk(self, elem: ET.Element, path: List[Tuple[str, str]]) -> None:
        for p in children(elem, "p"):
            sec_path = path + [(clean(p.get("id")), title_of(p))]
            low = sec_path[-1][1].lower()
            if low.startswith("appendix b"):
                self._use_cases(p)
                continue
            if "data dictionary" in low:
                self._data_dictionary(p)
                continue
            self._section(p, sec_path)
            self._walk(p, sec_path)

    def _section(self, p: ET.Element, path: List[Tuple[str, str]]) -> None:
        sec_id = self._section_id(path)
        excluded = self._excluded(path)
        n_sent = n_item = 0
        for ch in p:
            if tag(ch) == "req":
                rid = clean(ch.get("id"))
                bodies = children(ch, "text_body")
                text = " ".join(text_of(b) for b in bodies) if bodies else text_of(ch)
                base = f"{sec_id}/R{rid}" if rid.isdigit() or not rid else rid
                self._assess(self._uid(base), path, text, excluded, inherited_modal=False)
            elif tag(ch) == "text_body":
                intro_modal = False
                for kind, text in segments(ch):
                    if kind == "prose":
                        for s in sentences(text):
                            n_sent += 1
                            self._assess(self._uid(f"{sec_id}/S{n_sent}"), path, s, excluded, False)
                        intro_modal = text.endswith(":") and bool(MODAL.search(text))
                    else:
                        n_item += 1
                        m = ITEM_LABEL.match(text)
                        rid, text = (m.group(1), m.group(2)) if m else (f"{sec_id}/I{n_item}", text)
                        self._assess(self._uid(rid), path, text, excluded, intro_modal)

    def _assess(self, rid: str, path: List[Tuple[str, str]], text: str,
                excluded: Optional[str], inherited_modal: bool) -> None:
        if is_empty(text):
            return
        section = self._section_id(path)
        drop = lambda reason: self._drop(rid, "requirement", section, text, reason)  # noqa: E731

        if excluded:
            return drop(f"non-normative section: {excluded}")
        if not (MODAL.search(text) or inherited_modal):
            return drop("no normative modal (shall/must/will/should/can)")

        qs = quantities(text)
        vague = unique_matches(VAGUE, text)
        tech = unique_matches(TECH, text)
        ops = unique_matches(STATE_OP, NOT_AN_OP.sub(" ", text))
        timed = [q for q in qs if q["kind"] in ("time", "throughput", "count")]

        if any(q["kind"] == "percent" for q in qs) and re.search(r"availab", text, re.I):
            return drop("operational SLA (availability %): not provable or benchmarkable")
        if tech and not timed:
            return drop(f"platform/technology choice: {', '.join(tech)}")
        if vague and not (timed or DATA_RELATION.search(text)):
            return drop(f"vague: {', '.join(vague)}")
        if not (timed or ops):
            return drop("no state change, data relation or quantity to formalise")
        overview = next((t for _, t in path if OVERVIEW_SECTIONS.search(t)), None)
        if overview and not (timed or DATA_RELATION.search(text)):
            return drop(f"overview section ({overview}): no quantity or data relation")

        checks = runtime_checks(text, qs)
        item = {
            "id": rid,
            "kind": "requirement",
            "category": "performance" if checks else ("quantitative" if qs else "functional"),
            "verification": "lean+python_runtime" if checks else "lean",
            "section": section,
            "section_path": [t for _, t in path if t],
            "text": text,
            "signals": ops,
            "quantities": qs,
            "has_precondition": bool(PRECONDITION_CUE.search(text)),
        }
        if checks:
            item["runtime_checks"] = checks
        if vague:
            item["ignore_terms"] = vague
        refs = [g["term"] for g in self.glossary
                if re.search(r"\b" + re.escape(g["term"].lower()) + r"\b", text.lower())]
        if refs:
            item["glossary_refs"] = refs
        self.requirements.append(item)

    # -- data dictionary ------------------------------------------------------

    def _data_dictionary(self, p: ET.Element) -> None:
        for body in p.iter():
            if tag(body) != "text_body":
                continue
            for kind, text in segments(body):
                if kind != "item" or "=" not in text:
                    continue
                field, desc = (clean(x) for x in text.split("=", 1))
                rid = self._uid(f"DD-{slug(field)}")
                cons = data_constraints(desc)
                if not cons:
                    self._drop(rid, "data_dictionary", "data-dictionary", text,
                               "no length, charset, format or uniqueness constraint")
                    continue
                self.data_dictionary.append({"id": rid, "kind": "data_constraint", "field": field,
                                             "description": desc, "constraints": cons})

    # -- use cases ------------------------------------------------------------

    def _use_cases(self, appendix: ET.Element) -> None:
        for group in children(appendix, "p"):
            gname = re.sub(r"\s*use cases?$", "", title_of(group), flags=re.I)
            for uc in children(group, "p"):
                self._use_case(gname, uc)

    @staticmethod
    def _part_texts(part: ET.Element) -> List[str]:
        out: List[str] = []
        for body in children(part, "text_body"):
            for kind, text in segments(body):
                out.extend(sentences(text) if kind == "prose" else [text])
        return [t for t in out if not is_empty(t)]

    def _use_case(self, group: str, uc: ET.Element) -> None:
        name = title_of(uc)
        uid = self._uid(f"UC-{slug(group)}-{slug(name)}")
        parts = {title_of(part).lower(): self._part_texts(part) for part in children(uc, "p")}
        sec = "use-cases"

        def conditions(key: str) -> List[str]:
            kept = []
            for i, t in enumerate(parts.get(key, []), 1):
                tech = unique_matches(TECH, t)
                if tech:
                    self._drop(f"{uid}/{slug(key)}{i}", "use_case", sec, t,
                               f"platform/technology choice: {', '.join(tech)}")
                else:
                    kept.append(t)
            return kept

        for i, t in enumerate(parts.get("triggers", []), 1):
            self._drop(f"{uid}/trigger{i}", "use_case", sec, t, "UI trigger")

        basic = self._steps(uid, "basic", parts.get("basic scenario", []), numbered=True)
        kept_nums = [s["step"] for s in basic]
        flows: List[dict] = []
        for s in self._steps(uid, "alt", parts.get("alternative scenario", []), numbered=False):
            if not flows or flows[-1]["flow"] != s["flow"]:
                flows.append({"flow": s["flow"], "steps": []})
            flows[-1]["steps"].append({k: v for k, v in s.items() if k != "flow"})
        for s in basic + [st for f in flows for st in f["steps"]]:
            if "goto" in s:
                t = s["goto"]["step"]
                s["goto"]["resolves_to"] = next((n for n in kept_nums if n >= t), "end")

        self.use_cases.append({
            "id": uid,
            "kind": "use_case",
            "group": group,
            "name": name,
            "goal": " ".join(parts.get("goal", [])),
            "actors": parts.get("actors", []),
            "preconditions": conditions("preconditions"),
            "basic_scenario": basic,
            "alternative_scenarios": flows,
            "postconditions": conditions("postconditions"),
        })

    def _steps(self, uid: str, which: str, texts: List[str], numbered: bool) -> List[dict]:
        out, n, flow = [], 0, "A"
        for raw in texts:
            for piece in STEP_SPLIT.split(raw):
                m = STEP_LABEL.match(piece)
                text = piece[m.end():] if m else piece
                if m and m.group(1):
                    flow, n = m.group(1), int(m.group(2))
                elif m and m.group(3):
                    n = int(m.group(3))
                else:
                    n += 1
                label = str(n) if numbered else f"{flow}{n}"
                step = self._classify_step(text)
                if step is None:
                    continue
                if isinstance(step, str):
                    self._drop(f"{uid}/{which}/{label}", "use_case_step", "use-cases", text, step)
                    continue
                step = {"step": n, **step} if numbered else {"flow": flow, "step": n, **step}
                out.append(step)
        return out

    @staticmethod
    def _classify_step(text: str):
        """Return a step dict to keep, a drop-reason string, or None for empty."""
        if is_empty(text):
            return None
        goto = GOTO.search(text)
        step: dict
        if re.match(r"^go to step", text, re.I):
            step = {"actor": "system", "type": "goto", "text": text}
        elif SYSTEM_STEP.match(text):
            if UI_SYSTEM_VERB.match(text):
                return "UI presentation step"
            if not STATE_OP.search(NOT_AN_OP.sub(" ", text)):
                return "no state change"
            step = {"actor": "system", "type": "action", "text": text}
        else:
            if CLICK.search(text):
                return "UI interaction"
            if not USER_EVENT.search(text):
                return "user navigation or data entry with no checkable condition"
            step = {"actor": "user", "type": "event", "text": text}
        if goto:
            step["goto"] = {"step": int(goto.group(1))}
        return step


def parse_bytes(data: bytes, source_name: str) -> dict:
    root = ET.fromstring(data)
    p = _Parser()
    p.run(root)
    titles = [clean(t.text) for t in root.iter() if tag(t) == "title" and t.text and clean(t.text)]
    head = next((t for t in children(root, "title")), None)
    doc_titles = [clean(t.text) for t in head if clean(t.text)] if head is not None else titles[:1]
    return {
        "schema_version": SCHEMA_VERSION,
        "source": {"file": source_name, "sha256": hashlib.sha256(data).hexdigest()},
        "titles": doc_titles,
        "stats": {
            "requirements": len(p.requirements),
            "data_constraints": len(p.data_dictionary),
            "use_cases": len(p.use_cases),
            "dropped": len(p.dropped),
        },
        "glossary": p.glossary,
        "requirements": p.requirements,
        "data_dictionary": p.data_dictionary,
        "use_cases": p.use_cases,
        "dropped": p.dropped,
    }


def parse_file(path) -> dict:
    path = Path(path)
    return parse_bytes(path.read_bytes(), path.name)


def to_json(doc: dict) -> str:
    return json.dumps(doc, indent=2, ensure_ascii=False) + "\n"


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("xml", help="requirements document (req_document.xsd XML)")
    ap.add_argument("-o", "--out", help="output JSON path (default: stdout)")
    args = ap.parse_args(argv)
    out = to_json(parse_file(args.xml))
    if args.out:
        Path(args.out).write_text(out, encoding="utf-8")
    else:
        sys.stdout.write(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
