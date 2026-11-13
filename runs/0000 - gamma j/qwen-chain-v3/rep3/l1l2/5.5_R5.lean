import ContractForge
open ContractForge

-- 5.5/R5: The system shall validate email address existence.

-- L0 spec

structure Input where
  email : String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ ""
  post := fun i o => o.exists_ = true ↔ i.email.toList.all Char.isAlphanum = true ∧
                     i.email.contains '@' ∧ i.email.contains '.' ∧
                     i.email.length ≥ 6

example : Spec.pre { email := "test@example.com" } ∧ Spec.post { email := "test@example.com" } { exists_ := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { exists_ := decide (x.email.toList.all Char.isAlphanum ∧
                      x.email.contains '@' ∧
                      x.email.contains '.' ∧
                      x.email.length ≥ 6) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
