import ContractForge
open ContractForge

-- 3.15.1/I3: The third method is to use the system-wide auto-type hot key so that KeePass can search all entries in the database for matching sequences.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  database : List String
  query    : String
  deriving DecidableEq, Repr

structure Output where
  matches : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ m ∈ o.matches, m ∈ i.database ∧ m.toList.any (fun c => i.query.contains c)) ∧
    o.matches.length ≤ i.database.length

example : Spec.pre { database := ["example1", "example2", "example3"], query := "exa" } ∧
          Spec.post { database := ["example1", "example2", "example3"], query := "exa" }
                    { matches := ["example1", "example2"] } := by
  unfold Spec; decide
