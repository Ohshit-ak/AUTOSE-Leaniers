import ContractForge
open ContractForge

-- 2.14.4/I3: .Gemini subsystem should be as self-contained and autonomous as possible, thereby decreasing the functional width of the interface to the rest of the Gemini system.

-- L0 spec

structure Input where
  data : String
  deriving DecidableEq, Repr

structure Output where
  result : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.result = i.data

example : Spec.pre { data := "test" } ∧ Spec.post { data := "test" } { result := "test" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { result := x.data }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
