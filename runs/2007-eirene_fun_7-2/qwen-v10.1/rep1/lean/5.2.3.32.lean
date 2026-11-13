import ContractForge
open ContractForge

-- 5.2.3.32: 5.2.3.32 Where a change of train number is required during the course of a trains journey, it shall be possible for the driver to initiate the change or override the automatic change. This shall be carried out by entering the train number (option 1 in 5.2.3.26). (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  trainNumber : String
  override    : Bool
  deriving DecidableEq, Repr

structure Output where
  trainNumber : String
  accepted    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ "" ∧ (i.override ∨ i.trainNumber.toList.all Char.isDigit = true)
  post := fun i o => (o.accepted = true ↔ i.override) ∧
                     (o.trainNumber = if i.override then i.trainNumber else o.trainNumber)

example : Spec.pre { trainNumber := "12345", override := true } ∧
          Spec.post { trainNumber := "12345", override := true }
                    { accepted := true, trainNumber := "12345" } := by
  unfold Spec; decide
