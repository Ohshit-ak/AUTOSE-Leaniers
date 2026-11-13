# L0.5 report — 2006 - eirene sys 15.xml (qwen)

Compiles: 65/79 · rejects a bad example: 50 · ✅ pass 55 · ⚠️ flagged 8 · ❌ fail 16

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `3.3.4/S1` | requirement | — |
| ✅ | `3.4.3/S1` | requirement | — |
| ✅ | `3.7.2/S1` | requirement | — |
| ❌ | `3.7.3/S1` | requirement | the runtime bound `elapsedMicros <= 5000` is missing from `post` |
| ✅ | `3.8.2/S1` | requirement | — |
| ❌ | `3.8.3/S1` | requirement | does not compile |
| ✅ | `3.8.4/S1` | requirement | — |
| ❌ | `3.8.5/S1` | requirement | does not compile |
| ✅ | `4.3.5/S1` | requirement | — |
| ❌ | `4.4.3/S1` | requirement | does not compile |
| ✅ | `4.5.9/S1` | requirement | — |
| ❌ | `4.5.21/S1` | requirement | does not compile |
| ✅ | `4.5.36/S1` | requirement | — |
| ✅ | `5.3.9/S2` | requirement | — |
| ✅ | `5.3.12/S1` | requirement | — |
| ⚠️ | `5.4.2/S1` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `5.4.7/S1` | requirement | — |
| ✅ | `5.4.8/S1` | requirement | — |
| ✅ | `5.4.9/S1` | requirement | — |
| ⚠️ | `5.4.11/S1` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `5.5.2/S1` | requirement | — |
| ⚠️ | `5.5.3/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `5.5.9/S1` | requirement | — |
| ❌ | `5.5.10/S1` | requirement | does not compile |
| ✅ | `5.5.11/S1` | requirement | — |
| ✅ | `5.5.12/S1` | requirement | — |
| ❌ | `5.5.13/S2` | requirement | does not compile |
| ❌ | `5.5.20/I1` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `5.5.24/S1` | requirement | — |
| ❌ | `5.6.1/S1` | requirement | does not compile |
| ✅ | `5.6.2/S1` | requirement | — |
| ✅ | `5.6.3/S1` | requirement | — |
| ✅ | `5.6.4i/S1` | requirement | — |
| ✅ | `5.6.5/S1` | requirement | — |
| ✅ | `5.7.9/S1` | requirement | — |
| ⚠️ | `5.7.14/S1` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `5.7.15/S1` | requirement | — |
| ✅ | `7.3.3/S1` | requirement | — |
| ✅ | `7.5.5/S1` | requirement | — |
| ✅ | `7.5.9/S1` | requirement | — |
| ✅ | `8.2.2/S1` | requirement | — |
| ❌ | `8.2.3/S1` | requirement | does not compile |
| ✅ | `8.3.2/S1` | requirement | — |
| ✅ | `8.3.3/S1` | requirement | — |
| ✅ | `8.3.4/S1` | requirement | — |
| ✅ | `8.3.5/S1` | requirement | — |
| ✅ | `9.2.1/S1` | requirement | — |
| ✅ | `9.2.3/S1` | requirement | — |
| ⚠️ | `9.2.5/S1` | requirement | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
| ✅ | `9.2.6/S1` | requirement | — |
| ✅ | `9.2.8/S1` | requirement | — |
| ❌ | `9.5.3/I2` | requirement | does not compile |
| ❌ | `9.5.4/I2` | requirement | does not compile |
| ⚠️ | `9.10.3/S1` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { ac := "1234", number := "123456789012345" } { valid := true }` holds, but the requirement forbids this output for this input (The output should not be valid as the AC is not defined in table 9-13). Make `post` say when the failure outcome h |
| ❌ | `10.5.1/S1` | requirement | does not compile |
| ⚠️ | `11.3.8/S1` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { mobileNumber := "1234567890", networkNumber := "1234567890" } { valid := true }` holds, but the requirement forbids this output for this input (The output should indicate that the validation failed, but a buggy system might return true). Ma |
| ⚠️ | `11.3.8iii/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `11.3.9/S1` | requirement | — |
| ❌ | `11.3.9i/S1` | requirement | does not compile |
| ✅ | `11.3.12/S1` | requirement | — |
| ✅ | `11.3.15/S1` | requirement | — |
| ✅ | `11.5.3/S1` | requirement | — |
| ✅ | `11.5.4/S1` | requirement | — |
| ✅ | `11.6.3/S2` | requirement | — |
| ❌ | `13.2.3/S1` | requirement | does not compile |
| ✅ | `13.3.2/S1` | requirement | — |
| ❌ | `13.4.3/S1` | requirement | does not compile |
| ✅ | `13.5.2/S2` | requirement | — |
| ✅ | `13.5.3/S1` | requirement | — |
| ✅ | `13.5.5/S1` | requirement | — |
| ✅ | `13.5.6/S1` | requirement | — |
| ✅ | `13.5.7/S1` | requirement | — |
| ✅ | `13.5.8/S1` | requirement | — |
| ✅ | `13.5.9/S1` | requirement | — |
| ✅ | `13.5.10i/S1` | requirement | — |
| ✅ | `14.2.4/S1` | requirement | — |
| ✅ | `14.4.3/S1` | requirement | — |
| ✅ | `14.6.1/S1` | requirement | — |
| ✅ | `15.2.3/S1` | requirement | — |
