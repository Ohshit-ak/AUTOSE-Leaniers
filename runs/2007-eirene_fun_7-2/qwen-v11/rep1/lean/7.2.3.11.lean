import ContractForge
open ContractForge

-- 7.2.3.11: 7.2.3.11 Where a change of functional number is required, it shall be possible for the user to initiate the change. (M) Store/retrieve numbers and their details
-- compiles: True · rejects_bad_example: None · checked: False

structure FunctionalNumber where
  number : Nat
  details : String
  deriving DecidableEq, Repr

structure Input where
  numbers : List FunctionalNumber
  deriving DecidableEq, Repr

structure Output where
  numbers : List FunctionalNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.numbers.Nodup
  post := fun i o => o.numbers = i.numbers ∧
                     (o.numbers.length = i.numbers.length + 1 →
                      ∃ fn ∈ o.numbers, fn.number = i.numbers.length + 1) ∧
                     (o.numbers.length = i.numbers.length - 1 →
                      ∃ fn ∈ o.numbers, fn.number = i.numbers.length) ∧
                     (o.numbers.length = i.numbers.length →
                      ∀ fn ∈ o.numbers, ∃ fn' ∈ i.numbers, fn = fn')

example : Spec.pre { numbers := [{ number := 1, details := "Detail 1" },
                                  { number := 2, details := "Detail 2" }] } ∧
          Spec.post { numbers := [{ number := 1, details := "Detail 1" },
                                  { number := 2, details := "Detail 2" },
                                  { number := 3, details := "Detail 3" }] }
                    { numbers := [{ number := 1, details := "Detail 1" },
                                  { number := 2, details := "Detail 2" },
                                  { number := 3, details := "Detail 3" }] } := by
  unfold Spec; decide
