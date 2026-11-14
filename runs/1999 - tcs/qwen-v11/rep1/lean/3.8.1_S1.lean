import ContractForge
open ContractForge

-- 3.8.1/S1: Using risk assessment procedures defined in DoD 5200.28(D), a risk index and the minimum security requirements for TCS shall be determined. [SSS363] The inputs to this procedure are the clearance or authorization of the TCS users and the sensitivities of the data that the TCS processes, stores or transfers.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  clearance : String
  sensitivities : List String
  deriving DecidableEq, Repr

structure Output where
  riskIndex : Nat
  securityRequirements : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.clearance ≠ "" ∧ i.sensitivities.Nodup
  post := fun i o => o.riskIndex = 1 + i.sensitivities.length ∧
                     o.securityRequirements.length = 3 ∧
                     (∀ req ∈ o.securityRequirements, req = "Requirement1" ∨ req = "Requirement2" ∨ req = "Requirement3")

example : Spec.pre { clearance := "Top Secret", sensitivities := ["Confidential", "Secret", "Top Secret"] } ∧ Spec.post { clearance := "Top Secret", sensitivities := ["Confidential", "Secret", "Top Secret"] } { riskIndex := 4, securityRequirements := ["Requirement1", "Requirement2", "Requirement3"] } := by
  unfold Spec; decide
