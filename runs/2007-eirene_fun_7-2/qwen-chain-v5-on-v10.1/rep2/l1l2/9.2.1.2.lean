import ContractForge
open ContractForge

-- 9.2.1.2: 9.2.1.2 Each mobile shall be identified by a unique telephone number. (M)

-- L0 spec

structure Input where
  telephoneNumber : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.telephoneNumber ≠ ""
  post := fun i o => o.valid = true ↔
    i.telephoneNumber.toList.all Char.isDigit = true ∧
    i.telephoneNumber.length = 10

example : Spec.pre { telephoneNumber := "1234567890" } ∧
          Spec.post { telephoneNumber := "1234567890" }
                    { valid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide (x.telephoneNumber.toList.all Char.isDigit = true ∧
    x.telephoneNumber.length = 10) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
