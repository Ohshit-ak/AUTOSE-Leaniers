import ContractForge
open ContractForge

-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- compiles: False · rejects_bad_example: None · checked: False

structure User where
  username : String
  deriving DecidableEq, Repr

structure Input where
  users : List User
  username : String
  deriving DecidableEq, Repr

structure Output where
  users : List User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.users.Nodup ∧
                     (o.users.length = i.users.length - 1 ∧
                      ∃ u ∈ o.users, u.username = i.username) ∧
                     (o.users.length = i.users.length - 1 →
                      ∀ u ∈ i.users, u.username ≠ i.username)

example : Spec.pre { users := [{ username := "alice" }, { username := "bob" }],
                     username := "alice" } ∧
          Spec.post { users := [{ username := "alice" }, { username := "bob" }],
                      username := "alice" }
                    { users := [{ username := "bob" }] } := by
  unfold Spec; decide
