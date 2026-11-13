import ContractForge
open ContractForge

-- iv/S3: If yes, then the user should mark that Claim (Treatment Form) status as Rejected and send back to VSP.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  status  : String
  deriving DecidableEq, Repr

structure Output where
  status  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.status = "Yes"
  post := fun i o => o.status = "Rejected" ∧ o.status ≠ i.status

example : Spec.pre { status := "Yes" } ∧
          Spec.post { status := "Yes" } { status := "Rejected" } := by
  unfold Spec; decide
