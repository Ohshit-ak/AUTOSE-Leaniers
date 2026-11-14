import ContractForge
open ContractForge

-- 3.6.1/S3: When creating a group/subgroup the user must select a name and then he can add entries into it.
-- compiles: True · rejects_bad_example: True · checked: True

structure Group where
  name   : String
  entries : List String
  deriving DecidableEq, Repr

structure Input where
  name   : String
  entries : List String
  deriving DecidableEq, Repr

structure Output where
  name   : String
  entries : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ ""
  post := fun i o => o.name = i.name ∧
                     (o.entries.length = i.entries.length ∧
                      ∀ j ∈ o.entries, ∃ k ∈ i.entries, j = k)

example : Spec.pre { name := "New Group", entries := ["Entry1", "Entry2"] } ∧
          Spec.post { name := "New Group", entries := ["Entry1", "Entry2"] }
                    { name := "New Group", entries := ["Entry1", "Entry2"] } := by
  unfold Spec; decide
