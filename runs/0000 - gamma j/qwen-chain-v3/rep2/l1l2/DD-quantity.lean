import ContractForge
open ContractForge

-- DD-quantity: the number of units of each selected item that the customer is ordering; default = 1; maximum = quantity presently in inventory

-- L0 spec

structure Input where
  value : Nat
  max_ref : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ 1 ≤ i.value ∧ i.value ≤ i.max_ref

example : Spec.pre { value := 5, max_ref := 10 } ∧
          Spec.post { value := 5, max_ref := 10 } { valid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (data constraint (one validity rule)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide (1 ≤ x.value ∧ x.value ≤ x.max_ref) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
