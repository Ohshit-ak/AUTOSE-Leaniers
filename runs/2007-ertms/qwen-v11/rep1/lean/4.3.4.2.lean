import ContractForge
open ContractForge

-- 4.3.4.2: On lines fitted with RBC, the ETCS trainborne equipment shall be able to transmit the location of the entire train to the RBC.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  trainLocation : Nat -- location of the train in some unit (e.g., meters)
  deriving DecidableEq, Repr

structure Output where
  transmitted : Bool
  location    : Nat -- location of the train, possibly updated
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true -- no assumptions on the input
  post := fun i o => o.transmitted = true ∧
                     (o.location = i.trainLocation ↔ 0 ≤ i.trainLocation)

example : Spec.pre { trainLocation := 1000 } ∧
          Spec.post { trainLocation := 1000 }
                    { transmitted := true, location := 1000 } := by
  unfold Spec; decide
