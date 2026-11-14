import ContractForge
open ContractForge

-- 4.3.6.6: The driver shall have the possibility to select the language, this does not concern non pre-defined texts sent from the trackside.

-- L0 spec

structure Input where
  language : String
  deriving DecidableEq, Repr

structure Output where
  language : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.language ≠ ""
  post := fun i o => o.language = i.language

example : Spec.pre { language := "en" } ∧
          Spec.post { language := "en" } { language := "en" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { language := x.language }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
