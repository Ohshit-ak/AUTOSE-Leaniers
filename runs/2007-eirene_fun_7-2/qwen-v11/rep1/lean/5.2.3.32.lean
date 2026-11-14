import ContractForge
open ContractForge

-- 5.2.3.32: 5.2.3.32 Where a change of train number is required during the course of a trains journey, it shall be possible for the driver to initiate the change or override the automatic change. This shall be carried out by entering the train number (option 1 in 5.2.3.26). (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  currentTrainNumber : String
  newTrainNumber     : String
  deriving DecidableEq, Repr

structure Output where
  currentTrainNumber : String
  newTrainNumber     : String
  accepted           : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentTrainNumber ≠ "" ∧ i.newTrainNumber ≠ ""
  post := fun i o => (o.accepted = true ↔
    (i.currentTrainNumber ≠ i.newTrainNumber) ∧
    (o.currentTrainNumber = i.currentTrainNumber ∧ o.newTrainNumber = i.newTrainNumber)) ∧
    (o.accepted = false ↔
    (i.currentTrainNumber = i.newTrainNumber) ∧
    (o.currentTrainNumber = i.currentTrainNumber ∧ o.newTrainNumber = i.newTrainNumber))

example : Spec.pre { currentTrainNumber := "1234", newTrainNumber := "5678" } ∧
          Spec.post { currentTrainNumber := "1234", newTrainNumber := "5678" }
                    { currentTrainNumber := "1234", newTrainNumber := "5678", accepted := true } := by
  unfold Spec; decide

example : Spec.pre { currentTrainNumber := "1234", newTrainNumber := "1234" } ∧
          Spec.post { currentTrainNumber := "1234", newTrainNumber := "1234" }
                    { currentTrainNumber := "1234", newTrainNumber := "1234", accepted := false } := by
  unfold Spec; decide
