import ContractForge
open ContractForge

-- Design Constraints/S5: On capture of any duplicate name the system will give a warning message to have the duplicate name or to change the name.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  names : List String
  deriving DecidableEq, Repr

structure Output where
  warning : Bool
  newNames : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.names.Nodup
  post := fun i o => (o.warning = true ↔ i.names.contains (i.names.filter (fun n => i.names.count n > 1).head)) ∧
                     (o.newNames = i.names.filter (fun n => i.names.count n = 1))

example : Spec.pre { names := ["Alice", "Bob", "Alice"] } ∧
          Spec.post { names := ["Alice", "Bob", "Alice"] }
                     { warning := true, newNames := ["Alice", "Bob", "Alice"] } := by
  unfold Spec; decide
