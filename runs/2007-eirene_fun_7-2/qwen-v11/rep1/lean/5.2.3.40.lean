import ContractForge
open ContractForge

-- 5.2.3.40: 5.2.3.40 It shall be possible for the driver to find and display stored numbers and their information. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure StoredNumber where
  number : Nat
  info   : String
  deriving DecidableEq, Repr

structure Input where
  numbers : List StoredNumber
  deriving DecidableEq, Repr

structure Output where
  displayed : List StoredNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.numbers.Nodup
  post := fun i o => o.displayed.length ≤ i.numbers.length ∧
                     (∀ n ∈ o.displayed, ∃ n' ∈ i.numbers, n.number = n'.number ∧ n.info = n'.info) ∧
                     (o.displayed = [] ↔ i.numbers = []) ∧
                     (o.displayed.length = i.numbers.length ↔ o.displayed = i.numbers)

example : Spec.pre { numbers := [{ number := 5, info := "Home" },
                                  { number := 10, info := "Work" }] } ∧
          Spec.post { numbers := [{ number := 5, info := "Home" },
                                  { number := 10, info := "Work" }] }
                    { displayed := [{ number := 5, info := "Home" },
                                    { number := 10, info := "Work" }] } := by
  unfold Spec; decide

example : Spec.pre { numbers := [] } ∧
          Spec.post { numbers := [] }
                    { displayed := [] } := by
  unfold Spec; decide
