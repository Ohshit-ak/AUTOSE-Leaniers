import ContractForge
open ContractForge

-- Design Constraints/I17: Claim Status - Status of the claim is depends information available in the Claim, if any false data or any mandatory information is available in Claim, then the claims status will change, if the value of status is not "Accepted" then the claim will be stored in quarantine area and can able to precede it further from its status. The system should have a provision to capture the reason suppose if the claim status is "Rejection or Quarantine"

-- L0 spec

structure Claim where
  status     : String
  reason     : Option String
  mandatoryInfo : String
  data       : String
  deriving DecidableEq, Repr

structure Input where
  claim : Claim
  deriving DecidableEq, Repr

structure Output where
  status     : String
  reason     : Option String
  mandatoryInfo : String
  data       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.claim.status ≠ "Accepted"
  post := fun i o => (o.status = "Rejection" ∨ o.status = "Quarantine") ↔
                     (i.claim.status = "Rejection" ∨ i.claim.status = "Quarantine") ∧
                     (o.status = "Rejection" → o.reason = i.claim.reason) ∧
                     (o.status = "Quarantine" → o.reason = i.claim.reason) ∧
                     o.mandatoryInfo = i.claim.mandatoryInfo ∧
                     o.data = i.claim.data

example : Spec.pre { claim := { status := "Rejection", reason := some "False data", mandatoryInfo := "Info1", data := "Data1" } } ∧
          Spec.post { claim := { status := "Rejection", reason := some "False data", mandatoryInfo := "Info1", data := "Data1" } }
                    { status := "Rejection", reason := some "False data", mandatoryInfo := "Info1", data := "Data1" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { status := if x.claim.status = "Rejection" ∨ x.claim.status = "Quarantine" then x.claim.status else "Rejection",
    reason := if x.claim.status = "Rejection" ∨ x.claim.status = "Quarantine" then x.claim.reason else none,
    mandatoryInfo := x.claim.mandatoryInfo,
    data := x.claim.data }
