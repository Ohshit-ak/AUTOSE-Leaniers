import ContractForge
open ContractForge

-- 5.4.2: 5.4.2 Radio equipment installed in a drivers Cab shall not obstruct the drivers vision or otherwise hinder the safe driving of the train. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  radioSize : Nat
  driverVision : Bool
  deriving DecidableEq, Repr

structure Output where
  safe : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverVision = true
  post := fun i o => o.safe = true ↔ i.radioSize < 5

example : Spec.pre { radioSize := 4, driverVision := true } ∧
          Spec.post { radioSize := 4, driverVision := true }
                    { safe := true } := by
  unfold Spec; decide
