"""JSON Schemas (draft 2020-12) of the files the pipeline stages hand to each other.

These are the *contracts between stages*: the parser writes Requirements/parsed/*.json for the
spec agent and L0.5; L0 writes specs.json + review.json for the chain path; the chain path
writes chain_meta.json + l1l2.json for the evaluation scripts. A stage may add a field
(`additionalProperties` is open on records that grew between versions), but a field a
consumer reads must be there with the type the consumer expects.
"""

_STR, _INT, _BOOL, _NUM = {"type": "string"}, {"type": "integer"}, {"type": "boolean"}, {"type": "number"}
_STRS = {"type": "array", "items": _STR}
_NULL_STR = {"type": ["string", "null"]}
_NULL_BOOL = {"type": ["boolean", "null"]}
_COMPARATOR = {"enum": ["<", "<=", ">", ">=", "="]}


def _obj(required: dict, optional: dict = None, closed: bool = True) -> dict:
    return {"type": "object", "properties": {**required, **(optional or {})}, "required": list(required),
            "additionalProperties": not closed}


# ---------------------------------------------------------------------------
# Requirements/parsed/<doc>.json   (req_parser.py → spec agent, validate.py, req_graph.py)
# ---------------------------------------------------------------------------

QUANTITY = _obj({"kind": {"enum": ["time", "throughput", "count", "percent"]}, "value": _NUM, "unit": _STR,
                 "comparator": _COMPARATOR}, {"micros": _INT, "per_second": _NUM})
RUNTIME_CHECK = _obj({"metric": {"enum": ["latency", "throughput", "concurrency"]}, "operation": _STR,
                      "comparator": _COMPARATOR, "bound": _INT, "unit": _STR,
                      "lean_field": {"enum": ["elapsedMicros", "perSecond", "concurrentUsers"]}})
REQUIREMENT = _obj({"id": _STR, "kind": {"const": "requirement"},
                    "category": {"enum": ["functional", "quantitative", "performance"]},
                    "verification": {"enum": ["lean", "lean+python_runtime"]}, "section": _STR,
                    "section_path": _STRS, "text": {"type": "string", "minLength": 1}, "signals": _STRS,
                    "quantities": {"type": "array", "items": QUANTITY}, "has_precondition": _BOOL},
                   {"runtime_checks": {"type": "array", "items": RUNTIME_CHECK, "minItems": 1},
                    "ignore_terms": {"type": "array", "items": _STR, "minItems": 1},
                    "glossary_refs": {"type": "array", "items": _STR, "minItems": 1}})
CONSTRAINTS = _obj({}, {"min_length": _INT, "max_length": _INT, "exact_length": _INT,
                        "charset": {"enum": ["alphanumeric", "alphabetic", "numeric"]}, "unique": {"const": True},
                        "generated_by": {"const": "system"}, "format": _STR, "type": {"const": "money"},
                        "precision": {"const": "cents"}, "default": _INT, "max_ref": _STR, "tuple_fields": _STRS})
CONSTRAINTS["minProperties"] = 1
DATA_CONSTRAINT = _obj({"id": {"type": "string", "pattern": "^DD-"}, "kind": {"const": "data_constraint"},
                        "field": _STR, "description": _STR, "constraints": CONSTRAINTS})
_GOTO = _obj({"step": _INT}, {"resolves_to": {"type": ["integer", "string"]}})
_STEP = _obj({"step": _INT, "actor": {"enum": ["system", "user"]}, "type": {"enum": ["action", "event", "goto"]},
              "text": _STR}, {"goto": _GOTO})
USE_CASE = _obj({"id": {"type": "string", "pattern": "^UC-"}, "kind": {"const": "use_case"}, "group": _STR,
                 "name": _STR, "goal": _STR, "actors": _STRS, "preconditions": _STRS,
                 "basic_scenario": {"type": "array", "items": _STEP},
                 "alternative_scenarios": {"type": "array", "items": _obj({"flow": _STR,
                                                                           "steps": {"type": "array", "items": _STEP}})},
                 "postconditions": _STRS})
DROPPED = _obj({"id": _STR, "source": {"enum": ["requirement", "data_dictionary", "use_case", "use_case_step"]},
                "section": _STR, "text": _STR, "reason": {"type": "string", "minLength": 1}})
PARSED_DOC = _obj({"schema_version": {"const": "1.0"},
                   "source": _obj({"file": _STR, "sha256": {"type": "string", "pattern": "^[0-9a-f]{64}$"}}),
                   "titles": _STRS,
                   "stats": _obj({"requirements": _INT, "data_constraints": _INT, "use_cases": _INT, "dropped": _INT}),
                   "glossary": {"type": "array", "items": _obj({"term": _STR, "meaning": _STR})},
                   "requirements": {"type": "array", "items": REQUIREMENT},
                   "data_dictionary": {"type": "array", "items": DATA_CONSTRAINT},
                   "use_cases": {"type": "array", "items": USE_CASE},
                   "dropped": {"type": "array", "items": DROPPED}})

