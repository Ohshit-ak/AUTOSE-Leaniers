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
  lolDelayTimer : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  discrepancies : List String
  override : Bool
  lolDelayTimer : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.missionPlan ≠ ""
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
    (o.valid = false →
      o.discrepancies.length > 0 ∧
      o.override = false) ∧
    o.lolDelayTimer = i.lolDelayTimer

example : Spec.pre { missionPlan := "mission1", altitudeConstraints := [1000, 2000, 3000],
                     payloadConstraints := [50, 100, 150], dataLinkRangeConstraints := [5, 10, 15],
                     airspaceRestrictions := ["zone1", "zone2"], fuelLimitations := [1000, 2000],
                     threatConstraints := ["threat1", "threat2"], dataLinkTerrainMasking := ["mask1", "mask2"],
                     lolPlan := [10, 20, 30], lolDelayTimer := 60 } ∧
          Spec.post { missionPlan := "mission1", altitudeConstraints := [1000, 2000, 3000],
                      payloadConstraints := [50, 100, 150], dataLinkRangeConstraints := [5, 10, 15],
                      airspaceRestrictions := ["zone1", "zone2"], fuelLimitations := [1000, 2000],
                      threatConstraints := ["threat1", "threat2"], dataLinkTerrainMasking := ["mask1", "mask2"],
                      lolPlan := [10, 20, 30], lolDelayTimer := 60 }
                    { valid := true, discrepancies := [], override := false, lolDelayTimer := 60 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide (x.altitudeConstraints.Nodup ∧
      x.payloadConstraints.Nodup ∧
      x.dataLinkRangeConstraints.Nodup ∧
      x.airspaceRestrictions.Nodup ∧
      x.fuelLimitations.Nodup ∧
      x.threatConstraints.Nodup ∧
      x.dataLinkTerrainMasking.Nodup ∧
      x.lolPlan.Nodup),
    discrepancies := if x.altitudeConstraints.Nodup ∧
                     x.payloadConstraints.Nodup ∧
                     x.dataLinkRangeConstraints.Nodup ∧
                     x.airspaceRestrictions.Nodup ∧
                     x.fuelLimitations.Nodup ∧
                     x.threatConstraints.Nodup ∧
                     x.dataLinkTerrainMasking.Nodup ∧
                     x.lolPlan.Nodup then [] else ["Constraints not Nodup"],
    override := false,
    lolDelayTimer := x.lolDelayTimer }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
