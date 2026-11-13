import ContractForge
open ContractForge

-- 4.1.4.2a: If acknowledgement is specified the driver shall acknowledge transfer from Full Supervision to Partial Supervision within 5 seconds
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  acknowledged : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  acknowledged : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.acknowledged
  post := fun i o => o.acknowledged = i.acknowledged ∧
                     o.elapsedMicros ≤ 5000000

example : Spec.pre { acknowledged := true, elapsedMicros := 0 } ∧
          Spec.post { acknowledged := true, elapsedMicros := 4999999 }
                    { acknowledged := true, elapsedMicros := 4999999 } := by
  unfold Spec; decide
