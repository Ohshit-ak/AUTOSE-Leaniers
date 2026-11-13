import ContractForge
open ContractForge

-- 4.4.1.2: Information received shall not influence the traction unit(s) with in-operative cabs.

-- L0 spec

structure TractionUnit where
  cabStatus : Bool -- true if the cab is in-operative, false otherwise
  powerLevel : Nat -- power level of the traction unit
  deriving DecidableEq, Repr

structure Input where
  cabStatuses : List TractionUnit
  receivedInfo : String
  deriving DecidableEq, Repr

structure Output where
  cabStatuses : List TractionUnit
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.receivedInfo ≠ ""
  post := fun i o => o.cabStatuses = i.cabStatuses ∧
                     (o.cabStatuses.map (fun u => u.cabStatus) = i.cabStatuses.map (fun u => u.cabStatus))

example : Spec.pre { cabStatuses := [{ cabStatus := true, powerLevel := 50 },
                                      { cabStatus := false, powerLevel := 100 }],
                     receivedInfo := "new data" } ∧
          Spec.post { cabStatuses := [{ cabStatus := true, powerLevel := 50 },
                                       { cabStatus := false, powerLevel := 100 }],
                      receivedInfo := "new data" }
                    { cabStatuses := [{ cabStatus := true, powerLevel := 50 },
                                      { cabStatus := false, powerLevel := 100 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { cabStatuses := x.cabStatuses }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
