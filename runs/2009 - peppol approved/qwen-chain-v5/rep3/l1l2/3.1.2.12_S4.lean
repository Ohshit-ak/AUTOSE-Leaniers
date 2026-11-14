import ContractForge
open ContractForge

-- 3.1.2.12/S4: Requirement An economic operator MUST be able to act as an issuing body for candidate statements or other evidence that cannot be directly or electronically retrieved by the VCD system.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { issuedStatements := x.candidateStatements }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
