# L0.5 report — 2010-blitdraft.xml (qwen)

Compiles: 12/13 · rejects a bad example: 7 · ✅ pass 7 · ⚠️ flagged 3 · ❌ fail 3

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `2.1.1.2.1.1/S1` | requirement | — |
| ❌ | `2.1.1.2.1.5/S1` | requirement | does not compile |
| ⚠️ | `2.1.1.2.1.6/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ⚠️ | `2.1.1.2.1.7/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `2.1.1.2.1.8/S1` | requirement | — |
| ✅ | `2.1.1.2.1.9/S1` | requirement | — |
| ❌ | `2.1.1.2.1.10/S1` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `2.1.1.2.1.11/S1` | requirement | — |
| ❌ | `2.2.1.1/S1` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { stakeholders := ["Alice", "Bob"], changes := ["New Login Screen"] } ∧ ¬ Spec.post { stakeholders := ["Alice", "Bob"], changes := ["New Login Screen"] } { demonstrated := false } := by unfold Spec; decide |
| ⚠️ | `2.3.1.1/S1` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `2.5.2.4/S1` | requirement | — |
| ✅ | `2.6.3.1/S1` | requirement | — |
| ✅ | `2.6.3.4/S1` | requirement | — |
