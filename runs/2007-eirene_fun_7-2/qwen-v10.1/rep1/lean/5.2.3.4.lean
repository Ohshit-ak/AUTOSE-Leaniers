import ContractForge
open ContractForge

-- 5.2.3.4: 5.2.3.4 When switched off, the radio shall retain any numbers which are stored at the time the radio is switched off. (M) Switch radio MMI on/off
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  numbersStored : List Nat
  switchedOn    : Bool
  deriving DecidableEq, Repr

structure Output where
  numbersStored : List Nat
  switchedOn    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.numbersStored = i.numbersStored ∧ o.switchedOn = ¬ i.switchedOn

example : Spec.pre { numbersStored := [5, 10, 15], switchedOn := true } ∧
          Spec.post { numbersStored := [5, 10, 15], switchedOn := true }
                    { numbersStored := [5, 10, 15], switchedOn := false } := by
  unfold Spec; decide
