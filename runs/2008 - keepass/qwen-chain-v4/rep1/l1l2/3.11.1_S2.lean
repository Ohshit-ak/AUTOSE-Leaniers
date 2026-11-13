import ContractForge
open ContractForge

-- 3.11.1/S2: This can be done by selecting view/edit entry.

-- L0 spec

structure Input where
  entryId : Nat
  deriving DecidableEq, Repr

structure Output where
  description : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.entryId ≠ 0
  post := fun i o => o.description = "This can be done by selecting view/edit entry."

example : Spec.pre { entryId := 1 } ∧ Spec.post { entryId := 1 } { description := "This can be done by selecting view/edit entry." } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { description := "This can be done by selecting view/edit entry." }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
