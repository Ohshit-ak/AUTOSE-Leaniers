import ContractForge
open ContractForge

-- 5.2.3.41: 5.2.3.41 It should be possible for the driver to store and overwrite numbers and their details in the Cab radio. (O) Invoke supplementary services
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  number   : Nat
  details  : String
  existing : Option Nat
  deriving DecidableEq, Repr

structure Output where
  number   : Nat
  details  : String
  existing : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => (o.number = i.number ∧ o.details = i.details ∧ o.existing = i.existing) ∨
                     (o.number = i.number ∧ o.details = "" ∧ o.existing = i.existing) ∨
                     (o.number = i.number ∧ o.details = i.details ∧ o.existing = none) ∨
                     (o.number = i.number ∧ o.details = i.details ∧ o.existing = some 3)

example : Spec.pre { number := 5, details := "Test", existing := some 3 } ∧
          Spec.post { number := 5, details := "Test", existing := some 3 }
                    { number := 5, details := "Test", existing := some 3 } := by
  unfold Spec; decide
