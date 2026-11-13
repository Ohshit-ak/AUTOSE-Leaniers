# L0.5 report — 1999 - dii.xml (qwen)

Compiles: 7/8 · rejects a bad example: 5 · ✅ pass 5 · ⚠️ flagged 0 · ❌ fail 3

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `4.1/I1` | requirement | — |
| ✅ | `4.1/I3` | requirement | — |
| ❌ | `4.1/I6` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ❌ | `1/I6` | requirement | does not compile |
| ✅ | `4.14.2/S2` | requirement | — |
| ✅ | `4.14.7/I4` | requirement | — |
| ❌ | `4.14.7/I5` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { tags := ["tag1", "tag2", "tag3"] } ∧ ¬ Spec.post { tags := ["tag1", "tag2", "tag3"] } { consolidatedTags := ["tag1"], length := 1 } := by unfold Spec; decide |
| ✅ | `Include descriptive definitions AND synonyms for the Information Resource Definition./S1` | requirement | — |
