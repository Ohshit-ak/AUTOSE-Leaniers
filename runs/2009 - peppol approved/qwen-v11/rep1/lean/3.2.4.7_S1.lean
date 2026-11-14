import ContractForge
open ContractForge

-- 3.2.4.7/S1: Description Any VCD package that is created by a VCD system should be an artefact that can be interpreted without using specific technology.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  vcdPackage : String
  deriving DecidableEq, Repr

structure Output where
  interpretable : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.interpretable = true

example : Spec.pre { vcdPackage := "example" } ∧ Spec.post { vcdPackage := "example" } { interpretable := true } := by
  unfold Spec; decide
