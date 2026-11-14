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
  created : Bool
  user    : User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.template.isNone ∨ i.users.Nodup
  post := fun i o => (o.created = true ↔
    (i.template.isSome →
      i.users.count (·.username = i.template.getD.username) = 0 ∧
      i.users.count (·.email = i.template.getD.email) = 0) ∧
    (i.template.isNone →
      i.users.count (·.username = o.user.username) = 0 ∧
      i.users.count (·.email = o.user.email) = 0)) ∧
    o.user = i.template.getD ∨
    o.user = { username := "newUser", password := "pass123", email := "new@example.com", role := "admin" }

example : Spec.pre { users := [{ username := "user1", password := "pass123", email := "user1@example.com", role := "admin" }],
                     template := some { username := "user2", password := "pass456", email := "user2@example.com", role := "user" } } ∧
          Spec.post { users := [{ username := "user1", password := "pass123", email := "user1@example.com", role := "admin" }],
                      template := some { username := "user2", password := "pass456", email := "user2@example.com", role := "user" } }
                    { created := true, user := { username := "user2", password := "pass456", email := "user2@example.com", role := "user" } } := by
  unfold Spec; decide
