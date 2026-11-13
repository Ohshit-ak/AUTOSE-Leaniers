# L0.5 report — 2009 - peppol approved.xml (qwen)

Compiles: 53/59 · rejects a bad example: 39 · ✅ pass 42 · ⚠️ flagged 8 · ❌ fail 9

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `0/S1` | requirement | — |
| ✅ | `0/S5` | requirement | — |
| ⚠️ | `0/S6` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `0/I2` | requirement | — |
| ✅ | `0/I6` | requirement | — |
| ✅ | `0/S17` | requirement | — |
| ✅ | `1.1/S1` | requirement | — |
| ❌ | `1.1/S4` | requirement | does not compile |
| ✅ | `1.1/I2` | requirement | — |
| ⚠️ | `1.1/I8` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { registrationCertificate := "123456" } { suitable := true }` holds, but the requirement forbids this output for this input (The requirement states that the output should be `suitable = true` if and only if the registration certificate is alp |
| ✅ | `1.2/S8` | requirement | — |
| ✅ | `1.2/S34` | requirement | — |
| ✅ | `2.3.1/I1` | requirement | — |
| ✅ | `2.3.2.1/S3` | requirement | — |
| ✅ | `2.3.2.4/S7` | requirement | — |
| ✅ | `2.3.3.3/I19` | requirement | — |
| ✅ | `3.1.2.1/S2` | requirement | — |
| ✅ | `3.1.2.2/S2` | requirement | — |
| ✅ | `3.1.2.8/S3` | requirement | — |
| ❌ | `3.1.2.9/S1` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ❌ | `3.1.2.12/S4` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { economicOperatorId := 1, candidateStatements := ["Statement 1", "Statement 2"] } ∧ ¬ Spec.post { economicOperatorId := 1, candidateStatements := ["Statement 1", "Statement 2"] } { issuedStatements := ["Statement 1", "Statement 2"] } := by unfold Spec; decide |
| ✅ | `3.2.2/I5` | requirement | — |
| ✅ | `3.2.2/I6` | requirement | — |
| ✅ | `3.2.3.1/S1` | requirement | — |
| ✅ | `3.2.3.2/S1` | requirement | — |
| ✅ | `3.2.4.4/S1` | requirement | — |
| ✅ | `3.2.4.7/S1` | requirement | — |
| ⚠️ | `3.2.4.9/S3` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `3.2.4.9/S9` | requirement | — |
| ✅ | `3.2.4.9/S11` | requirement | — |
| ✅ | `3.2.4.10/S4` | requirement | — |
| ⚠️ | `3.3.2.2/S2` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `3.3.2.3/S1` | requirement | — |
| ❌ | `3.3.2.4/S2` | requirement | does not compile |
| ✅ | `3.3.2.4/S3` | requirement | — |
| ❌ | `3.3.2.9/S3` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { evidence := "extract from the register of conviction" } ∧ ¬ Spec.post { evidence := "extract from the register of conviction" } { valid := true } := by unfold Spec; decide |
| ✅ | `3.3.2.12/S6` | requirement | — |
| ✅ | `3.4.2.3/S1` | requirement | — |
| ✅ | `3.4.2.4/S3` | requirement | — |
| ❌ | `3.4.2.6/S3` | requirement | does not compile |
| ✅ | `3.4.2.8/S8` | requirement | — |
| ⚠️ | `3.4.2.9/S2` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { tenders := ["tender1", "tender2"], openingTime := 100, currentTimestamp := 50 } { tenders := ["tender1", "tender2"], accepted := true }` holds, but the requirement forbids this output for this input (The requirement forbids accessing tender |
| ⚠️ | `4.1.2/S8` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `4.2/S9` | requirement | — |
| ✅ | `4.2/S10` | requirement | — |
| ✅ | `4.3.1/I2` | requirement | — |
| ✅ | `4.3.1/S6` | requirement | — |
| ❌ | `4.3.1/S8` | requirement | does not compile |
| ✅ | `4.3.1/S11` | requirement | — |
| ✅ | `4.3.1/S1#2` | requirement | — |
| ❌ | `4.4.1/S5` | requirement | does not compile |
| ✅ | `4.4.2/S1` | requirement | — |
| ⚠️ | `4.4.2/S3` | requirement | could not test whether `post` rejects anything (example not in `Spec.post {…} {…}` form) |
| ✅ | `5.1/S2` | requirement | — |
| ✅ | `5.1/S3` | requirement | — |
| ⚠️ | `5.1/S6` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `5.2.1/S19` | requirement | does not compile |
| ✅ | `5.2.2/S18` | requirement | — |
| ✅ | `5.3/S6` | requirement | — |
