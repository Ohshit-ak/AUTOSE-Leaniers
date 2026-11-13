import ContractForge
open ContractForge

-- 3.7.2/S1: The network shall terminate the ongoing VGCS/VBS call if it receives the 3-digit sequence "***" transmitted via DTMF signals.

-- L0 spec

structure Input where
  dtmfSequence : String
  deriving DecidableEq, Repr

structure Output where
  terminated : Bool
  deriving DecidableEq, Repr

-- IMPL: The network checks for the 3-digit sequence "***" in the DTMF signals.
def Spec : Contract Input Output where
  pre  := fun i => i.dtmfSequence.length = 3
  post := fun i o => o.terminated = true ↔ i.dtmfSequence = "***"

example : Spec.pre { dtmfSequence := "***" } ∧
          Spec.post { dtmfSequence := "***" } { terminated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { terminated := x.dtmfSequence = "***" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
