import ContractForge
open ContractForge

-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure User where
  username : String
  deriving DecidableEq, Repr

structure Input where
  users : List User
  username : String
  deriving DecidableEq, Repr

structure Output where
  users : List User
  deleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.deleted = true ∧
                     o.users.Nodup ∧
                     (∀ u ∈ o.users, u.username ≠ i.username) ∧
                     o.users.length = i.users.length - 1

example : Spec.pre { users := [{ username := "alice" }, { username := "bob" }],
                     username := "bob" } ∧
          Spec.post { users := [{ username := "alice" }, { username := "bob" }],
                      username := "bob" }
                    { users := [{ username := "alice" }], deleted := true } := by
  unfold Spec; decide
