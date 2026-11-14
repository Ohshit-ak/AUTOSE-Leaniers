import ContractForge
open ContractForge

-- Design Constraints/S3#4: The system should generate message with two option "Continue - Yes/No" while the user trying to create a new VSP with an existing name, If the user press Yes the system will allow the user to enter the same, if not the system wont allow the new entry to save.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  vspName : String
  deriving DecidableEq, Repr

structure Output where
  vspName : String
  continue : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vspName ≠ ""
  post := fun i o => (o.message = "Continue - Yes/No" ↔ i.vspName ≠ "") ∧
                     (o.continue = true ↔ o.message = "Continue - Yes") ∧
                     (o.continue = false → o.message = "Continue - No") ∧
                     (o.continue = true → i.vspName = o.vspName)

example : Spec.pre { vspName := "exampleVSP" } ∧
          Spec.post { vspName := "exampleVSP" }
                    { vspName := "exampleVSP", continue := true, message := "Continue - Yes" } := by
  unfold Spec; decide
