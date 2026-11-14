import ContractForge
open ContractForge

-- 3.21.1/S3: When TAN are created, they appear as typical entries which in the field title contain "TAN" so that KeePass will know it's a TAN.
-- compiles: True · rejects_bad_example: None · checked: True

structure TANEntry where
  title  : String
  content: String
  deriving DecidableEq, Repr

structure Input where
  title  : String
  entries : List TANEntry
  deriving DecidableEq, Repr

structure Output where
  entries : List TANEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => 
    ∀ e ∈ o.entries, 
      (e.title.contains "TAN" = true) ∧
      (e.title = i.title ∨ e.title.contains "TAN" = true)

example : Spec.pre { title := "TAN-123", entries := [{ title := "TAN-123", content := "Some TAN" }, { title := "Not-TAN-123", content := "Not a TAN" }] } ∧ Spec.post { title := "TAN-123", entries := [{ title := "TAN-123", content := "Some TAN" }, { title := "Not-TAN-123", content := "Not a TAN" }] } { entries := [] } := by
  unfold Spec; decide
