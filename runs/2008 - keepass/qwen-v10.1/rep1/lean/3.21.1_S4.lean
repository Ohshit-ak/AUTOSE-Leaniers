import ContractForge
open ContractForge

-- 3.21.1/S4: In TAN entries, user cannot change the title, user name or URL but notes can be added.
-- compiles: True · rejects_bad_example: True · checked: True

structure TANEntry where
  title   : String
  username: String
  url     : String
  notes   : List String
  deriving DecidableEq, Repr

structure Input where
  entry : TANEntry
  newNotes : List String
  deriving DecidableEq, Repr

structure Output where
  entry : TANEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o =>
    o.entry.title   = i.entry.title   ∧
    o.entry.username= i.entry.username∧
    o.entry.url     = i.entry.url     ∧
    o.entry.notes   = i.entry.notes ++ i.newNotes

example : Spec.pre { entry := { title := "Example", username := "user", url := "http://example.com", notes := ["note1", "note2"] }, newNotes := [] } ∧ Spec.post { entry := { title := "Example", username := "user", url := "http://example.com", notes := ["note1", "note2"] }, newNotes := [] } { entry := { title := "Example", username := "user", url := "http://example.com", notes := ["note1", "note2"] } } := by
  unfold Spec; decide
