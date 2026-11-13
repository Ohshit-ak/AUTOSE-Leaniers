# L0.5 report — 2007-eirene_fun_7-2.xml (qwen)

Compiles: 111/126 · rejects a bad example: 80 · ✅ pass 82 · ⚠️ flagged 21 · ❌ fail 23

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `2.3.4` | requirement | — |
| ⚠️ | `2.3.12` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { faxActive := true, calls := [ { type := "fax", priority := 1, duration := 60 } ] } { faxActive := true, calls := [ { type := "fax", priority := 1, duration := 60 } ] }` holds, but the requirement forbids this output for this input (The outp |
| ✅ | `2.4.5` | requirement | — |
| ✅ | `3.2.2` | requirement | — |
| ✅ | `3.4.4` | requirement | — |
| ✅ | `3.5.1` | requirement | — |
| ✅ | `3.5.8` | requirement | — |
| ✅ | `4.1.2` | requirement | — |
| ✅ | `5.2.2ii` | requirement | — |
| ✅ | `5.2.2.7` | requirement | — |
| ❌ | `5.2.2.15` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output; `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `5.2.2.17` | requirement | — |
| ⚠️ | `5.2.2.19` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { emergencyActivation := true, emergencyTermination := false, emergencyFailure := false, trainBorneRecorder := some "recorder123" } { emergencyActivation := true, emergencyTermination := false, emergencyFailure := false, trainBorneRecorder := |
| ⚠️ | `5.2.2.20` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `5.2.2.24` | requirement | — |
| ✅ | `5.2.2.30` | requirement | — |
| ✅ | `5.2.2.31` | requirement | — |
| ✅ | `5.2.2.37` | requirement | — |
| ✅ | `5.2.2.42` | requirement | — |
| ❌ | `5.2.2.46` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `5.2.2.47` | requirement | — |
| ⚠️ | `5.2.2.55` | requirement | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
| ✅ | `5.2.2.57` | requirement | — |
| ✅ | `5.2.2.58` | requirement | — |
| ❌ | `5.2.2.59` | requirement | does not compile |
| ✅ | `5.2.2.60` | requirement | — |
| ✅ | `5.2.2.61` | requirement | — |
| ✅ | `5.2.2.62` | requirement | — |
| ❌ | `5.2.2.74` | requirement | does not compile |
| ⚠️ | `5.2.3.4` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ❌ | `5.2.3.8` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `5.2.3.9` | requirement | — |
| ✅ | `5.2.3.12` | requirement | — |
| ✅ | `5.2.3.13` | requirement | — |
| ✅ | `5.2.3.17` | requirement | — |
| ❌ | `5.2.3.25` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { networkIdentity := "NewNetwork", automaticallySelected := true } ∧ ¬ Spec.post { networkIdentity := "NewNetwork", automaticallySelected := true } { networkIdentity := "NewNetwork", visuallyConfirmed := true, automaticallySelected := true } := by unfold Spec; decide |
| ✅ | `5.2.3.25i` | requirement | — |
| ✅ | `5.2.3.25iii` | requirement | — |
| ✅ | `5.2.3.25ix` | requirement | — |
| ⚠️ | `5.2.3.25x` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { trainNumber := "12345", networkIdentity := "oldNetwork", indication := true } { trainNumber := "12345", networkIdentity := "newNetwork", indication := false }` holds, but the requirement forbids this output for this input (The requirement s |
| ✅ | `5.2.3.26` | requirement | — |
| ✅ | `5.2.3.27` | requirement | — |
| ✅ | `5.2.3.28i` | requirement | — |
| ✅ | `5.2.3.29` | requirement | — |
| ⚠️ | `5.2.3.30` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `5.2.3.31` | requirement | does not compile |
| ✅ | `5.2.3.32` | requirement | — |
| ❌ | `5.2.3.34` | requirement | does not compile |
| ⚠️ | `5.2.3.35` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ❌ | `5.2.3.36` | requirement | does not compile |
| ⚠️ | `5.2.3.37` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `5.2.3.38` | requirement | — |
| ❌ | `5.2.3.40` | requirement | does not compile |
| ✅ | `5.2.3.41` | requirement | — |
| ❌ | `5.2.4.4` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { calls := ["call1", "call2", "call3"] } ∧ ¬ Spec.post { calls := ["call1", "call2", "call3"] } { selectedCall := "call2", priority := 1 } := by unfold Spec; decide |
| ✅ | `5.3.3` | requirement | — |
| ✅ | `5.3.5` | requirement | — |
| ✅ | `5.4.2` | requirement | — |
| ❌ | `5.4.2i` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { cabLayout := "ABC123", cabRequirements := "XYZ789" } ∧ ¬ Spec.post { cabLayout := "ABC123", cabRequirements := "XYZ789" } { installationPossible := true } := by unfold Spec; decide |
| ⚠️ | `5.7.2` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `5.7.4` | requirement | — |
| ⚠️ | `5.8.1` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { emergencyCallActivation := false, incomingEmergencyCall := true, outgoingEmergencyCall := false, radioFaults := false, driverSafetyDeviceAlarm := false, confirmationDetails := "Confirmed" } { emergencyCallActivation := false, incomingEmerge |
| ❌ | `7.2.1.2` | requirement | does not compile |
| ⚠️ | `7.2.2.2` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { radioId := 1, controllerType := "primary" } { callEstablished := true }` holds, but the requirement forbids this output for this input (The requirement states that the user should be able to establish a call with primary, secondary, or powe |
| ❌ | `7.2.2.3` | requirement | does not compile |
| ✅ | `7.2.2.9` | requirement | — |
| ✅ | `7.2.2.12` | requirement | — |
| ✅ | `7.2.2.14` | requirement | — |
| ✅ | `7.2.2.22` | requirement | — |
| ❌ | `7.2.2.23` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { callType := "operational radio" } ∧ ¬ Spec.post { callType := "operational radio" } { callTerminated := true, indicationProvided := false } := by unfold Spec; decide |
| ❌ | `7.2.2.24` | requirement | does not compile |
| ✅ | `7.2.3.1` | requirement | — |
| ⚠️ | `7.2.3.4` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `7.2.3.9` | requirement | — |
| ✅ | `7.2.3.9i` | requirement | — |
| ⚠️ | `7.2.3.10` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { functionalNumber := { number := "12345" }, registered := false } { registered := true, functionalNumber := { number := "12345" } }` holds, but the requirement forbids this output for this input (The requirement does not allow the same funct |
| ✅ | `7.2.3.11` | requirement | — |
| ⚠️ | `7.2.3.12` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `7.2.3.13` | requirement | — |
| ❌ | `7.3.7` | requirement | does not compile |
| ⚠️ | `7.3.9` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `7.4.4.1` | requirement | — |
| ✅ | `9.2.1.1` | requirement | — |
| ✅ | `9.2.1.2` | requirement | — |
| ✅ | `9.2.2.2` | requirement | — |
| ✅ | `9.2.3.2` | requirement | — |
| ✅ | `9.5.1` | requirement | — |
| ✅ | `10.2.1` | requirement | — |
| ✅ | `10.4.1` | requirement | — |
| ✅ | `10.4.2` | requirement | — |
| ✅ | `10.4.4` | requirement | — |
| ✅ | `11.2.1.2` | requirement | — |
| ✅ | `11.2.1.9` | requirement | — |
| ✅ | `11.2.1.10` | requirement | — |
| ✅ | `11.2.2.1` | requirement | — |
| ⚠️ | `11.2.2.3` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `11.3.2.3` | requirement | — |
| ✅ | `11.3.3.3` | requirement | — |
| ✅ | `11.3.3.5` | requirement | — |
| ✅ | `11.4.2` | requirement | — |
| ✅ | `11.4.4` | requirement | — |
| ✅ | `12.2.1` | requirement | — |
| ✅ | `12.2.3` | requirement | — |
| ❌ | `12.3.1` | requirement | does not compile |
| ✅ | `12.3.2` | requirement | — |
| ✅ | `13.1.6` | requirement | — |
| ✅ | `13.1.7` | requirement | — |
| ❌ | `13.2.2.3` | requirement | does not compile |
| ⚠️ | `13.2.2.3ii` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ❌ | `13.2.2.4` | requirement | does not compile |
| ✅ | `13.2.3.3` | requirement | — |
| ✅ | `13.3.1` | requirement | — |
| ❌ | `13.3.2` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { location := { trainNumber := none, engineNumber := none, coachNumber := none } } ∧ ¬ Spec.post { location := { trainNumber := none, engineNumber := none, coachNumber := none } } { location := { trainNumber := none, engineNumber := none, coachNumber := none }, functionalIdentity := "" } := by unfold Spec; decide; `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `13.4.2` | requirement | — |
| ✅ | `13.4.3` | requirement | — |
| ❌ | `13.4.4` | requirement | does not compile |
| ⚠️ | `13.4.5` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ⚠️ | `13.4.6` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `13.4.7` | requirement | — |
| ✅ | `13.4.8` | requirement | — |
| ✅ | `14.2.4` | requirement | — |
| ⚠️ | `14.2.5` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `14.2.8` | requirement | — |
| ❌ | `14.2.11` | requirement | does not compile |
| ✅ | `14.2.12` | requirement | — |
| ✅ | `14.2.13` | requirement | — |
