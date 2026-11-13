import ContractForge
open ContractForge

-- DD-tracking-no: Number to track the order; 20 characters alphanumeric

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
    (i.raw.length = 20 ∧
     i.raw.toList.all Char.isAlphanum = true)

example : Spec.pre { raw := "A1B2C3D4E5F6G7H8I9J0" } ∧
          Spec.post { raw := "A1B2C3D4E5F6G7H8I9J0" }
                    { valid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (data constraint (one validity rule)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide (x.raw.length = 20 ∧ x.raw.toList.all Char.isAlphanum) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
