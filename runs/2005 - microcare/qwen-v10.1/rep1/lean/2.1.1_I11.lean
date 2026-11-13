import ContractForge
open ContractForge

-- 2.1.1/I11: The quarantined forms will be sent back to the VSP for verification, if the VSP returns the claim with satisfactory details, the claims will be entered on to the system, in the following month's batch.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  claims : List String
  deriving DecidableEq, Repr

structure Output where
  claims : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.claims.Nodup
  post := fun i o => o.claims = i.claims ∧
                     (o.claims.length = i.claims.length →
                      ∃ next_month : Nat, next_month = i.claims.length + 1 ∧
                      ∀ claim ∈ o.claims, claim ∈ i.claims)

example : Spec.pre { claims := ["claim1", "claim2"] } ∧
          Spec.post { claims := ["claim1", "claim2"] }
                    { claims := ["claim1", "claim2"] } := by
  unfold Spec; decide
