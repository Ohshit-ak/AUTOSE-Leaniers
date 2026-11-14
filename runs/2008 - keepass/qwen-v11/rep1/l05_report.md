# L0.5 report — 2008 - keepass.xml (qwen)

Compiles: 23/28 · rejects a bad example: 14 · ✅ pass 19 · ⚠️ flagged 2 · ❌ fail 7

| | Entry | Kind | Reasons |
|---|---|---|---|
| ❌ | `2.5/I4` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { passwords := ["password1", "password2"], active := true } ∧ ¬ Spec.post { passwords := ["password1", "password2"], active := true } { passwords := ["password1", "password2"], active := true } := by unfold Spec; decide |
| ✅ | `3.1.3/R1` | requirement | — |
| ✅ | `3.3.1/S1` | requirement | — |
| ✅ | `3.3.1/S2` | requirement | — |
| ✅ | `3.4.1/S4` | requirement | — |
| ❌ | `3.5.1/S4` | requirement | does not compile |
| ✅ | `3.6.1/S2` | requirement | — |
| ✅ | `3.6.1/S3` | requirement | — |
| ❌ | `3.8.1/S1` | requirement | does not compile |
| ✅ | `3.9.1/S3` | requirement | — |
| ✅ | `3.10.1/S1` | requirement | — |
| ❌ | `3.10.1/S4` | requirement | does not compile |
| ✅ | `3.10.1/S6` | requirement | — |
| ✅ | `3.10.3/R11` | requirement | — |
| ✅ | `3.11.1/S1` | requirement | — |
| ✅ | `3.11.1/S2` | requirement | — |
| ✅ | `3.11.1/S5` | requirement | — |
| ✅ | `3.11.3/R15` | requirement | — |
| ❌ | `3.12.1/S1` | requirement | does not compile |
| ✅ | `3.13.1/S1` | requirement | — |
| ✅ | `3.13.3/S1` | requirement | — |
| ✅ | `3.14.1/S1` | requirement | — |
| ✅ | `3.14.1/S6` | requirement | — |
| ✅ | `3.15.1/I3` | requirement | — |
| ❌ | `3.20.1/S4` | requirement | does not compile |
| ❌ | `3.21.1/S2` | requirement | does not compile |
| ⚠️ | `3.21.1/S3` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …); could not test whether `post` rejects anything (no field types to vary) |
| ⚠️ | `3.21.1/S4` | requirement | could not test whether `post` rejects anything (no field types to vary) |
