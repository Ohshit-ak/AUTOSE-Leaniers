import ContractForge
open ContractForge

-- 2.14.3/I4: Gemini software developers should maintain accurate change logs showing software modifications as they are applied to the system software.
-- compiles: False · rejects_bad_example: None · checked: False

structure ChangeLogEntry where
  timestamp : Nat
  author    : String
  description : String
  deriving DecidableEq, Repr

structure Input where
  modifications : List String
  timestamp     : Nat
  author        : String
  description   : String
  deriving DecidableEq, Repr

structure Output where
  changeLogs : List ChangeLogEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.modifications ≠ [] ∧ i.timestamp > 0 ∧ i.author ≠ ""
  post := fun i o => o.changeLogs.length = i.modifications.length ∧
                     ∀ i' ∈ i.modifications, ∃ e ∈ o.changeLogs, e.timestamp = i.timestamp ∧
                     e.author = i.author ∧ e.description = i.description

example : Spec.pre { modifications := ["Fix bug", "Add feature"], timestamp := 1623456789, author := "Alice" } ∧
          Spec.post { modifications := ["Fix bug", "Add feature"], timestamp := 1623456789, author := "Alice" }
                    { changeLogs := [{ timestamp := 1623456789, author := "Alice", description := "Fix bug" },
                                     { timestamp := 1623456789, author := "Alice", description := "Add feature" }] } := by
  unfold Spec; decide
