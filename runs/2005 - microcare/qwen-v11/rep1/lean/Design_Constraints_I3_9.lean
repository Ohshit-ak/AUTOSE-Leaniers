import ContractForge
open ContractForge

-- Design Constraints/I3#9: The system should save the user information only if the Password and Verify password values are equal
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  password  : String
  verifyPassword : String
  deriving DecidableEq, Repr

structure Output where
  saved : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.saved = true ↔ i.password = i.verifyPassword

example : Spec.pre { password := "test123", verifyPassword := "test123" } ∧
          Spec.post { password := "test123", verifyPassword := "test123" }
                    { saved := true } := by
  unfold Spec; decide
