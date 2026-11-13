# L0.5 report — 0000 - cctns.xml (qwen)

Compiles: 14/22 · rejects a bad example: 8 · ✅ pass 10 · ⚠️ flagged 3 · ❌ fail 9

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `3/registration/S1` | requirement | — |
| ⚠️ | `4/R2` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `4/audit-module/R2` | requirement | does not compile |
| ✅ | `4/audit-module/R5` | requirement | — |
| ✅ | `4/audit-module/R6` | requirement | — |
| ✅ | `4/access-module/R6` | requirement | — |
| ❌ | `4/access-module/R10` | requirement | does not compile |
| ⚠️ | `4/ease-of-use/R2` | requirement | could not test whether `post` rejects anything (example not in `Spec.post {…} {…}` form) |
| ✅ | `4/ease-of-use/R7` | requirement | — |
| ✅ | `4/ease-of-use/R8` | requirement | — |
| ⚠️ | `4/ease-of-use/R9` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { menuContents := ["Home", "Settings", "Help"], screenLayout := ["A", "B", "C"], functionKeys := ["F1", "F2", "F3"], onScreenColors := ["Red", "Green", "Blue"], fonts := ["Arial", "Times New Roman", "Courier New"], fontSizes := [12, 14, 16] } |
| ✅ | `4/usability/R8` | requirement | — |
| ❌ | `4/usability/R46` | requirement | does not compile |
| ✅ | `4/system-availability/R4` | requirement | — |
| ❌ | `4/system-availability/R5` | requirement | `i.failedAttempts ≥ 0` is always true for a `Nat` and says nothing; state a real condition on it or drop it |
| ❌ | `4/performance-and-scalability/R2` | requirement | does not compile |
| ❌ | `4/performance-and-scalability/R3` | requirement | does not compile |
| ❌ | `4/performance-and-scalability/R4` | requirement | does not compile |
| ✅ | `5/S6` | requirement | — |
| ✅ | `5/S7` | requirement | — |
| ❌ | `5/system-functionality/R21` | requirement | does not compile |
| ❌ | `5/system-functionality/R24` | requirement | does not compile |
