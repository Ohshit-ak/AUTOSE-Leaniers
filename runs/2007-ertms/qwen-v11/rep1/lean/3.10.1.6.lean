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
  pre  := fun i => True
  post := fun i o => o.nationalValues = i.nationalValues ∧
                     (o.nationalValues ≠ i.nationalValues → False)

example : Spec.pre { nationalValues := "AB12345" } ∧
          Spec.post { nationalValues := "AB12345" } { nationalValues := "AB12345" } := by
  unfold Spec; decide
