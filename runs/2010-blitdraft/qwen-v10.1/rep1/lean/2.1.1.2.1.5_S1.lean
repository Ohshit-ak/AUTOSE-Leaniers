import ContractForge
open ContractForge

-- 2.1.1.2.1.5/S1: The user shall be able to create/add a new user manually or from a template.
-- compiles: False · rejects_bad_example: None · checked: False

structure User where
  username : String
  password : String
  email    : String
  role     : String
  deriving DecidableEq, Repr

structure Input where
  users : List User
  template : Option User
  deriving DecidableEq, Repr

structure Output where
  users : List User
  added : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.template.isNone ∨ i.users.Nodup
  post := fun i o => o.added = true ↔
    (i.template.isNone →
      ∃ u ∈ i.users, u.username ≠ "" ∧ u.password ≠ "" ∧ u.email ≠ "" ∧ u.role ≠ "" ∧
      o.users.contains u ∧ o.users.count u = i.users.count u + 1) ∧
    (i.template.isSome →
      o.users.contains i.template.getD { username := "", password := "", email := "", role := "" } ∧
      o.users.count i.template.getD { username := "", password := "", email := "", role := "" } = i.users.count i.template.getD { username := "", password := "", email := "", role := "" } + 1)

example : Spec.pre { users := [{ username := "user1", password := "pass1", email := "email1", role := "admin" }],
                     template := none } ∧
          Spec.post { users := [{ username := "user1", password := "pass1", email := "email1", role := "admin" }],
                      template := none }
                    { users := [{ username := "user1", password := "pass1", email := "email1", role := "admin" }],
                      added := true } := by
  unfold Spec; decide

example : Spec.pre { users := [{ username := "user1", password := "pass1", email := "email1", role := "admin" }],
                     template := some { username := "user2", password := "pass2", email := "email2", role := "user" } } ∧
          Spec.post { users := [{ username := "user1", password := "pass1", email := "email1", role := "admin" }],
                      template := some { username := "user2", password := "pass2", email := "email2", role := "user" } }
                    { users := [{ username := "user1", password := "pass1", email := "email1", role := "admin" },
                                { username := "user2", password := "pass2", email := "email2", role := "user" }],
                      added := true } := by
  unfold Spec; decide
