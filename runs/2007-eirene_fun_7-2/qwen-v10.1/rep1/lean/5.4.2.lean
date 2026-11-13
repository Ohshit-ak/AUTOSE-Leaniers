import ContractForge
open ContractForge

-- 5.4.2: 5.4.2 Radio equipment installed in a drivers Cab shall not obstruct the drivers vision or otherwise hinder the safe driving of the train. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  radioObstructsVision : Bool
  deriving DecidableEq, Repr

structure Output where
  safeToDrive : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.radioObstructsVision = false
  post := fun i o => o.safeToDrive = true ↔ i.radioObstructsVision = false

example : Spec.pre { radioObstructsVision := false } ∧
          Spec.post { radioObstructsVision := false }
                    { safeToDrive := true } := by
  unfold Spec; decide
