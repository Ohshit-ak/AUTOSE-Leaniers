# L0.5 report — 2007-ertms.xml (qwen)

Compiles: 46/51 · rejects a bad example: 31 · ✅ pass 36 · ⚠️ flagged 8 · ❌ fail 7

| | Entry | Kind | Reasons |
|---|---|---|---|
| ⚠️ | `3.10.1.6` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `3.10.1.2` | requirement | — |
| ⚠️ | `4.1.2.10` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `4.1.2.11` | requirement | — |
| ✅ | `4.1.2.14b` | requirement | — |
| ✅ | `4.1.3.2a` | requirement | — |
| ✅ | `4.1.3.2d` | requirement | — |
| ✅ | `4.1.3.4b` | requirement | — |
| ✅ | `4.1.4.1` | requirement | — |
| ⚠️ | `4.1.4.2a` | requirement | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
| ✅ | `4.1.5.1a` | requirement | — |
| ✅ | `4.1.5.1b` | requirement | — |
| ✅ | `4.1.5.5` | requirement | — |
| ✅ | `4.1.8.1` | requirement | — |
| ✅ | `4.1.8.5` | requirement | — |
| ✅ | `4.1.1.3a#2` | requirement | — |
| ✅ | `4.1.1.3b` | requirement | — |
| ❌ | `4.1.1.4a` | requirement | does not compile |
| ⚠️ | `4.1.1.5` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `4.2.2.3` | requirement | does not compile |
| ❌ | `4.2.3.1` | requirement | does not compile |
| ✅ | `4.2.3.6b` | requirement | — |
| ⚠️ | `4.2.3.6c` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …); could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `4.3.1.2a` | requirement | does not compile |
| ❌ | `4.3.2.1a` | requirement | does not compile |
| ❌ | `4.3.2.1b` | requirement | does not compile |
| ✅ | `4.3.2.7` | requirement | — |
| ✅ | `4.3.3.2d` | requirement | — |
| ✅ | `4.3.3.3` | requirement | — |
| ✅ | `4.3.4.2` | requirement | — |
| ✅ | `4.3.6.6` | requirement | — |
| ✅ | `4.3.7.2` | requirement | — |
| ✅ | `4.3.10.2` | requirement | — |
| ⚠️ | `4.3.10.5` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `4.3.10.7` | requirement | — |
| ✅ | `4.4.1.2` | requirement | — |
| ✅ | `4.4.7.1` | requirement | — |
| ⚠️ | `4.5.2.2a` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `4.5.2.5b` | requirement | — |
| ❌ | `4.6.4.7` | requirement | `post` fixes `o.trains` elsewhere, so `∀ t ∈ o.trains, t.status = "emergency brake" ↔ ∃ t' ∈ i.trains, t'.id = t.id ∧ t'.status = "emergency stop"` only says `∀ t ∈ (i.trains), t.status = "emergency brake" ↔ ∃ t' ∈ i.trains, t'.id = t.id ∧ t'.status = "emergency stop"` about the input, and `pre` does not ensure that: no implementation can make it true. If the requirement assumes it, add it to `pre`; if the output should differ from the input (e.g. keep only the elements that satisfy it), change the condition that fixes `o.trains`.; could not test whether `post` rejects anything (no field types to vary) |
| ⚠️ | `4.7.1.1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `4.8.8.1` | requirement | — |
| ✅ | `4.8.8.5` | requirement | — |
| ✅ | `4.8.9.1` | requirement | — |
| ✅ | `4.8.10.1` | requirement | — |
| ✅ | `4.9.5.1` | requirement | — |
| ✅ | `4.9.5.4` | requirement | — |
| ✅ | `4.9.9.1` | requirement | — |
| ✅ | `4.9.9.2` | requirement | — |
| ✅ | `4.9.10.5` | requirement | — |
| ✅ | `5.2.1.2c` | requirement | — |
