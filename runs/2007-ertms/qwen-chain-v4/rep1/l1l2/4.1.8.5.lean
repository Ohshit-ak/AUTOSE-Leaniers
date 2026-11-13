import ContractForge
open ContractForge

-- 4.1.8.5: The onboard shall be capable to switch to another ETCS status when transmitted from trackside

-- L0 spec

structure Input where
  currentStatus : String
  newStatus     : String
  deriving DecidableEq, Repr

structure Output where
  switched      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentStatus ≠ "" ∧ i.newStatus ≠ ""
  post := fun i o => o.switched = true ↔
    (i.currentStatus = "Fitted" ∧ i.newStatus = "Unfitted") ∨
    (i.currentStatus = "Unfitted" ∧ i.newStatus = "Fitted")

example : Spec.pre { currentStatus := "Fitted", newStatus := "Unfitted" } ∧
          Spec.post { currentStatus := "Fitted", newStatus := "Unfitted" }
                    { switched := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { switched := decide (x.currentStatus = "Fitted" ∧ x.newStatus = "Unfitted" ∨ x.currentStatus = "Unfitted" ∧ x.newStatus = "Fitted") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
