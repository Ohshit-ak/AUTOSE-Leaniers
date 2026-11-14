# L0.5 report — 0000 - cctns.xml (qwen)

Compiles: 15/22 · rejects a bad example: 6 · ✅ pass 13 · ⚠️ flagged 1 · ❌ fail 8

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `3/registration/S1` | requirement | — |
| ❌ | `4/R2` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { user := "testUser", action := "testAction", message := "testMessage", alert := { user := "testUser", action := "testAction", message := "testMessage" } } ∧ ¬ Spec.post { user := "testUser", action := "testAction", message := "testMessage", alert := { user := "testUser", action := "testAction", message := "testMessage" } } { user := "testUser", action := "testAction", message := "testMessage", alert := { user := "testUser", action := "testAction", message := "testMessage" } } := by unfold Spec; decide |
| ❌ | `4/audit-module/R2` | requirement | does not compile |
| ✅ | `4/audit-module/R5` | requirement | — |
| ✅ | `4/audit-module/R6` | requirement | — |
| ✅ | `4/access-module/R6` | requirement | — |
| ❌ | `4/access-module/R10` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { cases := [{ id := 1, title := "Test Case", status := "active" }], activity := "Reviewing case" } ∧ ¬ Spec.post { cases := [{ id := 1, title := "Test Case", status := "active" }], activity := "Reviewing case" } { cases := [{ id := 1, title := "Test Case", status := "active" }], activity := "Reviewing case", audit := "" } := by unfold Spec; decide |
| ⚠️ | `4/ease-of-use/R2` | requirement | could not test whether `post` rejects anything (example not in `Spec.post {…} {…}` form) |
| ✅ | `4/ease-of-use/R7` | requirement | — |
| ✅ | `4/ease-of-use/R8` | requirement | — |
| ✅ | `4/ease-of-use/R9` | requirement | — |
| ✅ | `4/usability/R8` | requirement | — |
| ❌ | `4/usability/R46` | requirement | does not compile |
| ✅ | `4/system-availability/R4` | requirement | — |
| ✅ | `4/system-availability/R5` | requirement | — |
| ❌ | `4/performance-and-scalability/R2` | requirement | does not compile |
| ❌ | `4/performance-and-scalability/R3` | requirement | does not compile |
| ✅ | `4/performance-and-scalability/R4` | requirement | — |
| ✅ | `5/S6` | requirement | — |
| ✅ | `5/S7` | requirement | — |
| ❌ | `5/system-functionality/R21` | requirement | does not compile |
| ❌ | `5/system-functionality/R24` | requirement | does not compile |
