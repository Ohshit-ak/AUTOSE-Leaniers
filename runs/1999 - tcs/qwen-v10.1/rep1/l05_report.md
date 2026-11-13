# L0.5 report — 1999 - tcs.xml (qwen)

Compiles: 55/70 · rejects a bad example: 35 · ✅ pass 43 · ⚠️ flagged 9 · ❌ fail 18

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `1.2.2/S4` | requirement | — |
| ✅ | `3.1/S1` | requirement | — |
| ✅ | `3.1.1/S2` | requirement | — |
| ❌ | `3.1.1.1/S1` | requirement | does not compile |
| ✅ | `3.1.1.2/S1` | requirement | — |
| ❌ | `3.2.1/S4` | requirement | does not compile |
| ❌ | `3.2.1/S5` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { missionPlanParams := "valid plan", avFlightParams := "valid", payloadParams := "valid", dataLinkParams := "valid", vcrParams := "valid", loiterPatterns := "valid", avType := "valid", avId := "valid", payloadType := "valid", groundControlInfo := "valid", commConfig := "valid", flightRoutePlan := "valid", payloadPlan := "valid" } ∧ ¬ Spec.post { missionPlanParams := "valid plan", avFlightParams := "valid", payloadParams := "valid", dataLinkParams := "valid", vcrParams := "valid", loiterPatterns := "valid", avType := "valid", avId := "valid", payloadType := "valid", groundControlInfo := "valid", commConfig := "valid", flightRoutePlan := "valid", payloadPlan := "valid" } { missionPlanParams := "valid plan", avFlightParams := "valid", payloadParams := "valid", dataLinkParams := "valid", vcrParams := "valid", loiterPatterns := "valid", avType := "valid", avId := "valid", payloadType := "valid", groundControlInfo := "valid", commConfig := "valid", flightRoutePlan := "valid", payloadPlan := "valid", savedMissionPlan := "valid plan" } := by unfold Spec; decide |
| ✅ | `3.2.1/S6` | requirement | — |
| ⚠️ | `3.2.1.1/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `3.2.1.1/I5` | requirement | — |
| ❌ | `3.2.1.1/S2` | requirement | does not compile |
| ✅ | `3.2.1.1.1/S2` | requirement | — |
| ❌ | `3.2.1.2/S1` | requirement | does not compile |
| ✅ | `3.2.2/S2` | requirement | — |
| ✅ | `3.2.2.1/S1` | requirement | — |
| ✅ | `3.2.2.1/S2` | requirement | — |
| ✅ | `3.2.2.1.1/S1` | requirement | — |
| ✅ | `3.2.2.1.1.1/S1` | requirement | — |
| ✅ | `3.2.2.1.2/S1` | requirement | — |
| ⚠️ | `3.2.2.1.3/S1` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `3.2.2.1.5/S1` | requirement | does not compile |
| ⚠️ | `3.2.2.1.5.1/S1` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ❌ | `3.2.2.1.5.1/S2` | requirement | does not compile |
| ⚠️ | `3.2.2.2/S1` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { tcsId := 1, payloadId := 1, command := "control" } { success := true, message := "Payload control command sent successfully." }` holds, but the requirement forbids this output for this input (The requirement states that the TCS shall provid |
| ✅ | `3.2.2.2/S3` | requirement | — |
| ✅ | `3.2.2.2.1/S1` | requirement | — |
| ❌ | `3.2.2.2.2.1/S1` | requirement | does not compile |
| ✅ | `3.2.2.3.1/S1` | requirement | — |
| ❌ | `3.2.2.3.2/S1` | requirement | does not compile |
| ✅ | `3.2.3/S1` | requirement | — |
| ✅ | `3.2.3.1/S1` | requirement | — |
| ✅ | `3.2.3.1/S3` | requirement | — |
| ⚠️ | `3.2.3.1/S4` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { imageryData := "ALPHANUMERIC", telemetryData := "ALSO_ALPHANUMERIC" } { imageryData := "ALPHANUMERIC", telemetryData := "ALSO_ALPHANUMERIC", annotations := [] }` holds, but the requirement forbids this output for this input (The requirement |
| ❌ | `3.2.3.2/S1` | requirement | does not compile |
| ✅ | `3.2.3.3/S1` | requirement | — |
| ❌ | `3.2.3.3/S2` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { imagery := "image1", date_time_group := "2023-10-01 12:00:00", target_location := "left", north_arrow := "N", av_position := "right", av_heading := "45", pos1 := "A1", pos2 := "B2" } ∧ ¬ Spec.post { imagery := "image1", date_time_group := "2023-10-01 12:00:00", target_location := "left", north_arrow := "N", av_position := "right", av_heading := "45", pos1 := "A1", pos2 := "B2" } { frozen_frame := "image1", nrt_imagery := "image1", range := 1000, bearing := 45 } := by unfold Spec; decide |
| ⚠️ | `3.2.5/S5` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { dataServer := "validServer", videoCables := [], radios := ["UHF", "VHF"] } { receivedData := true, liveVideo := true, interfacedRadios := true }` holds, but the requirement forbids this output for this input (The requirement does not allow  |
| ✅ | `3.2.5/S6` | requirement | — |
| ✅ | `3.2.5.2/S1` | requirement | — |
| ✅ | `3.2.5.2/S2` | requirement | — |
| ❌ | `3.2.5.2.1/S2` | requirement | does not compile |
| ✅ | `3.2.5.2.1/S5` | requirement | — |
| ✅ | `3.2.11/S1` | requirement | — |
| ⚠️ | `3.3/S2` | requirement | could not test whether `post` rejects anything (example not in `Spec.post {…} {…}` form) |
| ❌ | `3.3.1.4/S2` | requirement | does not compile |
| ❌ | `3.3.1.6/S2` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { locationData := ["term1", "term2", "term3"] } ∧ ¬ Spec.post { locationData := ["term1", "term2", "term3"] } { geopositionalData := ["term1", "term2", "term3", "term4"] } := by unfold Spec; decide |
| ✅ | `3.4.3/S1` | requirement | — |
| ✅ | `3.4.7/S1` | requirement | — |
| ✅ | `3.8.1/S1` | requirement | — |
| ✅ | `3.8.3/S1` | requirement | — |
| ❌ | `3.8.4/S1` | requirement | does not compile |
| ✅ | `3.10.1/S1` | requirement | — |
| ✅ | `3.10.2/S1` | requirement | — |
| ✅ | `3.10.3/S1` | requirement | — |
| ✅ | `3.11.3/S1` | requirement | — |
| ✅ | `3.11.4/I3` | requirement | — |
| ✅ | `3.11.4/I4` | requirement | — |
| ✅ | `3.11.4/I5` | requirement | — |
| ⚠️ | `3.11.5/S1` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `3.11.6/S1` | requirement | — |
| ❌ | `3.12.1/S1` | requirement | does not compile |
| ✅ | `3.12.6/S1` | requirement | — |
| ✅ | `3.12.7/S1` | requirement | — |
| ✅ | `3.13.1/S4` | requirement | — |
| ✅ | `3.14/S3` | requirement | — |
| ✅ | `3.14/S5` | requirement | — |
| ✅ | `3.14/S6` | requirement | — |
| ❌ | `3.15/S3` | requirement | does not compile |
| ❌ | `3.15/S4` | requirement | does not compile |
| ⚠️ | `3.15.1.5/S1` | requirement | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
