-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- checked: True

structure Input where
  userId : Nat
  deriving DecidableEq, Repr

structure Output where
  deleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.userId ≠ 0
  post := fun i o => o.deleted = true

example : Spec.pre { userId := 1 } ∧ Spec.post { userId := 1 } { deleted := true } := by
  unfold Spec; decide
