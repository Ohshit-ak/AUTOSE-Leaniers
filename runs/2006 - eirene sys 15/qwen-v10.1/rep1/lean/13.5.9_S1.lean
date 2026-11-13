import ContractForge
open ContractForge

-- 13.5.9/S1: The user-to-user information elements in the following messages, as defined in [EN 301 515, Index [16]], shall be used for the confirmation of high priority calls: (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ "" ∧ i.message.toList.all (· == 'M') = true
  post := fun i o => o.confirmed = true

example : Spec.pre { message := "M" } ∧ Spec.post { message := "M" } { confirmed := true } := by
  unfold Spec; decide
