import ContractForge
open ContractForge

-- 11.3.12/S1: The result of the deregistration procedure shall be sent back to the mobile.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mobileId : Nat
  deriving DecidableEq, Repr

structure Output where
  mobileId : Nat
  success  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileId ≠ 0
  post := fun i o => o.mobileId = i.mobileId ∧
                     (o.success = true ↔ o.mobileId ≠ 0) ∧
                     (o.success = false → o.mobileId = 0)

example : Spec.pre { mobileId := 123 } ∧
          Spec.post { mobileId := 123 }
                    { mobileId := 123, success := true } := by
  unfold Spec; decide
