"""Deterministic requirements graph: parsed SRS + L0 specs (+ Domain.lean) → graph.json.

No model calls. The same inputs always give the same graph.json bytes: every list is
sorted, Louvain (only for groups that are too big) runs with a fixed seed, and the spaCy
version is recorded so a different lemmatiser is visible.

    entities     from the inputs every SRS has: the data dictionary, glossary terms and
                 use-case actors, normalised (lower case, camelCase/snake_case split, spaCy
                 lemma), glossary synonyms ("also called X"), and from the L0 specs
                 themselves: their helper structures (`structure Account`), and state: a
                 field name that one operation reads and another one writes (`signedIn`,
                 `cookie`) is an entity even when no document names it.
                 Optional extras (`--vocab full`, the default when the files exist):
                 benchmark/<doc>/Domain.lean (structures; fields as attributes) and
                 Requirements/synonyms/<doc>.json. `--vocab srs` ignores both, so the
                 graph of a new SRS does not depend on hand-written vocabulary
    operations   one per L0 spec. `structure Input` fields are reads; `structure Output`
                 fields are writes, except a field the spec only copies (`o.f = i.f`), which
                 is a read. A field maps to an entity by its name, else by its type
                 (`List Account`), else by its last/first word; unmapped fields are recorded
    edges        A → B when A writes entity X and B reads X (reason kept); use-case links
                 from fixed spaCy dependency rules: a precondition of B that a postcondition
                 of A establishes, and "include"/"extend" steps naming another use case
    groups       connected parts of the operation–entity projection (plus use-case links).
                 Each group is one system for L1 (one message type, one SystemSpec)
    components   Louvain communities (fixed seed) of a group. A group with more than
                 CF_GRAPH_MAX_COMPONENT operations is always split; a smaller one with at
                 least CF_GRAPH_MIN_SPLIT operations is split when the communities are real
                 (modularity ≥ CF_GRAPH_MIN_MODULARITY), else it is one component.
                 One contract per component
    order        chain order = topological order of the component graph. If it has cycles
                 they are listed, and (CF_GRAPH_CYCLES):
                   break (default)  the components stay as Louvain made them; inside each
                                    strongly connected set the order with the least
                                    backward dataflow is taken, and the backward edges are
                                    recorded as `feedback_edges`. L1's proofs do not depend
                                    on the order (a component passes on what it does not
                                    own), so breaking a cycle loses no soundness
                   merge            each strongly connected set becomes one component (the
                                    v1 behaviour; on gamma j it merged 47 of 52 operations
                                    back into one component)

Usage (from harness/):
    python req_graph.py "0000 - gamma j"            # → runs/<doc>/graph/graph.json, graph.png
    python req_graph.py "0000 - gamma j" --l0-run "../runs/0000 - gamma j/qwen-v10.1/rep1"
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import networkx as nx

from config import ROOT

GRAPH_VERSION = "2"
MAX_COMPONENT_OPS = int(os.getenv("CF_GRAPH_MAX_COMPONENT", "8"))
MIN_SPLIT_OPS = int(os.getenv("CF_GRAPH_MIN_SPLIT", "4"))          # smaller groups are never split
MIN_MODULARITY = float(os.getenv("CF_GRAPH_MIN_MODULARITY", "0.1"))  # below this a split is noise
CYCLE_MODE = os.getenv("CF_GRAPH_CYCLES", "break")                  # break | merge
VOCAB = os.getenv("CF_GRAPH_VOCAB", "full")                         # full | srs
EXACT_ORDER_MAX = 8      # strongly connected sets up to this size are ordered exactly
LOUVAIN_SEED = int(os.getenv("CF_GRAPH_SEED", "42"))
MAX_CYCLES_LISTED = 20
DEFAULT_L0_RUN = "qwen-v10.1/rep1"

# Words that never name an entity on their own.
STOP = {"a", "an", "the", "of", "to", "in", "on", "for", "and", "or", "with", "by", "is", "new",
        "no", "num", "number", "value", "raw", "data", "info", "list", "flag", "set", "get"}
SYSTEM_WORDS = {"system", "application", "software"}

_STRUCT_BLOCK = re.compile(r"^structure\s+(\w+)[^\n]*\bwhere\s*\n((?:[ \t]+.*\n?)*)", re.MULTILINE)
_FIELD_TYPE = re.compile(r"^[ \t]+(\w+)\s*:\s*(.+?)\s*(?:--.*)?$", re.MULTILINE)
_GLOSSARY_SYN = re.compile(r"\b(?:also (?:called|known as)|same as|synonym (?:for|of))\s+"
                           r"(?:an?\s+|the\s+)?([A-Za-z][A-Za-z \-]*[A-Za-z])", re.I)


# ---------------------------------------------------------------------------
# Normalisation (spaCy lemma of each word; cached, so the order of calls never matters)
# ---------------------------------------------------------------------------

_NLP = None
_LEMMA: Dict[str, str] = {}


def nlp():
    global _NLP
    if _NLP is None:
        import spacy
        _NLP = spacy.load("en_core_web_sm")
    return _NLP


def spacy_meta() -> dict:
    import spacy
    return {"spacy": spacy.__version__, "model": "en_core_web_sm", "model_version": nlp().meta["version"]}


def split_words(name: str) -> List[str]:
    """`productToAdd` / `product_to_add` / `Item ID` → ['product', 'to', 'add'] / … (lower case)."""
    spaced = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", name)
    spaced = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1 \2", spaced)
    return [w for w in re.split(r"[^A-Za-z0-9]+", spaced.lower()) if w]


def lemma(word: str) -> str:
    """spaCy lemma of one word. Words of 3 letters or fewer are kept as they are (spaCy turns
    `id` into `i`)."""
    if word not in _LEMMA:
        _LEMMA[word] = nlp()(word)[0].lemma_.lower() if word.isalpha() and len(word) > 3 else word
    return _LEMMA[word]


def norm_words(name: str) -> List[str]:
    return [lemma(w) for w in split_words(name)]


def norm(name: str) -> str:
    """Normalised term: lemmas of the content words, space separated."""
    words = [w for w in norm_words(name) if w not in STOP]
    return " ".join(words)


# ---------------------------------------------------------------------------
# Lean source helpers
# ---------------------------------------------------------------------------

def structures(code: str) -> Dict[str, Dict[str, str]]:
    """{structure: {field: type}} (comments and `deriving` lines dropped)."""
    out = {}
    for m in _STRUCT_BLOCK.finditer(code):
        fields = {}
        for f, t in _FIELD_TYPE.findall(m.group(2)):
            if f != "deriving":
                fields[f] = t.strip()
        out[m.group(1)] = fields
    return out


def type_names(t: str) -> List[str]:
    """Capitalised names inside a field type: `List (Option Account)` → ['Account']."""
    core = {"List", "Option", "Nat", "Int", "String", "Bool", "Char", "Prop", "Array", "Type"}
    return [n for n in re.findall(r"\b([A-Z]\w*)\b", t) if n not in core]


def copied_fields(code: str, out_fields: List[str]) -> List[str]:
    """Output fields the spec only copies from the input: `o.f = i.f` (either side)."""
    return [f for f in out_fields
            if re.search(rf"\bo\.{f}\s*=\s*i\.{f}\b|\bi\.{f}\s*=\s*o\.{f}\b", code)]


# ---------------------------------------------------------------------------
# Entities
# ---------------------------------------------------------------------------

class Vocabulary:
    """Entity terms, synonyms and attribute terms, with their sources."""

    def __init__(self):
        self.entities: Dict[str, dict] = {}
        self.synonyms: Dict[str, str] = {}      # term → entity term
        self.attributes: Dict[str, set] = defaultdict(set)  # attribute term → entity terms
        self.dd_owner: Dict[str, str] = {}      # data-dictionary field name → owning entity
        self.state: set = set()                 # entities found as state shared between specs

    def add_entity(self, name: str, source: str) -> Optional[str]:
        term = norm(name)
        if not term or set(term.split()) <= SYSTEM_WORDS:
            return None
        e = self.entities.setdefault(term, {"term": term, "names": [], "sources": []})
        if name not in e["names"]:
            e["names"].append(name)
        if source not in e["sources"]:
            e["sources"].append(source)
        return term

    def add_synonym(self, alias: str, target: str, source: str) -> None:
        a, t = norm(alias), norm(target)
        if a and t and a != t:
            self.synonyms.setdefault(a, t)
            self.add_entity(target, source)

    def resolve(self, term: str) -> Optional[Tuple[str, str]]:
        """(entity, how) for a normalised term: an entity, a synonym, or an attribute that
        belongs to exactly one entity."""
        if not term:
            return None
        if term in self.synonyms:
            return self.synonyms[term], "synonym"
        if term in self.entities:
            return term, "name"
        owners = self.attributes.get(term, set())
        if len(owners) == 1:
            return next(iter(owners)), "attribute"
        return None


def build_vocabulary(doc: dict, domain_code: Optional[str], synonyms: dict) -> Vocabulary:
    v = Vocabulary()
    for alias, target in sorted(synonyms.items()):
        v.add_synonym(alias, target, "synonyms file")
    if domain_code:
        for struct, fields in sorted(structures(domain_code).items()):
            ent = v.add_entity(struct, "Domain.lean")
            for f in sorted(fields):
                if ent and norm(f):
                    v.attributes[norm(f)].add(ent)
        # Type abbreviations name entities too (`abbrev Cart := List CartLine`).
        for name in sorted(re.findall(r"^abbrev\s+([A-Z]\w*)\s*:=", domain_code, re.MULTILINE)):
            v.add_entity(name, "Domain.lean")
    for g in doc.get("glossary", []):
        m = _GLOSSARY_SYN.search(g.get("meaning", ""))
        if m:
            v.add_synonym(m.group(1), g["term"], "glossary")  # "X: also called Y" → Y means X
        v.add_entity(g["term"], "glossary")
    for u in doc.get("use_cases", []):
        for actor in u.get("actors", []):
            v.add_entity(actor, "actor")
    for d in doc.get("data_dictionary", []):
        owner = data_owner(v, d)
        if owner:
            v.dd_owner[d["field"]] = owner
        attr = norm(d["field"])
        if owner and len(attr.split()) > 1:
            v.attributes[attr].add(owner)
        elif owner:  # a one-word field ("Name") is too generic to stand for its owner elsewhere
            pass
        else:
            v.add_entity(d["field"], "data dictionary")
    return v


def add_spec_entities(v: Vocabulary, results: List[dict], entries: dict) -> None:
    """Entities the L0 specs carry themselves, so the graph does not depend on a hand-written
    domain file: helper structures, and state. State = a field name no other source explains
    that some operation reads (`Input`) and some operation writes (`Output`), in at least
    two operations; e.g. `signedIn`, `cookie`."""
    read_by, written_by, names = defaultdict(set), defaultdict(set), {}
    parsed = []
    for r in results:
        st = structures(r.get("lean_predicate") or "")
        parsed.append((r, st))
        for struct, fields in sorted(st.items()):
            if struct in ("Input", "Output"):
                continue
            ent = v.add_entity(struct, "L0 structure")
            for f in sorted(fields):
                if ent and norm(f):
                    v.attributes[norm(f)].add(ent)
    for r, st in parsed:
        entry = entries.get(r["id"], {})
        alias = entry.get("field") if entry.get("kind") == "data_constraint" else None
        for side, ops in (("Input", read_by), ("Output", written_by)):
            for f, t in sorted(st.get(side, {}).items()):
                if map_field(v, f, t, alias if side == "Input" else None):
                    continue
                term = norm(f)
                if term:
                    ops[term].add(r["id"])
                    names.setdefault(term, f)
    for term in sorted(set(read_by) & set(written_by)):
        if len(read_by[term] | written_by[term]) >= 2:
            ent = v.add_entity(names[term], "shared field")
            if ent:
                v.state.add(ent)


def data_owner(v: Vocabulary, d: dict) -> Optional[str]:
    """The entity a data-dictionary field belongs to: the first word(s) of its name if they
    name an entity ("Item name" → item), else the first entity after "of" in its
    description ("Cost of a single unit of the selected item" → item)."""
    words = [w for w in norm(d["field"]).split()]
    for k in range(len(words) - 1, 0, -1):
        hit = v.resolve(" ".join(words[:k]))
        if hit and hit[1] != "attribute":
            return hit[0]
    for tok in nlp()(d.get("description", "")):
        if tok.dep_ == "pobj" and tok.head.lower_ == "of":
            phrase = " ".join(lemma(t.lower_) for t in tok.subtree
                              if t.pos_ in ("NOUN", "PROPN") and t.lower_ not in STOP)
            for cand in (phrase, lemma(tok.lower_)):
                hit = v.resolve(cand)
                if hit and hit[1] != "attribute":
                    return hit[0]
    return None


# ---------------------------------------------------------------------------
# Operations
# ---------------------------------------------------------------------------

def map_field(v: Vocabulary, name: str, typ: str, alias: Optional[str] = None) -> Optional[dict]:
    """Entity of a field: its whole name, its type's structure name, its last word, its first
    word; for a data-dictionary spec (`raw`/`value`), the dictionary field name `alias`."""
    words = [w for w in norm(name).split()]
    cands = [(" ".join(words), "name")]
    for t in type_names(typ):
        tw = norm(t).split()
        cands += [(" ".join(tw), "type")] + ([(tw[-1], "type head")] if len(tw) > 1 else [])
    if len(words) > 1:
        cands += [(words[-1], "last word"), (words[0], "first word")]
    if alias:
        if alias in v.dd_owner:
            return {"entity": v.dd_owner[alias], "rule": "data dictionary owner", "via": "owner",
                    "term": norm(alias)}
        cands.insert(0, (norm(alias), "data dictionary field"))
    for term, rule in cands:
        hit = v.resolve(term)
        if hit:
            return {"entity": hit[0], "rule": rule, "via": hit[1], "term": term}
    return None


def is_state_write(rec: dict, state: set = frozenset()) -> bool:
    """An output field changes an entity only if its name or type names that entity (or a
    synonym), e.g. `accounts : List Account`, `cart`. A `Bool` (`emailSent`, `valid`) or a value
    matched only through an attribute or one word of its name (`totalCost`) is a result the
    operation returns, not a change to the entity. A state entity (`signedIn`: read by one
    spec, written by another) is written by the field of that name, `Bool` or not."""
    if rec["entity"] in state and rec["via"] == "name" and rec["rule"] == "name":
        return True
    if rec["type"].strip() == "Bool":
        return False
    return rec["via"] in ("name", "synonym") and rec["rule"] in ("name", "type", "type head")


def operation(v: Vocabulary, r: dict, entry: dict) -> dict:
    code = r.get("lean_predicate") or ""
    st = structures(code)
    tin, tout = st.get("Input", {}), st.get("Output", {})
    alias = entry.get("field") if entry.get("kind") == "data_constraint" else None
    copies = copied_fields(code, list(tout))
    reads, writes, results, unmapped = [], [], [], []
    for side, fields in (("input", tin), ("output", tout)):
        for f, t in sorted(fields.items()):
            hit = map_field(v, f, t, alias if side == "input" else None)
            if not hit:
                unmapped.append({"side": side, "field": f, "type": t})
                continue
            rec = {"field": f, "type": t, **hit}
            if side == "input":
                reads.append(rec)
            elif f in copies:
                reads.append({**rec, "copied": True})
            elif is_state_write(rec, v.state):
                writes.append(rec)
            else:
                results.append(rec)
    return {
        "id": r["id"], "kind": r.get("kind") or entry.get("kind"), "lean_name": None,
        "compiles": bool(r.get("compiles")), "checked": r.get("checked"),
        "l05": (r.get("l05") or {}).get("status"),
        "text": " ".join((r.get("requirement_text") or "").split()),
        "reads": reads, "writes": writes, "results": results, "unmapped": unmapped,
        "entities_read": sorted({x["entity"] for x in reads}),
        "entities_written": sorted({x["entity"] for x in writes}),
    }


# ---------------------------------------------------------------------------
# Use-case links (fixed spaCy dependency rules)
# ---------------------------------------------------------------------------

_PARTICLE = {"into": "in", "in": "in", "out": "out", "up": "up", "off": "off", "on": "on"}


def _predicates(sent) -> set:
    """Lemmas of the root verb and its conjuncts, with a particle (`log in` ≠ `log out`)."""
    root = next((t for t in sent if t.dep_ == "ROOT"), None)
    if root is None:
        return set()
    verbs = [root] + [t for t in root.children if t.dep_ == "conj" and t.pos_ in ("VERB", "AUX")]
    out = set()
    for vb in verbs:
        prt = next((_PARTICLE[c.lower_] for c in vb.children
                    if c.dep_ in ("prt", "prep") and c.lower_ in _PARTICLE), None)
        out.add(f"{vb.lemma_.lower()} {prt}" if prt else vb.lemma_.lower())
    return out


def _subject(sent) -> set:
    """Noun lemmas of the subject phrase (with its compounds), without system words."""
    root = next((t for t in sent if t.dep_ == "ROOT"), None)
    subj = [c for c in (root.children if root is not None else []) if c.dep_ in ("nsubj", "nsubjpass")]
    words = {t.lemma_.lower() for s in subj for t in s.subtree
             if t.pos_ in ("NOUN", "PROPN") and t.dep_ in ("compound", "nsubj", "nsubjpass", "nmod")}
    return words - SYSTEM_WORDS


def _nouns(sent) -> set:
    return {t.lemma_.lower() for t in sent if t.pos_ in ("NOUN", "PROPN")} - SYSTEM_WORDS


def usecase_links(doc: dict, op_ids: set) -> List[dict]:
    """[{src, dst, kind, reason}] between use cases that are operations."""
    ucs = [u for u in doc.get("use_cases", []) if u["id"] in op_ids]
    posts = []
    for u in ucs:
        for s in u.get("postconditions", []):
            d = nlp()(s)
            posts.append((u["id"], s, _predicates(d), _nouns(d)))
    links = []
    for u in ucs:
        for s in u.get("preconditions", []):
            d = nlp()(s)
            subj, preds = _subject(d), _predicates(d)
            if not subj or not preds:
                continue
            for src, ps, ppreds, pnouns in posts:
                if src != u["id"] and preds & ppreds and subj <= pnouns:
                    links.append({"src": src, "dst": u["id"], "kind": "precondition",
                                  "reason": f'"{ps}" establishes the precondition "{s}"'})
        names = {o["id"]: o["name"].lower() for o in ucs if o["id"] != u["id"]}
        steps = [st["text"] for st in u.get("basic_scenario", [])] + \
                [st["text"] for f in u.get("alternative_scenarios", []) for st in f["steps"]]
        for text in steps:
            m = re.search(r"\b(include|includes|included|extend|extends|extended)\b", text, re.I)
            if not m:
                continue
            for oid, name in sorted(names.items()):
                if name and name in text.lower():
                    kind = "include" if m.group(1).lower().startswith("include") else "extend"
                    links.append({"src": oid if kind == "include" else u["id"],
                                  "dst": u["id"] if kind == "include" else oid,
                                  "kind": kind, "reason": f'step "{text}"'})
    return links


# ---------------------------------------------------------------------------
# Graph
# ---------------------------------------------------------------------------

def dataflow_edges(ops: List[dict]) -> Dict[Tuple[str, str], List[dict]]:
    """A → B for every entity A writes and B reads (A ≠ B), with the fields as the reason."""
    writers, readers = defaultdict(list), defaultdict(list)
    for o in ops:
        for w in o["writes"]:
            writers[w["entity"]].append((o["id"], w["field"]))
        for r in o["reads"]:
            readers[r["entity"]].append((o["id"], r["field"]))
    edges = defaultdict(list)
    for ent in sorted(writers):
        for a, fa in writers[ent]:
            for b, fb in readers.get(ent, []):
                if a != b:
                    edges[(a, b)].append({"kind": "dataflow", "entity": ent,
                                          "reason": f"{a} writes {ent} (`o.{fa}`), {b} reads it (`i.{fb}`)"})
    return edges


def _louvain_split(g: nx.Graph) -> List[List[str]]:
    """Louvain communities (fixed seed); a community still larger than MAX_COMPONENT_OPS is
    split again on its own subgraph. Louvain does not bound community size, and raising its
    resolution instead breaks a group into many one-operation components."""
    out = []
    for c in sorted((sorted(c) for c in nx.community.louvain_communities(
            g, weight="weight", seed=LOUVAIN_SEED)), key=lambda c: c[0]):
        if len(c) > MAX_COMPONENT_OPS and len(c) < g.number_of_nodes():
            out += _louvain_split(g.subgraph(c))
        else:
            out.append(c)
    return out


def split_group(sub: nx.Graph) -> Tuple[List[List[str]], str, Optional[float]]:
    """(communities, how, modularity) for one group. More than MAX_COMPONENT_OPS operations:
    always Louvain. At least MIN_SPLIT_OPS: Louvain, kept only if it finds real communities
    (≥ 2, modularity ≥ MIN_MODULARITY). Otherwise the group is one component."""
    members = sorted(sub.nodes)
    n = len(members)
    if n <= MAX_COMPONENT_OPS and (n < MIN_SPLIT_OPS or sub.number_of_edges() == 0):
        return [members], "connected", None
    comms = _louvain_split(sub)
    q = round(nx.community.modularity(sub, [set(c) for c in comms], weight="weight"), 4) \
        if sub.number_of_edges() and len(comms) > 1 else 0.0
    if n > MAX_COMPONENT_OPS or (len(comms) > 1 and q >= MIN_MODULARITY):
        return comms, "louvain", q
    return [members], "connected (no clear communities)", q


def _back_weight(order: List[str], weight: Dict[Tuple[str, str], int]) -> int:
    pos = {c: k for k, c in enumerate(order)}
    return sum(w for (a, b), w in weight.items() if a in pos and b in pos and pos[a] > pos[b])


def order_cycle(nodes: List[str], weight: Dict[Tuple[str, str], int]) -> List[str]:
    """Order of one strongly connected set with the least backward weight (ties: alphabetical).
    Exact for up to EXACT_ORDER_MAX components, else greedy: repeatedly take the component
    whose outgoing weight most exceeds its incoming weight among those left."""
    nodes = sorted(nodes)
    if len(nodes) <= EXACT_ORDER_MAX:
        from itertools import permutations
        return list(min(permutations(nodes), key=lambda p: (_back_weight(list(p), weight), p)))
    left, out = list(nodes), []
    while left:
        def gain(c):
            return (sum(w for (a, b), w in weight.items() if a == c and b in left)
                    - sum(w for (a, b), w in weight.items() if b == c and a in left))
        best = min(left, key=lambda c: (-gain(c), c))
        out.append(best)
        left.remove(best)
    return out


def chain_order(cg: nx.DiGraph, reasons: dict) -> Tuple[List[str], List[Tuple[str, str]]]:
    """(chain order, feedback edges). Strongly connected sets in topological order of the
    condensation; inside a set, `order_cycle`. Feedback edges are those that point backwards."""
    weight = {(a, b): max(1, len(reasons.get((a, b), []))) for a, b in cg.edges}
    cond = nx.condensation(cg)
    key = {n: min(cond.nodes[n]["members"]) for n in cond.nodes}
    order = []
    for n in nx.lexicographical_topological_sort(cond, key=lambda n: key[n]):
        members = sorted(cond.nodes[n]["members"])
        order += order_cycle(members, weight) if len(members) > 1 else members
    pos = {c: k for k, c in enumerate(order)}
    return order, sorted((a, b) for a, b in cg.edges if pos[a] > pos[b])


def _rotated(cycle: List[str]) -> List[str]:
    """A cycle written from its smallest name (networkx may start it anywhere)."""
    k = cycle.index(min(cycle))
    return list(cycle[k:]) + list(cycle[:k])


def _component_graph(comps: Dict[str, List[str]], by_id: dict, edges: dict):
    """Directed graph between components (an edge where an operation edge crosses them)
    and the operation-edge reasons behind each component edge."""
    where = {m: c for c, ms in comps.items() for m in ms}
    cg = nx.DiGraph()
    cg.add_nodes_from(sorted(comps))
    reasons = defaultdict(list)
    for (a, b), rs in sorted(edges.items()):
        ca, cb = where.get(a), where.get(b)
        if ca and cb and ca != cb:
            cg.add_edge(ca, cb)
            reasons[(ca, cb)] += [f"{a} → {b}: {r['reason']}" for r in rs]
    return cg, reasons


def _component_name(ops: List[dict], taken: set) -> str:
    """The entity most operations of the component touch (ties: alphabetical)."""
    count = defaultdict(int)
    for o in ops:
        for e in set(o["entities_read"]) | set(o["entities_written"]):
            count[e] += 1
    base = min(count, key=lambda e: (-count[e], e)) if count else "misc"
    from arch_lean import camel
    name, k = camel(base), 2
    while name in taken:
        name, k = f"{camel(base)}{k}", k + 1
    taken.add(name)
    return name


def build_graph(doc: dict, specs: dict, domain_code: Optional[str], synonyms: dict) -> dict:
    from arch_lean import slug
    entries = {e["id"]: e for e in doc["requirements"] + doc["data_dictionary"] + doc["use_cases"]}
    v = build_vocabulary(doc, domain_code, synonyms)
    add_spec_entities(v, specs["results"], entries)
    ops = [operation(v, r, entries.get(r["id"], {})) for r in specs["results"]]
    for o in ops:
        o["lean_name"] = slug(o["id"])
    ops.sort(key=lambda o: o["id"])
    by_id = {o["id"]: o for o in ops}

    edges = dataflow_edges(ops)
    for link in usecase_links(doc, set(by_id)):
        edges[(link["src"], link["dst"])].append({k: link[k] for k in ("kind", "reason")})

    # Groups: operation–entity projection plus use-case links (undirected).
    proj = nx.Graph()
    proj.add_nodes_from(sorted(by_id))
    ent_ops = defaultdict(set)
    for o in ops:
        for e in set(o["entities_read"]) | set(o["entities_written"]):
            ent_ops[e].add(o["id"])
    for e in sorted(ent_ops):
        members = sorted(ent_ops[e])
        for i, a in enumerate(members):
            for b in members[i + 1:]:
                w = proj.get_edge_data(a, b, {"weight": 0})["weight"]
                proj.add_edge(a, b, weight=w + 1)
    for (a, b) in sorted(edges):
        if any(r["kind"] != "dataflow" for r in edges[(a, b)]):
            w = proj.get_edge_data(a, b, {"weight": 0})["weight"]
            proj.add_edge(a, b, weight=w + 1)

    isolated = sorted(n for n in proj.nodes if proj.degree(n) == 0 and not
                      (by_id[n]["entities_read"] or by_id[n]["entities_written"]))
    parts = [sorted(c) for c in nx.connected_components(proj) if not (len(c) == 1 and next(iter(c)) in isolated)]
    parts.sort(key=lambda c: (-len(c), c[0]))

    groups, components, taken = [], [], set()
    for gi, members in enumerate(parts, 1):
        sub = proj.subgraph(members)
        comms, split, modularity = split_group(sub)
        comms.sort(key=lambda c: (-len(c), c[0]))
        gname = _component_name([by_id[m] for m in members], set())
        gname = f"{gname}Sys" if f"{gname}Sys" not in {g['id'] for g in groups} else f"{gname}Sys{gi}"

        # Provisional components, their graph and its cycles.
        prov_taken: set = set()
        prov = {_component_name([by_id[m] for m in c], prov_taken): c for c in comms}
        cg0, _ = _component_graph(prov, by_id, edges)
        acyclic = nx.is_directed_acyclic_graph(cg0)
        cycles = [] if acyclic else sorted(
            (_rotated(c) for c in nx.simple_cycles(cg0)), key=lambda c: (len(c), c))[:MAX_CYCLES_LISTED]
        merged = []
        if not acyclic and CYCLE_MODE == "merge":
            # Each strongly connected set of components becomes one component.
            final = []
            for scc in sorted((sorted(c) for c in nx.strongly_connected_components(cg0)), key=lambda c: c[0]):
                final.append(sorted(m for name in scc for m in prov[name]))
                if len(scc) > 1:
                    merged.append(scc)
            comms = sorted(final, key=lambda c: (-len(c), c[0]))

        cids = []
        for members_c in comms:
            name = _component_name([by_id[m] for m in members_c], taken)
            cids.append(name)
            components.append({"id": name, "group": gname, "operations": members_c,
                               "operations_lean": [m for m in members_c if by_id[m]["compiles"]],
                               "entities_read": sorted({e for m in members_c for e in by_id[m]["entities_read"]}),
                               "entities_written": sorted({e for m in members_c for e in by_id[m]["entities_written"]})})
            for m in members_c:
                by_id[m]["component"] = name
        cg, reasons = _component_graph({c: comp_ops for c, comp_ops in zip(cids, comms)}, by_id, edges)
        order, feedback = chain_order(cg, reasons)
        how = ("ok" if acyclic else f"cyclic: {len(cycles)} cycle(s); " + (
            f"{len(merged)} set(s) of components merged" if CYCLE_MODE == "merge" else
            f"components kept, {len(feedback)} feedback edge(s) point against the chain order"))
        groups.append({"id": gname, "operations": list(members), "components": cids, "split": split,
                       "modularity": modularity,
                       "component_edges": [{"src": a, "dst": b, "reasons": reasons[(a, b)]}
                                           for a, b in sorted(cg.edges)],
                       "acyclic": acyclic, "cycles": cycles, "cycles_resolved": None if acyclic else CYCLE_MODE,
                       "merged_cycles": merged,
                       "feedback_edges": [{"src": a, "dst": b, "reasons": len(reasons[(a, b)])} for a, b in feedback],
                       "order": order, "status": how})

    total = sum(len(o["reads"]) + len(o["writes"]) + len(o["results"]) + len(o["unmapped"]) for o in ops)
    mapped = sum(len(o["reads"]) + len(o["writes"]) + len(o["results"]) for o in ops)
    used = sorted({e for o in ops for e in o["entities_read"] + o["entities_written"]})
    edge_list = [{"src": a, "dst": b, "reasons": rs} for (a, b), rs in sorted(edges.items())]
    return {
        "graph_version": GRAPH_VERSION,
        "source": doc.get("source", {}),
        "inputs": {},  # filled by the caller (paths relative to the repo root + hashes)
        "settings": {"max_component_ops": MAX_COMPONENT_OPS, "min_split_ops": MIN_SPLIT_OPS,
                     "min_modularity": MIN_MODULARITY, "cycles": CYCLE_MODE, "louvain_seed": LOUVAIN_SEED},
        "nlp": spacy_meta(),
        "entities": [{**v.entities[t], "used": t in used,
                      "attributes": sorted(a for a, owners in v.attributes.items() if t in owners)}
                     for t in sorted(v.entities)],
        "synonyms": dict(sorted(v.synonyms.items())),
        "operations": ops,
        "edges": edge_list,
        "groups": groups,
        "components": components,
        "isolated_operations": isolated,
        "unmapped_fields": [{"operation": o["id"], **u} for o in ops for u in o["unmapped"]],
        "metrics": {
            "operations": len(ops), "fields": total, "fields_mapped": mapped,
            "pct_fields_mapped": round(100 * mapped / total, 1) if total else 0.0,
            "entities": len(v.entities), "entities_used": len(used),
            "entities_used_by_source": dict(sorted(_count_sources(v, used).items())),
            "state_entities": sorted(v.state),
            "edges": len(edge_list),
            "edges_dataflow": sum(any(r["kind"] == "dataflow" for r in e["reasons"]) for e in edge_list),
            "edges_usecase": sum(any(r["kind"] != "dataflow" for r in e["reasons"]) for e in edge_list),
            "groups": len(groups), "components": len(components),
            "cycles": sum(len(g["cycles"]) for g in groups),
            "cyclic_groups": sum(not g["acyclic"] for g in groups),
            "merged_component_sets": sum(len(g["merged_cycles"]) for g in groups),
            "feedback_edges": sum(len(g["feedback_edges"]) for g in groups),
            "largest_component": max((len(c["operations"]) for c in components), default=0),
            "isolated_operations": len(isolated),
        },
    }


def _count_sources(v: Vocabulary, used: List[str]) -> Dict[str, int]:
    """How many of the entities that operations use come from each source (an entity named by
    several sources counts for each)."""
    out: Dict[str, int] = defaultdict(int)
    for t in used:
        for src in v.entities[t]["sources"]:
            out[src] += 1
    return out


def to_json(graph: dict) -> str:
    return json.dumps(graph, indent=2, ensure_ascii=False, sort_keys=False) + "\n"


# ---------------------------------------------------------------------------
# Rendering (not part of the determinism guarantee)
# ---------------------------------------------------------------------------

def to_dot(graph: dict) -> str:
    comp_of = {o["id"]: o.get("component") for o in graph["operations"]}
    lines = ["digraph G {", '  rankdir=LR; splines=true; node [shape=box, fontsize=9]; edge [fontsize=7];']
    for c in graph["components"]:
        lines.append(f'  subgraph "cluster_{c["id"]}" {{ label="{c["group"]} / {c["id"]}"; '
                     'style=filled; fillcolor="#eef3ff";')
        lines += [f'    "{op}";' for op in c["operations"]]
        lines.append("  }")
    for e in graph["edges"]:
        if comp_of.get(e["src"]) and comp_of.get(e["dst"]):
            label = ",".join(sorted({r.get("entity", r["kind"]) for r in e["reasons"]}))
            lines.append(f'  "{e["src"]}" -> "{e["dst"]}" [label="{label}"];')
    lines.append("}")
    return "\n".join(lines) + "\n"


def render_png(graph: dict, out: Path) -> str:
    """graph.png with graphviz `dot` if installed, else networkx + matplotlib. Returns the tool."""
    dot = to_dot(graph)
    (out.parent / "graph.dot").write_text(dot, encoding="utf-8")
    if shutil.which("dot"):
        r = subprocess.run(["dot", "-Tpng", "-o", str(out)], input=dot, text=True, capture_output=True)
        if r.returncode == 0:
            return "graphviz"
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    g = nx.DiGraph()
    comp = {o["id"]: o.get("component") or "-" for o in graph["operations"] if o.get("component")}
    g.add_nodes_from(sorted(comp))
    g.add_edges_from((e["src"], e["dst"]) for e in graph["edges"] if e["src"] in comp and e["dst"] in comp)
    names = sorted(set(comp.values()))
    colors = [names.index(comp[n]) for n in g.nodes]
    plt.figure(figsize=(16, 12))
    nx.draw_networkx(g, pos=nx.spring_layout(g, seed=LOUVAIN_SEED), node_color=colors, cmap="tab20",
                     font_size=6, node_size=300, arrowsize=8)
    plt.axis("off")
    plt.savefig(out, dpi=120, bbox_inches="tight")
    plt.close()
    return "matplotlib"


# ---------------------------------------------------------------------------
# Inputs and CLI
# ---------------------------------------------------------------------------

def benchmark_dir(stem: str) -> Path:
    """`0000 - gamma j` → benchmark/gammaj (leading number dropped, letters and digits kept)."""
    name = re.sub(r"[^a-z0-9]", "", re.sub(r"^\d+\s*-\s*", "", stem).lower())
    return ROOT / "benchmark" / name


def _hash(path: Path) -> Optional[str]:
    return hashlib.sha256(path.read_bytes()).hexdigest()[:12] if path.exists() else None


def _rel(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(ROOT))
    except ValueError:
        return str(path)


def load_inputs(stem: str, l0_run: Optional[Path] = None, domain: Optional[Path] = None,
                vocab: Optional[str] = None):
    parsed = ROOT / "Requirements" / "parsed" / f"{stem}.json"
    l0_run = l0_run or (ROOT / "runs" / stem / DEFAULT_L0_RUN)
    domain = domain or (benchmark_dir(stem) / "Domain.lean")
    syn = ROOT / "Requirements" / "synonyms" / f"{stem}.json"
    doc = json.loads(parsed.read_text(encoding="utf-8"))
    specs = json.loads((l0_run / "specs.json").read_text(encoding="utf-8"))
    vocab = vocab or VOCAB
    extras = vocab == "full"   # `srs`: no hand-written vocabulary at all
    domain_code = domain.read_text(encoding="utf-8") if extras and domain.exists() else None
    synonyms = json.loads(syn.read_text(encoding="utf-8")) if extras and syn.exists() else {}
    synonyms = synonyms.get("synonyms", synonyms)
    inputs = {"parsed": _rel(parsed), "parsed_sha": _hash(parsed),
              "l0_run": _rel(l0_run), "l0_specs_sha": _hash(l0_run / "specs.json"),
              "vocab": vocab,
              "domain": _rel(domain) if domain_code is not None else None,
              "domain_sha": _hash(domain) if domain_code is not None else None,
              "synonyms": _rel(syn) if synonyms else None, "synonyms_sha": _hash(syn) if synonyms else None,
              "synonyms_size": len(synonyms)}
    return doc, specs, domain_code, synonyms, inputs


def run(stem: str, l0_run: Optional[Path] = None, domain: Optional[Path] = None,
        out_dir: Optional[Path] = None, png: bool = True, vocab: Optional[str] = None) -> dict:
    doc, specs, domain_code, synonyms, inputs = load_inputs(stem, l0_run, domain, vocab)
    graph = build_graph(doc, specs, domain_code, synonyms)
    graph["inputs"] = inputs
    out_dir = out_dir or (ROOT / "runs" / stem / "graph")
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "graph.json").write_text(to_json(graph), encoding="utf-8")
    if png:
        try:
            render_png(graph, out_dir / "graph.png")
        except Exception as e:  # rendering is optional; graph.json is the result
            print(f"[graph] graph.png not written: {type(e).__name__}: {e}")
    return graph


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("doc", help="document stem, e.g. '0000 - gamma j' (or the .xml/.json path)")
    ap.add_argument("--l0-run", type=Path, help=f"L0 run folder with specs.json (default runs/<doc>/{DEFAULT_L0_RUN})")
    ap.add_argument("--domain", type=Path, help="Domain.lean (default benchmark/<doc>/Domain.lean)")
    ap.add_argument("-o", "--out", type=Path, help="output folder (default runs/<doc>/graph)")
    ap.add_argument("--no-png", action="store_true")
    ap.add_argument("--vocab", choices=["full", "srs"], default=None,
                    help="full: also use Domain.lean and the synonyms file if they exist (default, or "
                         "$CF_GRAPH_VOCAB); srs: only the SRS and the L0 specs")
    args = ap.parse_args(argv)
    stem = Path(args.doc).stem if args.doc.endswith((".xml", ".json")) else args.doc
    g = run(stem, args.l0_run, args.domain, args.out, png=not args.no_png, vocab=args.vocab)
    print(json.dumps(g["metrics"], indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
