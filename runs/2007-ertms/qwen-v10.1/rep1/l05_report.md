# L0.5 report — 2007-ertms.xml (qwen)

Compiles: 45/51 · rejects a bad example: 30 · ✅ pass 36 · ⚠️ flagged 9 · ❌ fail 6

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `3.10.1.6` | requirement | — |
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
| ✅ | `4.1.1.4a` | requirement | — |
| ❌ | `4.1.1.5` | requirement | does not compile |
| ❌ | `4.2.2.3` | requirement | does not compile |
| ❌ | `4.2.3.1` | requirement | does not compile |
| ✅ | `4.2.3.6b` | requirement | — |
| ⚠️ | `4.2.3.6c` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …); could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `4.3.1.2a` | requirement | — |
| ❌ | `4.3.2.1a` | requirement | does not compile |
| ❌ | `4.3.2.1b` | requirement | does not compile |
| ❌ | `4.3.2.7` | requirement | does not compile |
| ⚠️ | `4.3.3.2d` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { distanceToDangerPoint := 100, maxDecelerationRate := 5, initialSpeed := 50 } { releaseSpeed := 50, shallStopBeforeDanger := true }` holds, but the requirement forbids this output for this input (The train will not stop before reaching the d |
| ✅ | `4.3.3.3` | requirement | — |
| ✅ | `4.3.4.2` | requirement | — |
| ✅ | `4.3.6.6` | requirement | — |
| ✅ | `4.3.7.2` | requirement | — |
| ✅ | `4.3.10.2` | requirement | — |
| ⚠️ | `4.3.10.5` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ⚠️ | `4.3.10.7` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { level := 1, operational_status := "normal", shunting_confirmation := false, shunting_data := false, national_train_control_data := false, actual_speed := 60, full_service_brake := false, emergency_brake := false, train_trip_function := fals |
| ✅ | `4.4.1.2` | requirement | — |
| ✅ | `4.4.7.1` | requirement | — |
| ⚠️ | `4.5.2.2a` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `4.5.2.5b` | requirement | — |
| ⚠️ | `4.6.4.7` | requirement | could not test whether `post` rejects anything (no field types to vary) |
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
