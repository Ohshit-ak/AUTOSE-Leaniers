import ContractForge
open ContractForge

-- 3.1.2.12/S4: Requirement An economic operator MUST be able to act as an issuing body for candidate statements or other evidence that cannot be directly or electronically retrieved by the VCD system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  economicOperatorId : Nat
  candidateStatements : List String
  deriving DecidableEq, Repr

structure Output where
  issuedStatements : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.economicOperatorId ≠ 0
  post := fun i o => o.issuedStatements.length = i.candidateStatements.length ∧
                     ∀ s ∈ o.issuedStatements, ∃ cs ∈ i.candidateStatements, cs = s ∧
                     (o.issuedStatements = i.candidateStatements →
                      o.issuedStatements.length = i.candidateStatements.length)

example : Spec.pre { economicOperatorId := 1, candidateStatements := ["stmt1", "stmt2"] } ∧
          Spec.post { economicOperatorId := 1, candidateStatements := ["stmt1", "stmt2"] }
                    { issuedStatements := ["stmt1", "stmt2"] } := by
  unfold Spec; decide
