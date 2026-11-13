import ContractForge
open ContractForge

-- 3.2.4.9/S11: Instead such an attestation can be included into VCD stages 3 and 4 if it is sufficiently described through context specific data in multilingual versions (e.g.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  attestation : String
  contextData : List String
  languages   : List String
  deriving DecidableEq, Repr

structure Output where
  included : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.attestation ≠ "" ∧ i.contextData.Nodup ∧ i.languages.Nodup
  post := fun i o => (o.included = true ↔
    (i.contextData.length > 0 ∧
     i.languages.length > 0 ∧
     i.contextData.all (fun cd => i.attestation.toList.all (fun c => cd.contains c)) = true))

example : Spec.pre { attestation := "This is an attestation", contextData := [], languages := ["en", "fr"] } ∧ Spec.post { attestation := "This is an attestation", contextData := [], languages := ["en", "fr"] } { included := false } := by
  unfold Spec; decide
