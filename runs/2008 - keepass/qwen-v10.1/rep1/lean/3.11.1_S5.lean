import ContractForge
open ContractForge

-- 3.11.1/S5: Then the user can change the group, title, user name, password, URL, notes, expiration date and attachment file.
-- compiles: True · rejects_bad_example: False · checked: False

structure Entry where
  group     : String
  title     : String
  username  : String
  password  : String
  url       : String
  notes     : String
  expiration : String
  attachment: Option String
  deriving DecidableEq, Repr

structure Input where
  entry : Entry
  deriving DecidableEq, Repr

structure Output where
  entry : Entry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.entry.group     = i.entry.group     ∧
                     o.entry.title      = i.entry.title      ∧
                     o.entry.username   = i.entry.username   ∧
                     o.entry.password   = i.entry.password   ∧
                     o.entry.url        = i.entry.url        ∧
                     o.entry.notes      = i.entry.notes      ∧
                     o.entry.expiration = i.entry.expiration ∧
                     o.entry.attachment = i.entry.attachment

example : Spec.pre { entry := { group := "Finance", title := "Bank Account", username := "user1", password := "pass1", url := "http://bank.com", notes := "Important", expiration := "2023-12-31", attachment := some "file.pdf" } } ∧
          Spec.post { entry := { group := "Finance", title := "Bank Account", username := "user1", password := "pass1", url := "http://bank.com", notes := "Important", expiration := "2023-12-31", attachment := some "file.pdf" } }
                    { entry := { group := "Finance", title := "Bank Account", username := "user1", password := "pass1", url := "http://bank.com", notes := "Important", expiration := "2023-12-31", attachment := some "file.pdf" } } := by
  unfold Spec; decide
