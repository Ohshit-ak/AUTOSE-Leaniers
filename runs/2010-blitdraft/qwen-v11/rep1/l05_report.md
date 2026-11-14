# L0.5 report — 2010-blitdraft.xml (qwen)

Compiles: 10/13 · rejects a bad example: 7 · ✅ pass 7 · ⚠️ flagged 1 · ❌ fail 5

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `2.1.1.2.1.1/S1` | requirement | — |
| ❌ | `2.1.1.2.1.5/S1` | requirement | does not compile |
| ❌ | `2.1.1.2.1.6/S1` | requirement | does not compile |
| ⚠️ | `2.1.1.2.1.7/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `2.1.1.2.1.8/S1` | requirement | — |
| ✅ | `2.1.1.2.1.9/S1` | requirement | — |
| ❌ | `2.1.1.2.1.10/S1` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `2.1.1.2.1.11/S1` | requirement | — |
| ❌ | `2.2.1.1/S1` | requirement | does not compile |
| ❌ | `2.3.1.1/S1` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { dayOfWeek := 2, timeOfDay := 4200, updateScheduled := true } ∧ ¬ Spec.post { dayOfWeek := 2, timeOfDay := 4200, updateScheduled := true } { updateScheduled := true } := by unfold Spec; decide |
| ✅ | `2.5.2.4/S1` | requirement | — |
| ✅ | `2.6.3.1/S1` | requirement | — |
| ✅ | `2.6.3.4/S1` | requirement | — |
