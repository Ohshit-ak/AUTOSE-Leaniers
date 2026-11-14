import ContractForge
open ContractForge

-- 4.1.5.1a: Transferring to Full Supervision shall occur automatically when a movement authority and all other necessary information is received through track-to-train transmission.

-- L0 spec

structure Input where
  movementAuthorityReceived : Bool
  allNecessaryInfoReceived  : Bool
  deriving DecidableEq, Repr

structure Output where
  inFullSupervision : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.movementAuthorityReceived ∧ i.allNecessaryInfoReceived
  post := fun i o => (o.inFullSupervision = true ↔ i.movementAuthorityReceived ∧ i.allNecessaryInfoReceived)

example : Spec.pre { movementAuthorityReceived := true, allNecessaryInfoReceived := true } ∧
          Spec.post { movementAuthorityReceived := true, allNecessaryInfoReceived := true }
                    { inFullSupervision := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { inFullSupervision := decide (x.movementAuthorityReceived ∧ x.allNecessaryInfoReceived) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
