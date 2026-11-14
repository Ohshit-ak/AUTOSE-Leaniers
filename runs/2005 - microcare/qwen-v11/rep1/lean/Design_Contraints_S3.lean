import ContractForge
open ContractForge

-- Design Contraints/S3: The system will automatically create Staff Code with Suffix as VSP Code + SC + 3 digit.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  vspCode : String
  deriving DecidableEq, Repr

structure Output where
  staffCode : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vspCode ≠ ""
  post := fun i o => o.staffCode = i.vspCode ++ "SC" ++ (i.vspCode.length + 2).twoDigitNat

example : Spec.pre { vspCode := "1234" } ∧
          Spec.post { vspCode := "1234" }
                    { staffCode := "1234SC12" } := by
  unfold Spec; decide
