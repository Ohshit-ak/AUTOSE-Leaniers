# L0.5 report — 2005 - phin.xml (qwen)

Compiles: 37/43 · rejects a bad example: 28 · ✅ pass 31 · ⚠️ flagged 4 · ❌ fail 8

| | Entry | Kind | Reasons |
|---|---|---|---|
| ❌ | `1/S5` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { objects := [] } ∧ ¬ Spec.post { objects := [] } { objects := [{ id := 0, name := "New Object", data := "Some Data" }] } := by unfold Spec; decide |
| ✅ | `2/I5` | requirement | — |
| ✅ | `2/I8` | requirement | — |
| ✅ | `2.1.1/S1` | requirement | — |
| ✅ | `2.2.1.3/S1` | requirement | — |
| ✅ | `2.2.2.1/S1` | requirement | — |
| ✅ | `2.2.2.4/S1` | requirement | — |
| ⚠️ | `2.2.3.1/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `2.2.3.2/S1` | requirement | does not compile |
| ⚠️ | `2.2.4.2a/S1` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { caseId := "12345", jurisdiction := "Test Jurisdiction", suspectedAgent := "AgentX", diagnosis := "DiagnosisY", healthStatus := "No Symptoms", caseStatus := "Confirmed", investigationDates := ["2023-01-01", "2023-01-02"], clinicalHistory :=  |
| ✅ | `2.2.4.2b/S1` | requirement | — |
| ✅ | `2.2.4.3a/S1` | requirement | — |
| ❌ | `2.2.6.1/S1` | requirement | does not compile |
| ✅ | `2.2.6.2/S1` | requirement | — |
| ✅ | `2.2.6.3/S1` | requirement | — |
| ✅ | `2.2.6.3.a/S1` | requirement | — |
| ⚠️ | `2.2.6.3.b/S1` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `2.2.6.3.c/S1` | requirement | — |
| ✅ | `2.2.6.6/S1` | requirement | — |
| ✅ | `2.2.6.7/S1` | requirement | — |
| ✅ | `2.2.6.9/S1` | requirement | — |
| ✅ | `2.2.6.10/S1` | requirement | — |
| ✅ | `2.2.9.1/S1` | requirement | — |
| ✅ | `2.2.9.2/S1` | requirement | — |
| ✅ | `2.3.1.1/S1` | requirement | — |
| ✅ | `2.3.1.5/S1` | requirement | — |
| ❌ | `2.3.1.6/S1` | requirement | does not compile |
| ⚠️ | `2.3.2.5.a/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `2.3.3.3/S1` | requirement | — |
| ❌ | `2.4.1/S1` | requirement | does not compile |
| ❌ | `2.4.2/S1` | requirement | does not compile |
| ✅ | `2.4.3/S1` | requirement | — |
| ✅ | `2.4.4/S1` | requirement | — |
| ✅ | `2.4.11/S1` | requirement | — |
| ✅ | `2.5/S1` | requirement | — |
| ✅ | `2.5.1/S1` | requirement | — |
| ✅ | `2.5.3/S1` | requirement | — |
| ❌ | `2.5.4/S1` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ❌ | `2.5.5/S1` | requirement | does not compile |
| ✅ | `2.5.7/S1` | requirement | — |
| ✅ | `2.5.9/S1` | requirement | — |
| ✅ | `2.5.10/S1` | requirement | — |
| ✅ | `2.5.12/S1` | requirement | — |
