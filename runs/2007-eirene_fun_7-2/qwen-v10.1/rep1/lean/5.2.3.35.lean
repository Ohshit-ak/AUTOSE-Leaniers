import ContractForge
open ContractForge

-- 5.2.3.35: 5.2.3.35 The functional number of other on-train users who may be addressed through the Cab radio via the on-train bus shall be registered/deregistered automatically at the same time as the registration/deregistration of the drivers functional number. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  driversNumber : Nat
  otherNumbers  : List Nat
  deriving DecidableEq, Repr

structure Output where
  driversNumber : Nat
  otherNumbers  : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.driversNumber = i.driversNumber ∧
                     o.otherNumbers = i.otherNumbers

example : Spec.pre { driversNumber := 123, otherNumbers := [456, 789] } ∧
          Spec.post { driversNumber := 123, otherNumbers := [456, 789] }
                    { driversNumber := 123, otherNumbers := [456, 789] } := by
  unfold Spec; decide

-- IMPL: The system automatically updates the list of other numbers when the
-- drivers number is registered or deregistered.
