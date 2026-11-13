import ContractForge
open ContractForge

-- 3.2.1/S6: The TCS shall automatically check the validity of the intended mission plan prior to being uploaded including altitude constraints, payload constraints, data link range constraints, airspace restrictions, fuel limitations, threat constraints, data link terrain masking effects, and Loss of Link (LOL) Plan. [SSS073] The TCS shall notify the operator of all discrepancies found during the mission plan check as well as indicate successful completion of the mission plan check. [SSS074] The TCS shall provide the capability to override validation faults after the fault is acknowledged by the operator. [SSS540] The TCS shall allow the operator to set the LOL delay timer(s) during mission planning. [SSS075] The LOL delay is the time from when the AV detects an unplanned LOL to the time it initiates LOL procedures.

-- L0 spec

structure Input where
  missionPlan : String
  altitudeConstraints : List Nat
  payloadConstraints : List Nat
  dataLinkRangeConstraints : List Nat
  airspaceRestrictions : List String
  fuelLimitations : List Nat
  threatConstraints : List String
  dataLinkTerrainMasking : List String
  lolPlan : List Nat
  aviationRestrictions : List String
  notifyingOperator : Bool
  deriving DecidableEq, Repr

structure Output where
  discrepancies : List String
  valid : Bool
  lolDelayTimer : Nat
  overriding : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.missionPlan ≠ "" ∧ i.notifyingOperator = true
  post := fun i o =>
    (o.valid = true ↔
      i.altitudeConstraints.Nodup ∧
      i.payloadConstraints.Nodup ∧
      i.dataLinkRangeConstraints.Nodup ∧
      i.airspaceRestrictions.Nodup ∧
      i.fuelLimitations.Nodup ∧
      i.threatConstraints.Nodup ∧
      i.dataLinkTerrainMasking.Nodup ∧
      i.lolPlan.Nodup) ∧
    (o.discrepancies.length = 0 ↔ o.valid = true) ∧
    (o.overriding = true ↔
      o.discrepancies.length > 0 ∧
      ∃ d ∈ o.discrepancies, d ≠ "altitude constraints" ∧
      d ≠ "payload constraints" ∧
      d ≠ "data link range constraints" ∧
      d ≠ "airspace restrictions" ∧
      d ≠ "fuel limitations" ∧
      d ≠ "threat constraints" ∧
      d ≠ "data link terrain masking" ∧
      d ≠ "LOL plan") ∧
    (o.valid = false ↔
      o.discrepancies.length > 0 ∧
      ¬i.notifyingOperator) ∧
    o.lolDelayTimer = o.lolDelayTimer

example : Spec.pre { missionPlan := "test plan", altitudeConstraints := [1000, 2000], payloadConstraints := [1, 2], dataLinkRangeConstraints := [5000], airspaceRestrictions := ["restricted area"], fuelLimitations := [100], threatConstraints := ["threat"], dataLinkTerrainMasking := ["masked area"], lolPlan := [10], aviationRestrictions := ["no entry"], notifyingOperator := true } ∧ Spec.post { missionPlan := "test plan", altitudeConstraints := [1000, 2000], payloadConstraints := [1, 2], dataLinkRangeConstraints := [5000], airspaceRestrictions := ["restricted area"], fuelLimitations := [100], threatConstraints := ["threat"], dataLinkTerrainMasking := ["masked area"], lolPlan := [10], aviationRestrictions := ["no entry"], notifyingOperator := true } { discrepancies := [], valid := true, lolDelayTimer := 0, overriding := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { discrepancies := List.nil,
    valid := x.altitudeConstraints.Nodup ∧
            x.payloadConstraints.Nodup ∧
            x.dataLinkRangeConstraints.Nodup ∧
            x.airspaceRestrictions.Nodup ∧
            x.fuelLimitations.Nodup ∧
            x.threatConstraints.Nodup ∧
            x.dataLinkTerrainMasking.Nodup ∧
            x.lolPlan.Nodup,
    lolDelayTimer := 0,
    overriding := false }
