import ContractForge
open ContractForge

-- 13.4.8: 13.4.8 The performance of the confirmation procedure shall not be dependent upon the current use of the mobile and shall not overload the network. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  emergencyCallId : Nat
  mobileStatus    : String
  networkLoad     : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmationSent : Bool
  networkLoadAfter : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileStatus ≠ "in use" ∧ 0 < i.networkLoad
  post := fun i o => o.confirmationSent = true ∧
                     o.networkLoadAfter = i.networkLoad - 1

example : Spec.pre { emergencyCallId := 123, mobileStatus := "not in use", networkLoad := 50 } ∧
          Spec.post { emergencyCallId := 123, mobileStatus := "not in use", networkLoad := 50 }
                    { confirmationSent := true, networkLoadAfter := 49 } := by
  unfold Spec; decide
