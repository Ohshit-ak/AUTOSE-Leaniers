import ContractForge
open ContractForge

-- 3.2.5/S3: Reconfiguration procedures must exist, to change the observing environment.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  environment : String
  changes     : List String
  deriving DecidableEq, Repr

structure Output where
  environment : String
  changes     : List String
  newEnv      : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.environment ≠ "" ∧ i.changes.Nodup
  post := fun i o => o.environment = i.environment ∧
                     o.changes = i.changes ∧
                     o.newEnv ≠ "" ∧
                     (o.newEnv = i.environment ∧ o.newEnv.toList.all (fun c => c.isAlpha) = true)

example : Spec.pre { environment := "lab", changes := ["light", "camera"] } ∧
          Spec.post { environment := "lab", changes := ["light", "camera"],
                      newEnv := "labcamera" }
                    { environment := "lab", changes := ["light", "camera"],
                      newEnv := "labcamera" } := by
  unfold Spec; decide
