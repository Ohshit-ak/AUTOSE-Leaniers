import ContractForge
open ContractForge

-- iv/S3: If yes, then the user should mark that Claim (Treatment Form) status as Rejected and send back to VSP.
-- compiles: True · rejects_bad_example: True · checked: True

structure Claim where
  status : String
  deriving DecidableEq, Repr

structure Input where
  isRejection : Bool
  claim       : Claim
  deriving DecidableEq, Repr

structure Output where
  claim       : Claim
  sendingBack : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isRejection = true
  post := fun i o => (o.claim.status = "Rejected" ↔ i.isRejection) ∧
                     (o.sendingBack = true ↔ i.isRejection)

example : Spec.pre { isRejection := true, claim := { status := "Pending" } } ∧
          Spec.post { isRejection := true, claim := { status := "Pending" } }
                     { claim := { status := "Rejected" }, sendingBack := true } := by
  unfold Spec; decide
