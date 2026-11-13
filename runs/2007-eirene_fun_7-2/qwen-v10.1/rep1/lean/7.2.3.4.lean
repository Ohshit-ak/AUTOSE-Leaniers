import ContractForge
open ContractForge

-- 7.2.3.4: 7.2.3.4 When switched off, the radio shall retain any settings and numbers which are stored at the time the radio is switched off. (M) Select language
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  settings : String
  numbers  : List Nat
  deriving DecidableEq, Repr

structure Output where
  settings : String
  numbers  : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.settings = i.settings ∧ o.numbers = i.numbers

example : Spec.pre { settings := "English", numbers := [123, 456] } ∧
          Spec.post { settings := "English", numbers := [123, 456] }
                    { settings := "English", numbers := [123, 456] } := by
  unfold Spec; decide
