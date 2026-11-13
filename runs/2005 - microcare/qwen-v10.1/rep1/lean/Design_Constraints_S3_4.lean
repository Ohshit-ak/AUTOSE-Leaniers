import ContractForge
open ContractForge

-- Design Constraints/S3#4: The system should generate message with two option "Continue - Yes/No" while the user trying to create a new VSP with an existing name, If the user press Yes the system will allow the user to enter the same, if not the system wont allow the new entry to save.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  vspName : String
  existingVSPs : List String
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vspName ≠ ""
  post := fun i o => (o.accepted = true ↔
    (o.message = "Continue - Yes/No" ∧ o.message.toList.all Char.isLower = true) ∧
    (o.message = "Continue - Yes" → i.existingVSPs.contains i.vspName) ∧
    (o.message = "Continue - No" → ¬i.existingVSPs.contains i.vspName))

example : Spec.pre { vspName := "exampleVSP", existingVSPs := ["testVSP"] } ∧
          Spec.post { vspName := "exampleVSP", existingVSPs := ["testVSP"] }
                    { accepted := false, message := "Continue - No" } := by
  unfold Spec; decide
