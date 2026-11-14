import ContractForge
open ContractForge

-- 7.2.3.13: 7.2.3.13 It shall be possible for the user to store and/or overwrite numbers and their details in the radio. (M) Computer interface
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  number : Nat
  details : String
  deriving DecidableEq, Repr

structure Output where
  stored : Bool
  newNumber : Nat
  newDetails : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.stored = true ∧
                     (o.newNumber = i.number ∨ o.newNumber ≠ i.number) ∧
                     (o.newDetails = i.details ∨ o.newDetails ≠ i.details) ∧
                     (o.newNumber = i.number ↔ o.stored) ∧
                     (o.newDetails = i.details ↔ o.stored)

example : Spec.pre { number := 123, details := "details123" } ∧
          Spec.post { number := 123, details := "details123" }
                    { stored := true, newNumber := 123, newDetails := "details123" } := by
  unfold Spec; decide
