import ContractForge
open ContractForge

-- DD-e-mail-id: E-mail address of the customer who is using the Web order system; 50 characters alphanumeric

-- L0 spec

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    i.raw.length = 50 ∧
    i.raw.toList.all Char.isAlphanum = true

example : Spec.pre { raw := "aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890" } ∧ Spec.post { raw := "aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890" } { valid := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (data constraint (one validity rule)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide (x.raw.length = 50 ∧ x.raw.toList.all Char.isAlphanum) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
