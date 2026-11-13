import ContractForge
open ContractForge

-- 3.10.1/S4: He can fill in fields like: group where the entry will be added, title, user name, password, repeat password, URL, notes, expiration date and attachment file.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  group       : String
  title       : String
  username    : String
  password    : String
  repeatPassword : String
  url         : String
  notes       : String
  expirationDate : String
  attachmentFile : Option String
  deriving DecidableEq, Repr

structure Output where
  group       : String
  title       : String
  username    : String
  password    : String
  url         : String
  notes       : String
  expirationDate : String
  attachmentFile : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.group ≠ "" ∧ i.title ≠ "" ∧ i.username ≠ "" ∧
                 i.password = i.repeatPassword ∧ i.url ≠ ""
  post := fun i o => o.group = i.group ∧
                     o.title = i.title ∧
                     o.username = i.username ∧
                     o.password = i.password ∧
                     o.url = i.url ∧
                     o.notes = i.notes ∧
                     o.expirationDate = i.expirationDate ∧
                     o.attachmentFile = i.attachmentFile

example : Spec.pre { group := "General", title := "Test Entry", username := "user123", password := "pass123", repeatPassword := "pass123", url := "http://example.com", notes := "Some notes", expirationDate := "2023-12-31", attachmentFile := some "file.txt" } ∧
          Spec.post { group := "General", title := "Test Entry", username := "user123", password := "pass123", url := "http://example.com", notes := "Some notes", expirationDate := "2023-12-31", attachmentFile := some "file.txt" }
                    { group := "General", title := "Test Entry", username := "user123", password := "pass123", url := "http://example.com", notes := "Some notes", expirationDate := "2023-12-31", attachmentFile := some "file.txt" } := by
  unfold Spec; decide
