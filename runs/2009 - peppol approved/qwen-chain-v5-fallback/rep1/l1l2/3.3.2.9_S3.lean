import ContractForge
open ContractForge

-- 3.3.2.9/S3: Requirement Special legal regulations for evidences MUST be considered (e.g. for extract from the register of conviction).

-- L0 spec

structure Input where
  evidence : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    i.evidence = "other special legal regulation" ∨
    (i.evidence = "extract from the register of conviction" → o.valid = false)

example : Spec.pre { evidence := "" } ∧ Spec.post { evidence := "" } { valid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { valid := decide (x.evidence = "other special legal regulation" ∨
                     (x.evidence = "extract from the register of conviction" → false)) }
