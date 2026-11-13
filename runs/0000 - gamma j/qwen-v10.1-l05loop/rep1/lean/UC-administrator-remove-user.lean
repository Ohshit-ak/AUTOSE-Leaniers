import ContractForge
open ContractForge

-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure User where
  username : String
  deriving DecidableEq, Repr

structure Account where
  username : String
  deriving DecidableEq, Repr

structure Input where
  users   : List User
  username : String
  deriving DecidableEq, Repr

structure Output where
  users   : List User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.users.length > 0
  post := fun i o => o.users.length = i.users.length - 1 ∧
                     ∃ u ∈ i.users, u.username = i.username ∧
                     ¬∃ u' ∈ o.users, u'.username = i.username

example : Spec.pre { users := [{ username := "user1" }, { username := "user2" }],
                     username := "user1" } ∧
          Spec.post { users := [{ username := "user1" }, { username := "user2" }],
                      username := "user1" }
                    { users := [{ username := "user2" }] } := by
  unfold Spec; decide