# ---------------------------------------------------------------------------
# runs/<doc>/<l0 run>/repN/specs.json + review.json   (main.py L0 → chain_pipeline, evaluation)
# ---------------------------------------------------------------------------

RUN_META = _obj({"harness_version": _STR, "model": _STR, "model_id": _STR, "temperature": _NUM,
                 "restart_temperature": _NUM, "seed": _INT, "repetition": _INT,
                 "git_commit": _STR, "git_dirty": _BOOL}, closed=False)
L05 = _obj({"status": {"enum": ["pass", "flag", "fail"]}, "problems": _STRS, "flags": _STRS},
           {"strength": _obj({"output_free": _STRS, "output_problems": _STRS, "unrealizable_inputs": _STRS,
                              "trivial": _BOOL, "witness": _NULL_STR, "copy_ok": _BOOL,
                              "class": {"enum": ["strong", "weak", "copy-ok", "unrealizable"]}})})
SPEC_RESULT = _obj({"id": _STR, "kind": {"enum": ["requirement", "data_constraint", "use_case"]},
                    "requirement_text": _STR, "lean_predicate": _STR, "compiles": _NULL_BOOL,
                    "checked": _NULL_BOOL, "attempts": _INT, "l05": L05},
                   {"rejects_bad_example": _NULL_BOOL, "bad_example": _NULL_STR, "seconds": _NUM}, closed=False)
SPECS = _obj({"source": _obj({"file": _STR, "sha256": _STR}), "model": _STR,
              "summary": _obj({"total": _INT, "checked": _INT}, closed=False),
              "results": {"type": "array", "items": SPEC_RESULT},
              "l05_summary": _obj({"pass": _INT, "flag": _INT, "fail": _INT})},
             {"meta": RUN_META, "lean_checked": _BOOL}, closed=False)
REVIEW = {"type": "object", "additionalProperties": _obj(
    {"status": {"enum": ["pass", "flag", "fail"]}, "decision": {"enum": ["accept", "review", "redo", "exclude"]},
     "reasons": _STRS, "note": _STR})}

# ---------------------------------------------------------------------------
# runs/<doc>/<chain run>/repN/chain_meta.json + l1l2.json   (chain_pipeline → summarize_e2e)
# ---------------------------------------------------------------------------

CHAIN_META = _obj({"harness_version": {"type": "string", "pattern": "^chain-v\\d+$"}, "model": _STR, "model_id": _STR,
                   "temperature": _NUM, "restart_temperature": _NUM, "seed": _INT, "repetition": _INT,
                   "git_commit": _STR, "git_dirty": _BOOL, "l0_prompt_hash": _STR,
                   "prompt_hash": _obj({"architect": _STR, "coder": _STR}), "l0_run": _STR,
                   "split": {"enum": ["auto", "always", "never"]}, "fallback_single": _BOOL}, closed=False)
_STAGES = {"type": "array", "items": _NULL_STR}
_FAILED_SPLIT = _obj({"error": _STR, "error_class": _NULL_STR, "stages": _STAGES, "code": _STR})
L1 = _obj({"success": _BOOL, "mode": {"enum": ["chain", "single", "single-fallback", "single-not-decomposable"]},
           "attempts": _INT, "contracts": _STRS, "strength": {"type": ["object", "null"]}, "error": _STR,
           "error_class": _NULL_STR, "stages": _STAGES, "code": _STR},
          {"why_single": _STR, "repairs": _STRS, "carried_by_harness": _STRS, "stopped": _STR,
           "failed_split": _FAILED_SPLIT})
L2 = _obj({"contract": _STR, "success": _BOOL, "attempts": _INT, "error": _STR, "error_class": _NULL_STR,
           "stages": _STAGES, "code": _STR},
          {"harness_only": _BOOL, "fields": _obj({"harness": _STRS, "model": _STRS}), "stopped": _STR})
SPEC_CHECK = _obj({"trivial": _BOOL}, {"witness": _STR, "copy_ok": _BOOL,
                                       "l05_class": {"enum": ["strong", "weak", "copy-ok", "unrealizable", None]}})
CHAIN_RECORD = _obj({"id": _STR, "kind": {"enum": ["requirement", "data_constraint", "use_case"]},
                     "requirement_text": _STR, "l1": L1, "l2": {"type": "array", "items": L2, "maxItems": 2},
                     "seconds": _NUM},
                    {"spec_check": SPEC_CHECK, "system_theorem": _STR, "full_check": _BOOL, "l2_root_cause": _STR})
CHAIN_RUN = {"type": "array", "items": CHAIN_RECORD}
