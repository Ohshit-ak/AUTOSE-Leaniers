import ContractForge
open ContractForge

-- 3.11.4/I5: TALDT denotes Total Administrative and Logistic Downtime
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  downtime : Nat
  deriving DecidableEq, Repr

structure Output where
  availability : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.downtime < 100
  post := fun i o => o.availability = 100 - i.downtime

example : Spec.pre { downtime := 5 } ∧
          Spec.post { downtime := 5 } { availability := 95 } := by
  unfold Spec; decide
