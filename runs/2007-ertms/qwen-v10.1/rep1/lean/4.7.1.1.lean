import ContractForge
open ContractForge

-- 4.7.1.1: The ETCS trainborne equipment shall transmit its own train identification to the RBC.
-- compiles: True · rejects_bad_example: True · checked: True

structure TrainIdentification where
  id : Nat
  deriving DecidableEq, Repr

structure Input where
  trainId : TrainIdentification
  deriving DecidableEq, Repr

structure Output where
  trainId : TrainIdentification
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.trainId = i.trainId

example : Spec.pre { trainId := { id := 12345 } } ∧
          Spec.post { trainId := { id := 12345 } } { trainId := { id := 12345 } } := by
  unfold Spec; decide
