import ContractForge
open ContractForge

-- 5.1/R9: The system shall be able to restore 1000 records per second.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  records : List String
  deriving DecidableEq, Repr

structure Output where
  perSecond : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.perSecond ≥ 1000

example : Spec.pre { records := ["record1", "record2", "record3"] } ∧
          Spec.post { records := ["record1", "record2", "record3"] }
                    { perSecond := 1001 } := by
  unfold Spec; decide
