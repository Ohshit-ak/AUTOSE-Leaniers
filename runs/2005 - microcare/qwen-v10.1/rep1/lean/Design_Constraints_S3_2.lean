import ContractForge
open ContractForge

-- Design Constraints/S3#2: On capture of any duplicate name the system will give a warning message to have the duplicate name or to change the name.
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
                     (o.newNames.length = i.names.length ∧
                      ∀ n ∈ o.newNames, o.newNames.count n = 1 ∧
                      (o.newNames.contains (i.names.filter (fun n => i.names.count n > 1).head) ↔ o.warning = true))

example : Spec.pre { names := ["apple", "banana", "apple"] } ∧
          Spec.post { names := ["apple", "banana", "apple"] }
                     { warning := true, newNames := ["apple1", "banana", "apple1"] } := by
  unfold Spec; decide
