import ContractForge
open ContractForge

-- 11.2.1.2: 11.2.1.2 The primary usage of functional addressing will be for controllers to establish communications with train drivers by making use of the train number. The train number will vary between journeys although EIRENE equipment in the cab is unlikely to change. (I)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  trainNumber : String
  deriving DecidableEq, Repr

structure Output where
  communicationEstablished : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ ""
  post := fun i o => o.communicationEstablished = true ↔
    (i.trainNumber.toList.all Char.isDigit = true) ∧
    (i.trainNumber.length = 4) ∧
    (o.communicationEstablished = false →
      (i.trainNumber = "1234" ∨ i.trainNumber = "5678"))

example : Spec.pre { trainNumber := "1234" } ∧
          Spec.post { trainNumber := "1234" }
                    { communicationEstablished := true } := by
  unfold Spec; decide
