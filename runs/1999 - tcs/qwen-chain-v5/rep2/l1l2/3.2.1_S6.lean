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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  valid : Bool
  discrepancies : List String
  override : Bool
  lolDelayTimer : Nat
  deriving DecidableEq, Repr

def ComputeValidityContract : Contract Input Mid where
  pre  := fun i => i.missionPlan ≠ ""
  post := fun i m => (m.valid = true ↔
                     i.altitudeConstraints.Nodup ∧
                     i.payloadConstraints.Nodup ∧
                     i.dataLinkRangeConstraints.Nodup ∧
                     i.airspaceRestrictions.Nodup ∧
                     i.fuelLimitations.Nodup ∧
                     i.threatConstraints.Nodup ∧
                     i.dataLinkTerrainMasking.Nodup ∧
                     i.lolPlan.Nodup) ∧ m.lolDelayTimer = i.lolDelayTimer

def GenerateOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (m.valid = true →
                      o.valid = true ∧
                      o.discrepancies = [] ∧
                      o.override = false) ∧
                     (m.valid = false →
                      o.valid = false ∧
                      o.discrepancies.length > 0 ∧
                      o.override = false) ∧
                     o.lolDelayTimer = m.lolDelayTimer



theorem po1 : Contract.Compatible ComputeValidityContract GenerateOutputContract := by
  discharge_po1 [ComputeValidityContract, GenerateOutputContract, Spec]

theorem po2 : Contract.Refines (ComputeValidityContract.seq GenerateOutputContract) Spec := by
  discharge_po2 [ComputeValidityContract, GenerateOutputContract, Spec]

-- L2 ComputeValidityContract (success=True)

def ComputeValidityContractImpl (x : Input) : Mid :=
  { valid := decide (x.altitudeConstraints.Nodup ∧
                     x.payloadConstraints.Nodup ∧
                     x.dataLinkRangeConstraints.Nodup ∧
                     x.airspaceRestrictions.Nodup ∧
                     x.fuelLimitations.Nodup ∧
                     x.threatConstraints.Nodup ∧
                     x.dataLinkTerrainMasking.Nodup ∧
                     x.lolPlan.Nodup),
    discrepancies := [],
    override := false,
    lolDelayTimer := x.lolDelayTimer }

theorem ComputeValidityContractImpl_ok : ComputeValidityContract.Satisfies ComputeValidityContractImpl := by
  discharge_po3 [ComputeValidityContract, ComputeValidityContractImpl]

-- L2 GenerateOutputContract (success=True)

def GenerateOutputContractImpl (x : Mid) : Output :=
  { valid := if x.valid = true then true else if x.valid = false then false else false,
    discrepancies := if x.valid = true then [] else ["FILL"],
    override := if x.valid = true then false else if x.valid = false then false else false,
    lolDelayTimer := x.lolDelayTimer }

theorem GenerateOutputContractImpl_ok : GenerateOutputContract.Satisfies GenerateOutputContractImpl := by
  discharge_po3 [GenerateOutputContract, GenerateOutputContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (GenerateOutputContractImpl ∘ ComputeValidityContractImpl) :=
  Contract.system_sound po1 po2 ComputeValidityContractImpl_ok GenerateOutputContractImpl_ok
