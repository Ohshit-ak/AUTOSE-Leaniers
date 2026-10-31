import ContractForge
open ContractForge

-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure User where
  username : String
  deriving DecidableEq, Repr

structure Account where
  username : String
  deriving DecidableEq, Repr

structure Input where
  users    : List User
  selected : User
  deriving DecidableEq, Repr

structure Output where
  users    : List User
  deleted  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selected.username ≠ ""
  post := fun i o => o.deleted = true ∧
                     o.users = i.users.filter (·.username ≠ i.selected.username)

example : Spec.pre { users := [], selected := { username := "bob" } } ∧ Spec.post { users := [], selected := { username := "bob" } } { users := [], deleted := true } := by
  unfold Spec; decide
