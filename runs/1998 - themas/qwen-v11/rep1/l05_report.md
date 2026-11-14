# L0.5 report — 1998 - themas.xml (qwen)

Compiles: 24/30 · rejects a bad example: 16 · ✅ pass 18 · ⚠️ flagged 2 · ❌ fail 10

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `2.4/S4` | requirement | — |
| ✅ | `3.1.1.1.3/S1` | requirement | — |
| ✅ | `3.1.1.2.1/S1` | requirement | — |
| ✅ | `3.1.1.2.3/S2` | requirement | — |
| ✅ | `3.1.1.3.1/S1` | requirement | — |
| ✅ | `3.1.1.3.3/S1` | requirement | — |
| ✅ | `3.1.1.3.3/S2` | requirement | — |
| ✅ | `3.1.3.3/S1` | requirement | — |
| ❌ | `3.1.3.3/S3` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { temperature := 50, valid_min := 30, valid_max := 70 } ∧ ¬ Spec.post { temperature := 50, valid_min := 30, valid_max := 70 } { within_range := true } := by unfold Spec; decide |
| ⚠️ | `3.1.3.3/S4` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `3.1.3.3/S6` | requirement | — |
| ✅ | `3.1.4.1.1/S1` | requirement | — |
| ❌ | `3.1.4.1.3/S1` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { reportedTemp := 101, setting := 100, upperLimit := 110, lowerLimit := 90 } ∧ ¬ Spec.post { reportedTemp := 101, setting := 100, upperLimit := 110, lowerLimit := 90 } { status := "within limits" } := by unfold Spec; decide |
| ⚠️ | `3.1.4.1.3/S2` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `3.1.5.1.1/S2` | requirement | — |
| ✅ | `3.1.5.1.3/S3` | requirement | — |
| ❌ | `3.1.5.1.3/S4` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `3.1.5.1.3/S5` | requirement | — |
| ❌ | `3.1.5.1.3/S6` | requirement | does not compile |
| ❌ | `3.1.5.1.3/S7` | requirement | does not compile |
| ✅ | `3.1.5.3.3/S2` | requirement | — |
| ✅ | `3.1.6.3/S1` | requirement | — |
| ✅ | `3.1.6.3/S5` | requirement | — |
| ❌ | `3.1.6.3/S6` | requirement | does not compile |
| ✅ | `3.1.7.3/S1` | requirement | — |
| ❌ | `3.1.7.3/S2` | requirement | does not compile |
| ❌ | `3.1.7.3/S5` | requirement | does not compile |
| ❌ | `3.1.9.1/S1` | requirement | does not compile |
| ✅ | `3.1.10.3/S3` | requirement | — |
| ❌ | `3.1.10.3/I2` | requirement | does not compile |
