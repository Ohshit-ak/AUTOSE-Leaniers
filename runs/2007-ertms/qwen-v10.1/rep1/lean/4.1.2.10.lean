import ContractForge
open ContractForge

-- 4.1.2.10: Current train data shall be stored (except at transition to shunting) in the ETCS equipment until the traction unit is not operative.
-- compiles: True · rejects_bad_example: True · checked: True

structure TrainData where
  current : String
  deriving DecidableEq, Repr

structure Input where
  tractionUnitOperative : Bool
  deriving DecidableEq, Repr

structure Output where
  currentTrainData : Option TrainData
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => (o.currentTrainData = some { current := "current train data" } ↔
                      ¬i.tractionUnitOperative) ∧
                     (o.currentTrainData = none ↔
                      i.tractionUnitOperative)

example : Spec.pre { tractionUnitOperative := true } ∧
          Spec.post { tractionUnitOperative := true }
                     { currentTrainData := none } := by
  unfold Spec; decide
