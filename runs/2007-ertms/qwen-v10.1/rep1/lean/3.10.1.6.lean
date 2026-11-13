import ContractForge
open ContractForge

-- 3.10.1.6: Once received onboard the national values shall remain valid even if the onboard equipment is switched off
-- compiles: True · rejects_bad_example: True · checked: True

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
