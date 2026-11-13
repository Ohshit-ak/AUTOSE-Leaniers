import ContractForge
open ContractForge

-- 2.14.3/I4: Gemini software developers should maintain accurate change logs showing software modifications as they are applied to the system software.
-- compiles: True · rejects_bad_example: True · checked: True

structure ChangeLogEntry where
  timestamp : Nat
  author    : String
  description : String
  deriving DecidableEq, Repr

structure Input where
  changes : List ChangeLogEntry
  deriving DecidableEq, Repr

structure Output where
  changes : List ChangeLogEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.changes.Nodup
  post := fun i o => o.changes = i.changes

example : Spec.pre { changes := [{ timestamp := 1, author := "Alice", description := "Initial setup" },
                                  { timestamp := 2, author := "Bob", description := "Feature addition" }] } ∧
          Spec.post { changes := [{ timestamp := 1, author := "Alice", description := "Initial setup" },
                                   { timestamp := 2, author := "Bob", description := "Feature addition" }] }
                    { changes := [{ timestamp := 1, author := "Alice", description := "Initial setup" },
                                  { timestamp := 2, author := "Bob", description := "Feature addition" }] } := by
  unfold Spec; decide
