import ContractForge
open ContractForge

-- DD-item-name: Name of the selected item; maximum 50 character alphabetic string

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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 50 ∧
     i.raw.toList.all (·.isAlpha) = true)

example : Spec.pre { raw := "exampleName" } ∧
          Spec.post { raw := "exampleName" } { valid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (data constraint (one validity rule)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide ((1 ≤ x.raw.length ∧ x.raw.length ≤ 50 ∧
     x.raw.toList.all (·.isAlpha) = true)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
