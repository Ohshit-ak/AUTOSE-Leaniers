import ContractForge
open ContractForge

-- Design Constraints/I17: Claim Status - Status of the claim is depends information available in the Claim, if any false data or any mandatory information is available in Claim, then the claims status will change, if the value of status is not "Accepted" then the claim will be stored in quarantine area and can able to precede it further from its status. The system should have a provision to capture the reason suppose if the claim status is "Rejection or Quarantine"
-- compiles: True · rejects_bad_example: True · checked: True

structure Claim where
  status     : String
  reason     : Option String
  dataValid  : Bool
  deriving DecidableEq, Repr

structure Input where
  claim      : Claim
  deriving DecidableEq, Repr

structure Output where
  status     : String
  reason     : Option String
  dataValid  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.claim.status ≠ "Accepted"
  post := fun i o => 
    (o.status = "Rejection" ∨ o.status = "Quarantine") ↔
    (i.claim.status = "Rejection" ∨ i.claim.status = "Quarantine") ∧
    (o.status = "Rejection" → o.reason = i.claim.reason) ∧
    (o.status = "Quarantine" → o.reason = i.claim.reason) ∧
    o.status = i.claim.status ∧
    o.dataValid = i.claim.dataValid

example : Spec.pre { claim := { status := "Rejection", reason := some "False data in claim", dataValid := true } } ∧
          Spec.post { claim := { status := "Rejection", reason := some "False data in claim", dataValid := true } }
                    { status := "Rejection", reason := some "False data in claim", dataValid := true } := by
  unfold Spec; decide
