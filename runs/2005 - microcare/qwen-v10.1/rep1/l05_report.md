# L0.5 report — 2005 - microcare.xml (qwen)

Compiles: 27/34 · rejects a bad example: 17 · ✅ pass 21 · ⚠️ flagged 5 · ❌ fail 8

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `2.1.1/I1` | requirement | — |
| ✅ | `2.1.1/I9` | requirement | — |
| ❌ | `2.1.1/I11` | requirement | does not compile |
| ✅ | `2.1.1/I12` | requirement | — |
| ❌ | `2.1.1/I13` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `1./S2` | requirement | — |
| ✅ | `1./I7` | requirement | — |
| ⚠️ | `1./I11` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `Design Constraints/I1` | requirement | — |
| ✅ | `Design Constraints/I2` | requirement | — |
| ⚠️ | `Design Constraints/I3` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `i/S2` | requirement | — |
| ✅ | `Design Constraints/S2` | requirement | — |
| ❌ | `Design Constraints/S5` | requirement | does not compile |
| ⚠️ | `Design Constraints/I9` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ❌ | `Design Constraints/S3#2` | requirement | does not compile |
| ✅ | `iii/I5` | requirement | — |
| ✅ | `3./S2` | requirement | — |
| ✅ | `3./I5` | requirement | — |
| ✅ | `Design Constraints/S3#4` | requirement | — |
| ✅ | `Design Constraints/S15` | requirement | — |
| ❌ | `Design Constraints/S19` | requirement | does not compile |
| ❌ | `Design Contraints/S3` | requirement | does not compile |
| ✅ | `iv/S3` | requirement | — |
| ❌ | `For Second Follow UP/S1` | requirement | does not compile |
| ❌ | `Design Constraints/S2#6` | requirement | does not compile |
| ✅ | `Design Constraints/I17` | requirement | — |
| ⚠️ | `Design Constraints/S9#3` | requirement | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
| ⚠️ | `Assumptions/I5` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { treatments := [{ code := "A", amount := 100 }, { code := "B", amount := 200 }, { code := "A", amount := 150 }] } { claimAmount := 450 }` holds, but the requirement forbids this output for this input (The output should not include any claim  |
| ✅ | `Assumptions/I2#2` | requirement | — |
| ✅ | `Design Constraints/I1#9` | requirement | — |
| ✅ | `Design Constraints/I2#9` | requirement | — |
| ✅ | `Design Constraints/I3#9` | requirement | — |
| ✅ | `Design Constraints/I4#8` | requirement | — |
