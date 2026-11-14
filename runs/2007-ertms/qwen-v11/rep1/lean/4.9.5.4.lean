import ContractForge
open ContractForge

-- 4.9.5.4: The driver shall be able to confirm the train integrity to the RBC manually. The confirmation requires the train to be stationary.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  isStationary : Bool
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isStationary
  post := fun i o => o.confirmed = i.isStationary

example : Spec.pre { isStationary := true } ∧ Spec.post { isStationary := true } { confirmed := true } := by
  unfold Spec; decide
