import ContractForge
open ContractForge

-- 1.2/S34: Currently a new version of the Austrian Federal Procurement Act is elaborated which will probably change the necessity for the Economic Operator to just give a declaration on oath concerning the Economic Operator's suitability.

-- L0 spec

structure Input where
  declarationOath : Bool
  evidenceProvided : Bool
  deriving DecidableEq, Repr

structure Output where
  suitabilityDeclared : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.declarationOath
  post := fun i o => (o.suitabilityDeclared = true ↔ i.evidenceProvided) ∧
                     (o.suitabilityDeclared = false ↔ ¬i.declarationOath)

example : Spec.pre { declarationOath := true, evidenceProvided := true } ∧ Spec.post { declarationOath := true, evidenceProvided := true } { suitabilityDeclared := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { suitabilityDeclared := decide (x.evidenceProvided) }
