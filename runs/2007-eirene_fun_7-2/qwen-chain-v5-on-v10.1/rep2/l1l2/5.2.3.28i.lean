import ContractForge
open ContractForge

-- 5.2.3.28i: 5.2.3.28i Where ERTMS/ETCS and radio systems are available and the driver is required to enter the train number as part of the initialisation procedure, this task shall be carried out only once on the ERTMS/ETCS system and the entered number transmitted to the radio system. (M)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { trainNumber := x.trainNumber, transmitted := x.transmitted }
