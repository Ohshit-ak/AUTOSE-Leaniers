# L0.5 report — 2009 - peppol approved.xml (qwen)

Compiles: 50/59 · rejects a bad example: 40 · ✅ pass 44 · ⚠️ flagged 4 · ❌ fail 11

| | Entry | Kind | Reasons |
|---|---|---|---|
| ❌ | `0/S1` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `0/S5` | requirement | — |
| ✅ | `0/S6` | requirement | — |
| ❌ | `0/I2` | requirement | does not compile |
| ❌ | `0/I6` | requirement | does not compile |
| ✅ | `0/S17` | requirement | — |
| ✅ | `1.1/S1` | requirement | — |
| ✅ | `1.1/S4` | requirement | — |
| ❌ | `1.1/I2` | requirement | does not compile |
| ✅ | `1.1/I8` | requirement | — |
| ❌ | `1.2/S8` | requirement | does not compile |
| ✅ | `1.2/S34` | requirement | — |
| ✅ | `2.3.1/I1` | requirement | — |
| ✅ | `2.3.2.1/S3` | requirement | — |
| ✅ | `2.3.2.4/S7` | requirement | — |
| ✅ | `2.3.3.3/I19` | requirement | — |
| ✅ | `3.1.2.1/S2` | requirement | — |
| ✅ | `3.1.2.2/S2` | requirement | — |
| ✅ | `3.1.2.8/S3` | requirement | — |
| ✅ | `3.1.2.9/S1` | requirement | — |
| ✅ | `3.1.2.12/S4` | requirement | — |
| ✅ | `3.2.2/I5` | requirement | — |
| ✅ | `3.2.2/I6` | requirement | — |
| ✅ | `3.2.3.1/S1` | requirement | — |
| ✅ | `3.2.3.2/S1` | requirement | — |
| ⚠️ | `3.2.4.4/S1` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `3.2.4.7/S1` | requirement | — |
| ❌ | `3.2.4.9/S3` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output; `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `3.2.4.9/S9` | requirement | — |
| ❌ | `3.2.4.9/S11` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { attestation := "Sample attestation", contextData := ["short", "longer than 100 characters"], language := "en" } ∧ ¬ Spec.post { attestation := "Sample attestation", contextData := ["short", "longer than 100 characters"], language := "en" } { included := true } := by unfold Spec; decide |
| ✅ | `3.2.4.10/S4` | requirement | — |
| ⚠️ | `3.3.2.2/S2` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `3.3.2.3/S1` | requirement | — |
| ❌ | `3.3.2.4/S2` | requirement | does not compile |
| ✅ | `3.3.2.4/S3` | requirement | — |
| ✅ | `3.3.2.9/S3` | requirement | — |
| ✅ | `3.3.2.12/S6` | requirement | — |
| ❌ | `3.4.2.3/S1` | requirement | does not compile |
| ✅ | `3.4.2.4/S3` | requirement | — |
| ✅ | `3.4.2.6/S3` | requirement | — |
| ✅ | `3.4.2.8/S8` | requirement | — |
| ✅ | `3.4.2.9/S2` | requirement | — |
| ⚠️ | `4.1.2/S8` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `4.2/S9` | requirement | — |
| ✅ | `4.2/S10` | requirement | — |
| ✅ | `4.3.1/I2` | requirement | — |
| ✅ | `4.3.1/S6` | requirement | — |
| ✅ | `4.3.1/S8` | requirement | — |
| ✅ | `4.3.1/S11` | requirement | — |
| ✅ | `4.3.1/S1#2` | requirement | — |
| ❌ | `4.4.1/S5` | requirement | does not compile |
| ✅ | `4.4.2/S1` | requirement | — |
| ⚠️ | `4.4.2/S3` | requirement | could not test whether `post` rejects anything (example not in `Spec.post {…} {…}` form) |
| ❌ | `5.1/S2` | requirement | does not compile |
| ✅ | `5.1/S3` | requirement | — |
| ✅ | `5.1/S6` | requirement | — |
| ✅ | `5.2.1/S19` | requirement | — |
| ✅ | `5.2.2/S18` | requirement | — |
| ✅ | `5.3/S6` | requirement | — |
