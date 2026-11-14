import ContractForge
open ContractForge

-- 4.3.1/S8: This way, the Austrian VCD implementation will ensure full pan-European interoperability and will lead to a dynamic situation regarding the legal rule set and its flexibility to adapt to legal and organisational changes.

-- L0 spec

structure Input where
  legalRules : List String
  deriving DecidableEq, Repr

structure Output where
  legalRules : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.legalRules.Nodup
  post := fun i o => o.legalRules.Nodup ∧
                     (o.legalRules.length = i.legalRules.length) ∧
                     (∃ r ∈ o.legalRules, r ∈ i.legalRules) ∧
                     (∀ r ∈ i.legalRules, r ∈ o.legalRules ∨
                      (∃ r' ∈ o.legalRules, r' ≠ r ∧ r' ≠ r ∧
                       r'.splitOn " " = r.splitOn " "))

example : Spec.pre { legalRules := ["rule1", "rule2", "rule3"] } ∧
          Spec.post { legalRules := ["rule1", "rule2", "rule3"] }
                    { legalRules := ["rule1", "rule2", "rule3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { legalRules := x.legalRules }
