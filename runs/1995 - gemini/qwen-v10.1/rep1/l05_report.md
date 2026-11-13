# L0.5 report — 1995 - gemini.xml (qwen)

Compiles: 46/54 · rejects a bad example: 33 · ✅ pass 37 · ⚠️ flagged 6 · ❌ fail 11

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `2.6.3/I6` | requirement | — |
| ✅ | `2.6.3/S17` | requirement | — |
| ⚠️ | `2.6.3/I8` | requirement | could not test whether `post` rejects anything (example not in `Spec.post {…} {…}` form) |
| ⚠️ | `2.7.1/S6` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { command := "invalid-command" } { accepted := true, transmitted := true }` holds, but the requirement forbids this output for this input (The requirement states that there should be minimal checking and delay, but it does not specify that co |
| ✅ | `2.7.2/S5` | requirement | — |
| ❌ | `2.9.2.1/I1` | requirement | does not compile |
| ✅ | `2.9.2.1/I6` | requirement | — |
| ✅ | `2.9.3/I1` | requirement | — |
| ⚠️ | `2.9.3/I2` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `2.10/S4` | requirement | — |
| ✅ | `2.10/I7` | requirement | — |
| ✅ | `2.12/S1` | requirement | — |
| ✅ | `2.13.2/S3` | requirement | — |
| ✅ | `2.14.3/I4` | requirement | — |
| ✅ | `2.14.3/I7` | requirement | — |
| ✅ | `2.14.4/I3` | requirement | — |
| ⚠️ | `3.1.1/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `3.1.2.1/S1` | requirement | — |
| ❌ | `3.1.2.1/S6` | requirement | does not compile |
| ❌ | `3.2.1.3/S3` | requirement | does not compile |
| ❌ | `3.2.3/S1` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { nodes := [{ workstations := 1 }, { workstations := 2 }] } ∧ ¬ Spec.post { nodes := [{ workstations := 1 }, { workstations := 2 }] } { capacityNodes := 3, capacityUsers := 3 } := by unfold Spec; decide |
| ✅ | `3.2.3/S12` | requirement | — |
| ❌ | `3.2.5/S3` | requirement | does not compile |
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
| ✅ | `3.4.3/S4` | requirement | — |
| ⚠️ | `3.5.4/I2` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { currentCapabilities := 10, currentPerformance := 5, upgradeAreas := ["Area1"], estimatedEffort := [], estimatedResources := [] } { upgradedCapabilities := 11, upgradedPerformance := 6, upgradeAreas := ["Area1"], estimatedEffort := [], estim |
| ✅ | `3.5.4.1/I1` | requirement | — |
| ✅ | `3.5.6.2/S3` | requirement | — |
| ✅ | `3.5.6.2/I2` | requirement | — |
| ✅ | `3.5.6.2/I5` | requirement | — |
| ⚠️ | `3.5.9/S6` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ❌ | `4.2.2.1/S3` | requirement | does not compile |
| ✅ | `4.2.4.1/I4` | requirement | — |
| ❌ | `4.2.4.1/I5` | requirement | does not compile |
| ✅ | `4.2.4.1/I6` | requirement | — |
| ✅ | `4.2.4.2/I3` | requirement | — |
| ✅ | `4.2.4.2/I4` | requirement | — |
| ❌ | `4.3.1/S2` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `4.3.1.2.1/I1` | requirement | — |
| ❌ | `4.3.1.2.1/I3` | requirement | does not compile |
| ❌ | `4.3.1.2.1/I4` | requirement | does not compile |
| ❌ | `4.3.1.2.1/I5` | requirement | `i.mask ≥ 0` is always true for a `Nat` and says nothing; state a real condition on it or drop it |
| ✅ | `4.3.1.2.2/S5` | requirement | — |
| ✅ | `4.3.3/I3` | requirement | — |
