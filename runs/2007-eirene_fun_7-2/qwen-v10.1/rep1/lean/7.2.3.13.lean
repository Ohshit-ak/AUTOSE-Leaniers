import ContractForge
open ContractForge

-- 7.2.3.13: 7.2.3.13 It shall be possible for the user to store and/or overwrite numbers and their details in the radio. (M) Computer interface
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  number   : Nat
  details  : String
  radio    : String
  overwrite : Bool
  deriving DecidableEq, Repr

structure Output where
  radio    : String
  success  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.radio ≠ "" ∧ i.overwrite = true ∨ i.number > 0
  post := fun i o => (o.success = true ↔
    (i.radio = o.radio ∧ (i.number = 0 ∨ o.radio.length ≤ i.radio.length))) ∧
    (o.success = false ↔
      (i.number > 0 ∧ i.radio.length ≤ o.radio.length ∧ i.overwrite = false))

example : Spec.pre { number := 123, details := "test details", radio := "", overwrite := false } ∧ Spec.post { number := 123, details := "test details", radio := "", overwrite := false } { radio := "longerRadio", success := false } := by
  unfold Spec; decide
