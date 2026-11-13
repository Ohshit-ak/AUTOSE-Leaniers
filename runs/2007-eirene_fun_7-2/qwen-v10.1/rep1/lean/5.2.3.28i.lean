import ContractForge
open ContractForge

-- 5.2.3.28i: 5.2.3.28i Where ERTMS/ETCS and radio systems are available and the driver is required to enter the train number as part of the initialisation procedure, this task shall be carried out only once on the ERTMS/ETCS system and the entered number transmitted to the radio system. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  trainNumber : String
  transmitted : Bool
  deriving DecidableEq, Repr

structure Output where
  trainNumber : String
  transmitted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ "" ∧
                 i.trainNumber.length = 5 ∧
                 i.trainNumber.toList.all (fun r => Char.isDigit r)
  post := fun i o => o.transmitted = true ↔
    (i.trainNumber.length = 5 ∧
     i.trainNumber.toList.all (fun r => Char.isDigit r)) ∧
    o.trainNumber = i.trainNumber ∧
    o.transmitted = i.transmitted

example : Spec.pre { trainNumber := "11111", transmitted := true } ∧ Spec.post { trainNumber := "11111", transmitted := true } { trainNumber := "11111", transmitted := true } := by
  unfold Spec; decide
