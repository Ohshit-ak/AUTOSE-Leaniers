import ContractForge
open ContractForge

-- 4.8.8.5: The onboard equipment shall display plain text messages as received.

-- L0 spec

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  displayed : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.displayed = i.message

example : Spec.pre { message := "Hello, world!" } ∧
          Spec.post { message := "Hello, world!" } { displayed := "Hello, world!" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { displayed := x.message }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
