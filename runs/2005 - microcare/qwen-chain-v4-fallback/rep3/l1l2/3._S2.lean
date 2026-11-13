import ContractForge
open ContractForge

-- 3./S2: In this module you will see that every capture of data will be validated and checked on saving into the database.

-- L0 spec

structure Input where
  data : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.data.isEmpty = false ∧
     i.data.toList.all (fun c => c.isAlpha ∨ Char.isDigit c ∨ c == ' '))

example : Spec.pre { data := "example data" } ∧
          Spec.post { data := "example data" }
                    { valid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide (x.data.isEmpty = false ∧ x.data.toList.all (fun c => c.isAlpha ∨ Char.isDigit c ∨ c == ' ')) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
