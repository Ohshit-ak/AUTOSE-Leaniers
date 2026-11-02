import ContractForge
open ContractForge

-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  deriving DecidableEq, Repr

structure Output where
  accounts : List Account
  deleted  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.deleted = true ∧
                     o.accounts = i.accounts.filter (fun a => a.username ≠ i.username)

example : Spec.pre { accounts := [{ username := "user1" }, { username := "user2" }],
                     username := "user1" } ∧
          Spec.post { accounts := [{ username := "user1" }, { username := "user2" }],
                      username := "user1" }
                    { accounts := [{ username := "user2" }], deleted := true } := by
  unfold Spec; decide
