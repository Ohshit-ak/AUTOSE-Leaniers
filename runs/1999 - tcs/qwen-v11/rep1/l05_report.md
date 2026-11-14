# L0.5 report — 1999 - tcs.xml (qwen)

Compiles: 56/70 · rejects a bad example: 37 · ✅ pass 46 · ⚠️ flagged 6 · ❌ fail 18

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `1.2.2/S4` | requirement | — |
| ✅ | `3.1/S1` | requirement | — |
| ✅ | `3.1.1/S2` | requirement | — |
| ❌ | `3.1.1.1/S1` | requirement | does not compile |
| ✅ | `3.1.1.2/S1` | requirement | — |
| ❌ | `3.2.1/S4` | requirement | does not compile |
| ✅ | `3.2.1/S5` | requirement | — |
| ✅ | `3.2.1/S6` | requirement | — |
| ❌ | `3.2.1.1/S1` | requirement | does not compile |
| ✅ | `3.2.1.1/I5` | requirement | — |
| ❌ | `3.2.1.1/S2` | requirement | does not compile |
| ⚠️ | `3.2.1.1.1/S2` | requirement | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
| ❌ | `3.2.1.2/S1` | requirement | does not compile |
| ✅ | `3.2.2/S2` | requirement | — |
| ✅ | `3.2.2.1/S1` | requirement | — |
| ✅ | `3.2.2.1/S2` | requirement | — |
| ✅ | `3.2.2.1.1/S1` | requirement | — |
| ❌ | `3.2.2.1.1.1/S1` | requirement | `post` fixes `o.flightBehavior` elsewhere, so `i.manualOverride → o.flightBehavior = "manual"` only says `i.manualOverride → (i.flightBehavior) = "manual"` about the input, and `pre` does not ensure that: no implementation can make it true. If the requirement assumes it, add it to `pre`; if the output should differ from the input (e.g. keep only the elements that satisfy it), change the condition that fixes `o.flightBehavior`.; `post` fixes `o.flightBehavior`, `o.manualOverride` elsewhere, so `∀ c ∈ i.controlCommands, o.flightBehavior = "manual" → (c = "override" ↔ o.manualOverride = true)` only says `∀ c ∈ i.controlCommands, (i.flightBehavior) = "manual" → (c = "override" ↔ (i.manualOverride) = true)` about the input, and `pre` does not ensure that: no implementation can make it true. If the requirement assumes it, add it to `pre`; if the output should differ from the input (e.g. keep only the elements that satisfy it), change the condition that fixes `o.flightBehavior`, `o.manualOverride`. |
| ❌ | `3.2.2.1.2/S1` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ⚠️ | `3.2.2.1.3/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `3.2.2.1.5/S1` | requirement | does not compile |
| ⚠️ | `3.2.2.1.5.1/S1` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ⚠️ | `3.2.2.1.5.1/S2` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `3.2.2.2/S1` | requirement | — |
| ❌ | `3.2.2.2/S3` | requirement | does not compile |
| ✅ | `3.2.2.2.1/S1` | requirement | — |
| ❌ | `3.2.2.2.2.1/S1` | requirement | does not compile |
| ✅ | `3.2.2.3.1/S1` | requirement | — |
| ❌ | `3.2.2.3.2/S1` | requirement | does not compile |
| ✅ | `3.2.3/S1` | requirement | — |
| ✅ | `3.2.3.1/S1` | requirement | — |
| ❌ | `3.2.3.1/S3` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `3.2.3.1/S4` | requirement | — |
| ✅ | `3.2.3.2/S1` | requirement | — |
| ✅ | `3.2.3.3/S1` | requirement | — |
| ✅ | `3.2.3.3/S2` | requirement | — |
| ✅ | `3.2.5/S5` | requirement | — |
| ✅ | `3.2.5/S6` | requirement | — |
| ✅ | `3.2.5.2/S1` | requirement | — |
| ✅ | `3.2.5.2/S2` | requirement | — |
| ❌ | `3.2.5.2.1/S2` | requirement | does not compile |
| ❌ | `3.2.5.2.1/S5` | requirement | does not compile |
| ✅ | `3.2.11/S1` | requirement | — |
| ✅ | `3.3/S2` | requirement | — |
| ✅ | `3.3.1.4/S2` | requirement | — |
| ✅ | `3.3.1.6/S2` | requirement | — |
| ✅ | `3.4.3/S1` | requirement | — |
| ✅ | `3.4.7/S1` | requirement | — |
| ✅ | `3.8.1/S1` | requirement | — |
| ✅ | `3.8.3/S1` | requirement | — |
| ✅ | `3.8.4/S1` | requirement | — |
| ✅ | `3.10.1/S1` | requirement | — |
| ❌ | `3.10.2/S1` | requirement | does not compile |
| ✅ | `3.10.3/S1` | requirement | — |
| ✅ | `3.11.3/S1` | requirement | — |
| ✅ | `3.11.4/I3` | requirement | — |
| ✅ | `3.11.4/I4` | requirement | — |
| ✅ | `3.11.4/I5` | requirement | — |
| ❌ | `3.11.5/S1` | requirement | does not compile |
| ✅ | `3.11.6/S1` | requirement | — |
| ❌ | `3.12.1/S1` | requirement | does not compile |
| ✅ | `3.12.6/S1` | requirement | — |
| ✅ | `3.12.7/S1` | requirement | — |
| ✅ | `3.13.1/S4` | requirement | — |
| ✅ | `3.14/S3` | requirement | — |
| ✅ | `3.14/S5` | requirement | — |
| ✅ | `3.14/S6` | requirement | — |
| ❌ | `3.15/S3` | requirement | does not compile |
| ⚠️ | `3.15/S4` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ⚠️ | `3.15.1.5/S1` | requirement | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
