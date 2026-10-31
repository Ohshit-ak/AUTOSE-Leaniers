import ContractForge
open ContractForge

-- 5.1/R9: The system shall be able to restore 1000 records per second.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  records : List String
  deriving DecidableEq, Repr

structure Output where
  restored : Nat
  perSecond : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.records.Nodup
  post := fun i o => o.restored = i.records.length ∧
                     o.perSecond ≥ 1000

example : Spec.pre { records := ["rec1", "rec2", "rec3"] } ∧
          Spec.post { records := ["rec1", "rec2", "rec3"] }
                    { restored := 3, perSecond := 1000 } := by
  unfold Spec; decide
