import ContractForge
open ContractForge

-- 7.2.3.12: 7.2.3.12 It shall be possible for the user to find and display stored numbers and their information. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure StoredNumber where
  number : Nat
  info   : String
  deriving DecidableEq, Repr

structure Input where
  numbers : List StoredNumber
  query   : String
  deriving DecidableEq, Repr

structure Output where
  results : List StoredNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.numbers ∧ it.info.contains i.query) ∧
    (o.results.length ≤ 100 → ∀ it ∈ i.numbers, it.info.contains i.query → it ∈ o.results) ∧
    o.results.length ≤ 100

example : Spec.pre { numbers := [], query := "123" } ∧ Spec.post { numbers := [], query := "123" } { results := [] } := by
  unfold Spec; decide
