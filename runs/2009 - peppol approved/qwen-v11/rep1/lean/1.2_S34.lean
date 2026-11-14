import ContractForge
open ContractForge

-- 1.2/S34: Currently a new version of the Austrian Federal Procurement Act is elaborated which will probably change the necessity for the Economic Operator to just give a declaration on oath concerning the Economic Operator's suitability.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  declarationOath : Bool
  deriving DecidableEq, Repr

structure Output where
  suitabilityDeclared : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.declarationOath
  post := fun i o => (o.suitabilityDeclared = true ↔ i.declarationOath) ∧
                     (o.suitabilityDeclared = false → o.suitabilityDeclared = false)

example : Spec.pre { declarationOath := true } ∧ Spec.post { declarationOath := true } { suitabilityDeclared := true } := by
  unfold Spec; decide
