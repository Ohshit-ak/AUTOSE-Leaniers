import ContractForge
open ContractForge

-- 5.5.11/S1: Stored number access shall be provided to initiate the following calls: (M)

-- L0 spec

structure Input where
  storedNumbers : List String
  callType      : String
  deriving DecidableEq, Repr

structure Output where
  callInitiated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.storedNumbers ≠ [] ∧ i.callType = "M"
  post := fun i o => o.callInitiated = true ↔
    ∃ s ∈ i.storedNumbers, s = "M" ∧ i.callType = "M"

example : Spec.pre { storedNumbers := ["M", "N"], callType := "M" } ∧ Spec.post { storedNumbers := ["M", "N"], callType := "M" } { callInitiated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { callInitiated := decide (∃ s ∈ x.storedNumbers, s = "M" ∧ x.callType = "M") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
