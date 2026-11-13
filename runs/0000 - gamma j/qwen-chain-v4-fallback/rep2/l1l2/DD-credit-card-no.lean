import ContractForge
open ContractForge

-- DD-credit-card-no: Credit card number of the customer; 16 digit numeric string

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
    i.raw.length = 16 ∧
    i.raw.toList.all Char.isDigit = true

example : Spec.pre { raw := "1234567890123456" } ∧
          Spec.post { raw := "1234567890123456" }
                    { valid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (data constraint (one validity rule)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide (x.raw.length = 16 ∧ x.raw.toList.all Char.isDigit) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
