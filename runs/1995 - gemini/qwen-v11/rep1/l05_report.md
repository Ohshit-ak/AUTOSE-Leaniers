# L0.5 report — 1995 - gemini.xml (qwen)

Compiles: 47/54 · rejects a bad example: 35 · ✅ pass 37 · ⚠️ flagged 8 · ❌ fail 9

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `2.6.3/I6` | requirement | — |
| ✅ | `2.6.3/S17` | requirement | — |
| ⚠️ | `2.6.3/I8` | requirement | could not test whether `post` rejects anything (example not in `Spec.post {…} {…}` form) |
| ✅ | `2.7.1/S6` | requirement | — |
| ⚠️ | `2.7.2/S5` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ❌ | `2.9.2.1/I1` | requirement | does not compile |
| ✅ | `2.9.2.1/I6` | requirement | — |
| ✅ | `2.9.3/I1` | requirement | — |
| ⚠️ | `2.9.3/I2` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `2.10/S4` | requirement | — |
| ⚠️ | `2.10/I7` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `2.12/S1` | requirement | — |
| ✅ | `2.13.2/S3` | requirement | — |
| ❌ | `2.14.3/I4` | requirement | does not compile |
| ✅ | `2.14.3/I7` | requirement | — |
| ✅ | `2.14.4/I3` | requirement | — |
| ⚠️ | `3.1.1/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `3.1.2.1/S1` | requirement | does not compile |
| ⚠️ | `3.1.2.1/S6` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `3.2.1.3/S3` | requirement | does not compile |
| ✅ | `3.2.3/S1` | requirement | — |
| ❌ | `3.2.3/S12` | requirement | `i.activeNodes ≥ 0` is always true for a `Nat` and says nothing; state a real condition on it or drop it |
| ✅ | `3.2.5/S3` | requirement | — |
| ✅ | `3.2.5/S6` | requirement | — |
| ✅ | `3.3.1/S2` | requirement | — |
| ✅ | `3.3.1/S6` | requirement | — |
| ✅ | `3.3.2/S7` | requirement | — |
| ✅ | `3.3.3.3/S2` | requirement | — |
| ✅ | `3.3.4.1/I1` | requirement | — |
| ✅ | `3.3.4.1/I3` | requirement | — |
| ✅ | `3.4.1/S8` | requirement | — |
| ✅ | `3.4.2/S7` | requirement | — |
| ✅ | `3.4.3/I6` | requirement | — |
| ✅ | `3.4.3/I12` | requirement | — |
| ⚠️ | `3.4.3/S4` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `3.5.4/I2` | requirement | — |
| ✅ | `3.5.4.1/I1` | requirement | — |
| ✅ | `3.5.6.2/S3` | requirement | — |
| ✅ | `3.5.6.2/I2` | requirement | — |
| ✅ | `3.5.6.2/I5` | requirement | — |
| ⚠️ | `3.5.9/S6` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `4.2.2.1/S3` | requirement | — |
| ✅ | `4.2.4.1/I4` | requirement | — |
| ✅ | `4.2.4.1/I5` | requirement | — |
| ❌ | `4.2.4.1/I6` | requirement | does not compile |
| ✅ | `4.2.4.2/I3` | requirement | — |
| ❌ | `4.2.4.2/I4` | requirement | does not compile |
| ✅ | `4.3.1/S2` | requirement | — |
| ❌ | `4.3.1.2.1/I1` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { records := [{ name := "record1", field1 := "value1", field2 := "value2" }, { name := "record2", field1 := "value3", field2 := "value4" }, { name := "record1", field1 := "value5", field2 := "value6" }] } ∧ ¬ Spec.post { records := [{ name := "record1", field1 := "value1", field2 := "value2" }, { name := "record2", field1 := "value3", field2 := "value4" }, { name := "record1", field1 := "value5", field2 := "value6" }] } { records := [{ name := "record1", field1 := "value1", field2 := "value2" }, { name := "record2", field1 := "value3", field2 := "value4" }, { name := "record1", field1 := "value5", field2 := "value6" }] } := by unfold Spec; decide |
| ❌ | `4.3.1.2.1/I3` | requirement | does not compile |
| ✅ | `4.3.1.2.1/I4` | requirement | — |
| ✅ | `4.3.1.2.1/I5` | requirement | — |
| ✅ | `4.3.1.2.2/S5` | requirement | — |
| ✅ | `4.3.3/I3` | requirement | — |
