import ContractForge
open ContractForge

-- 2.1.1.2.1.9/S1: The system shall perform a search on the [system name] user display name and user name columns in the user tables to find the user and verify the user's existence.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  displayName : String
  userName    : String
  userTables  : List String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.displayName ≠ "" ∨ i.userName ≠ ""
  post := fun i o => o.exists_ = true ↔
    (i.userTables.any (fun table => table.contains i.displayName) ∨
     i.userTables.any (fun table => table.contains i.userName))

example : Spec.pre { displayName := "John Doe", userName := "johndoe", userTables := [] } ∧ Spec.post { displayName := "John Doe", userName := "johndoe", userTables := [] } { exists_ := false } := by
  unfold Spec; decide
