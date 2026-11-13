import ContractForge
open ContractForge

-- 3.1.2.12/S4: Requirement An economic operator MUST be able to act as an issuing body for candidate statements or other evidence that cannot be directly or electronically retrieved by the VCD system.
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  economicOperatorId : Nat
  candidateStatements : List String
  deriving DecidableEq, Repr

structure Output where
  issuedStatements : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.economicOperatorId ≠ 0
  post := fun i o => o.issuedStatements = i.candidateStatements

example : Spec.pre { economicOperatorId := 1, candidateStatements := ["Statement1", "Statement2"] } ∧
          Spec.post { economicOperatorId := 1, candidateStatements := ["Statement1", "Statement2"] }
                    { issuedStatements := ["Statement1", "Statement2"] } := by
  unfold Spec; decide
