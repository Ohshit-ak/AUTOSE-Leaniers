import ContractForge
open ContractForge

-- 5.5.13/S2: It shall be possible to store a priority in association with a stored number.
-- compiles: False · rejects_bad_example: None · checked: False

structure Priority where
  value : Nat
  deriving DecidableEq, Repr

structure StoredNumber where
  number : String
  priority : Option Priority
  deriving DecidableEq, Repr

structure Input where
  numbers : List StoredNumber
  deriving DecidableEq, Repr

structure Output where
  numbers : List StoredNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.numbers = i.numbers ∧
                     ∀ n ∈ o.numbers, n.priority = i.n.priority

example : Spec.pre { numbers := [{ number := "123", priority := some { value := 5 } },
                                  { number := "456", priority := none }] } ∧
          Spec.post { numbers := [{ number := "123", priority := some { value := 5 } },
                                  { number := "456", priority := none }] }
                    { numbers := [{ number := "123", priority := some { value := 5 } },
                                  { number := "456", priority := none }] } := by
  unfold Spec; decide
