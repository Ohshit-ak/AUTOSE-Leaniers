import ContractForge
open ContractForge

-- 7.5.9/S1: Changing the battery shall not result in the loss of data stored in the radio.
-- compiles: True · rejects_bad_example: True · checked: True

structure Battery where
  id : Nat
  deriving DecidableEq, Repr

structure Radio where
  data : String
  battery : Option Battery
  deriving DecidableEq, Repr

structure Input where
  oldBattery : Option Battery
  newBattery : Option Battery
  radioData  : String
  deriving DecidableEq, Repr

structure Output where
  radioData : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.oldBattery ≠ none ∧ i.newBattery ≠ none
  post := fun i o => o.radioData = i.radioData

example : Spec.pre { oldBattery := some { id := 1 }, newBattery := some { id := 2 },
                     radioData := "config" } ∧
          Spec.post { oldBattery := some { id := 1 }, newBattery := some { id := 2 },
                      radioData := "config" }
                    { radioData := "config" } := by
  unfold Spec; decide
