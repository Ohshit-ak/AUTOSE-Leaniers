import ContractForge
open ContractForge

-- 5.2.3.28i: 5.2.3.28i Where ERTMS/ETCS and radio systems are available and the driver is required to enter the train number as part of the initialisation procedure, this task shall be carried out only once on the ERTMS/ETCS system and the entered number transmitted to the radio system. (M)
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  trainNumber : String
  transmitted : Bool
  deriving DecidableEq, Repr

structure Output where
  trainNumber : String
  transmitted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ ""
  post := fun i o => (o.transmitted = true ↔
    i.trainNumber.length = 5 ∧
    ∃ r ∈ i.trainNumber.toList, r = '1' ∨ r = '2' ∨ r = '3' ∨ r = '4' ∨ r = '5') ∧
    o.trainNumber = i.trainNumber

example : Spec.pre { trainNumber := "12345", transmitted := true } ∧
          Spec.post { trainNumber := "12345", transmitted := true }
                    { trainNumber := "12345", transmitted := true } := by
  unfold Spec; decide
