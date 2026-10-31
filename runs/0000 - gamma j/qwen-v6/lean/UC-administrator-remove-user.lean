import ContractForge
open ContractForge

-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- compiles: True · rejects_bad_example: None · checked: False

structure User where
  username : String
  deriving DecidableEq, Repr

structure Input where
  users  : List User
  target : User
  deriving DecidableEq, Repr

structure Output where
  users  : List User
  removed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.users.Nodup ∧ i.target ∈ i.users
  post := fun i o => o.removed = true ∧ o.users = i.users.filter (· ≠ i.target)

example : Spec.pre { users := [{ username := "alice" }, { username := "bob" }],
                     target := { username := "alice" } } ∧
          Spec.post { users := [{ username := "alice" }, { username := "bob" }],
                      target := { username := "alice" } }
                    { removed := true, users := [{ username := "bob" }] } := by
  unfold Spec; decide
