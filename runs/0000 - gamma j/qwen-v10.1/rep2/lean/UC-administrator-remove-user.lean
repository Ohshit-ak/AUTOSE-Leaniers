import ContractForge
open ContractForge

-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure User where
  username : String
  password : String
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
                     (o.users = i.users.filter (fun u => u.username ≠ i.username))

example : Spec.pre { users := [{ username := "alice", password := "pass1" },
                                { username := "bob", password := "pass2" }],
                     username := "alice" } ∧
          Spec.post { users := [{ username := "alice", password := "pass1" },
                                { username := "bob", password := "pass2" }],
                      username := "alice" }
                    { users := [{ username := "bob", password := "pass2" }] } := by
  unfold Spec; decide
