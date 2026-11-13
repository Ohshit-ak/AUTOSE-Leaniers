import ContractForge
open ContractForge

-- 3.10.1.6: Once received onboard the national values shall remain valid even if the onboard equipment is switched off

-- L0 spec

structure Input where
  nationalValues : String
  deriving DecidableEq, Repr

structure Output where
  nationalValues : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.nationalValues ≠ ""
  post := fun i o => o.nationalValues = i.nationalValues

example : Spec.pre { nationalValues := "values" } ∧
          Spec.post { nationalValues := "values" } { nationalValues := "values" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { nationalValues := x.nationalValues }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
