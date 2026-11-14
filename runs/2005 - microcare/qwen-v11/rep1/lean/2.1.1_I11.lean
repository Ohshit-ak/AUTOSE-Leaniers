import ContractForge
open ContractForge

-- 2.1.1/I11: The quarantined forms will be sent back to the VSP for verification, if the VSP returns the claim with satisfactory details, the claims will be entered on to the system, in the following month's batch.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  claims : List String
  batch  : Nat
  deriving DecidableEq, Repr

structure Output where
  processedClaims : List String
  newBatch        : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.claims.Nodup
  post := fun i o => (o.processedClaims.length ≤ i.claims.length) ∧
                     (o.newBatch = i.batch + 1) ∧
                     (o.processedClaims.length > 0 →
                      ∃ c ∈ o.processedClaims, ∃ vspClaim ∈ i.claims, vspClaim = c) ∧
                     (o.processedClaims.length = 0 →
                      ∀ c ∈ i.claims, o.processedClaims.contains c → False)

example : Spec.pre { claims := ["A123", "B456"], batch := 1 } ∧
          Spec.post { claims := ["A123", "B456"], batch := 1 }
                    { processedClaims := ["A123"], newBatch := 2 } := by
  unfold Spec; decide
