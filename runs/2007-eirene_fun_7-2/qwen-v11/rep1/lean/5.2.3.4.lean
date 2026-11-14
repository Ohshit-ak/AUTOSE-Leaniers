import ContractForge
open ContractForge

-- 5.2.3.4: 5.2.3.4 When switched off, the radio shall retain any numbers which are stored at the time the radio is switched off. (M) Switch radio MMI on/off
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  numbersStored : List Nat
  switchedOn    : Bool
  deriving DecidableEq, Repr

structure Output where
  switchedOn    : Bool
  numbersStored : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.switchedOn
  post := fun i o => o.switchedOn = false ∧
                     o.numbersStored = i.numbersStored

example : Spec.pre { numbersStored := [5, 10, 15], switchedOn := true } ∧
          Spec.post { numbersStored := [5, 10, 15], switchedOn := true }
                    { switchedOn := false, numbersStored := [5, 10, 15] } := by
  unfold Spec; decide
