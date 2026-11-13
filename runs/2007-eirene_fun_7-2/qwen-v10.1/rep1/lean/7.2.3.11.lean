import ContractForge
open ContractForge

-- 7.2.3.11: 7.2.3.11 Where a change of functional number is required, it shall be possible for the user to initiate the change. (M) Store/retrieve numbers and their details
-- compiles: True · rejects_bad_example: True · checked: True

structure FunctionalNumber where
  number : Nat
  details : String
  newNumber : Nat
  newDetails : String
  deriving DecidableEq, Repr

structure Input where
  numbers : List FunctionalNumber
  newNumber : Nat
  newDetails : String
  deriving DecidableEq, Repr

structure Output where
  numbers : List FunctionalNumber
  newNumber : Nat
  newDetails : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.numbers.length > 0
  post := fun i o =>
    o.newNumber ≠ i.newNumber ∧
    o.newDetails ≠ i.newDetails ∧
    o.numbers.Nodup ∧
    o.numbers.length > 0 ∧
    (∀ fn ∈ o.numbers, ∃ fn' ∈ i.numbers, fn.number = fn'.number ∧
      (fn.details = fn'.details ∧ fn'.newNumber = fn.newNumber ∧ fn'.newDetails = fn.newDetails) ∨
      (fn.details ≠ fn'.details ∨ fn'.newNumber ≠ fn.newNumber ∨ fn'.newDetails ≠ fn.newDetails))

example : Spec.pre { numbers := [{ number := 1, details := "Detail 1", newNumber := 1, newDetails := "Detail 1" }, { number := 2, details := "Detail 2", newNumber := 2, newDetails := "Detail 2" }], newNumber := 3, newDetails := "New Detail" } ∧ Spec.post { numbers := [{ number := 1, details := "Detail 1", newNumber := 1, newDetails := "Detail 1" }, { number := 2, details := "Detail 2", newNumber := 2, newDetails := "Detail 2" }], newNumber := 3, newDetails := "New Detail" } { numbers := [{ number := 1, details := "Detail 1", newNumber := 1, newDetails := "Detail 1" }, { number := 2, details := "Detail 2", newNumber := 2, newDetails := "Detail 2" }], newNumber := 0, newDetails := "" } := by
  unfold Spec; decide
