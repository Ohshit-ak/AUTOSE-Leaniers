import ContractForge
open ContractForge

-- 5.2.3.41: 5.2.3.41 It should be possible for the driver to store and overwrite numbers and their details in the Cab radio. (O) Invoke supplementary services
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  number  : Nat
  details : String
  deriving DecidableEq, Repr

structure Output where
  number  : Nat
  details : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.number = i.number ∧
                     (o.details = i.details ∨
                      (o.number ≠ i.number ∧ o.details = "Overwritten"))

example : Spec.pre { number := 5, details := "Test details" } ∧ Spec.post { number := 5, details := "Test details" } { number := 5, details := "Test details" } := by
  unfold Spec; decide
