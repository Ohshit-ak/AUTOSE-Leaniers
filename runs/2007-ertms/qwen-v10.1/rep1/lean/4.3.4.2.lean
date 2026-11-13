import ContractForge
open ContractForge

-- 4.3.4.2: On lines fitted with RBC, the ETCS trainborne equipment shall be able to transmit the location of the entire train to the RBC.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  trainLocation : Nat -- location of the train in some unit (e.g., meters)
  deriving DecidableEq, Repr

structure Output where
  transmitted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true -- no assumptions about the input
  post := fun i o => o.transmitted = true ↔ 0 ≤ i.trainLocation

example : Spec.pre { trainLocation := 1000 } ∧
          Spec.post { trainLocation := 1000 } { transmitted := true } := by
  unfold Spec; decide
