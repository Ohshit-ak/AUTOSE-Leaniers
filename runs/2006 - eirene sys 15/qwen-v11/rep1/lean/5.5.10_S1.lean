import ContractForge
open ContractForge

-- 5.5.10/S1: Facilities shall be provided to support a list of stored names/numbers of up to a minimum of 100 entries.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  names : List String
  deriving DecidableEq, Repr

structure Output where
  names : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.names.length ≥ 100
  post := fun i o => o.names = i.names

example : Spec.pre { names := ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Hannah", "Ivan", "Jack", "Katie", "Liam", "Mia", "Noah", "Olivia", "Peter", "Quinn", "Rachel", "Sam", "Tina", "Uma", "Vince", "Wendy", "Xander", "Yvonne", "Zoe"] } ∧
          Spec.post { names := ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Hannah", "Ivan", "Jack", "Katie", "Liam", "Mia", "Noah", "Olivia", "Peter", "Quinn", "Rachel", "Sam", "Tina", "Uma", "Vince", "Wendy", "Xander", "Yvonne", "Zoe"] }
                    { names := ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Hannah", "Ivan", "Jack", "Katie", "Liam", "Mia", "Noah", "Olivia", "Peter", "Quinn", "Rachel", "Sam", "Tina", "Uma", "Vince", "Wendy", "Xander", "Yvonne", "Zoe"] } := by
  unfold Spec; decide
