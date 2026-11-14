import ContractForge
open ContractForge

-- 3.11.1/S5: Then the user can change the group, title, user name, password, URL, notes, expiration date and attachment file.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  group    : String
  title    : String
  username : String
  password : String
  url      : String
  notes    : String
  expirationDate : String
  attachmentFile : Option String
  deriving DecidableEq, Repr

structure Output where
  group    : String
  title    : String
  username : String
  password : String
  url      : String
  notes    : String
  expirationDate : String
  attachmentFile : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o =>
    i.group    = o.group    ∧
    i.title    = o.title    ∧
    i.username = o.username ∧
    i.password = o.password ∧
    i.url      = o.url      ∧
    i.notes    = o.notes    ∧
    i.expirationDate = o.expirationDate ∧
    i.attachmentFile = o.attachmentFile

example : Spec.pre { group := "G1", title := "T1", username := "u1", password := "p1", url := "http://url1", notes := "notes1", expirationDate := "2023-12-31", attachmentFile := some "file1.txt" } ∧
          Spec.post { group := "G1", title := "T1", username := "u1", password := "p1", url := "http://url1", notes := "notes1", expirationDate := "2023-12-31", attachmentFile := some "file1.txt" }
                    { group := "G1", title := "T1", username := "u1", password := "p1", url := "http://url1", notes := "notes1", expirationDate := "2023-12-31", attachmentFile := some "file1.txt" } := by
  unfold Spec; decide
