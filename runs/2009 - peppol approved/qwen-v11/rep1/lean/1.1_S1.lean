import ContractForge
open ContractForge

-- 1.1/S1: A VCD will facilitate electronic Tendering by providing cross-border data and document solution that contains the necessary attestations and certificates typically required in eTendering.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  companyDossier : String
  attestations   : List String
  certificates   : List String
  deriving DecidableEq, Repr

structure Output where
  tendered       : Bool
  dossier        : String
  attestations   : List String
  certificates   : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.companyDossier ≠ "" ∧ i.attestations.Nodup ∧ i.certificates.Nodup
  post := fun i o => o.tendered = true ↔
    (o.dossier = i.companyDossier ∧
     o.attestations = i.attestations ∧
     o.certificates = i.certificates ∧
     o.tendered = true)

example : Spec.pre { companyDossier := "Dossier123", attestations := ["Attest1", "Attest2"], certificates := ["Cert1", "Cert2"] } ∧
          Spec.post { companyDossier := "Dossier123", attestations := ["Attest1", "Attest2"], certificates := ["Cert1", "Cert2"] }
                    { tendered := true, dossier := "Dossier123", attestations := ["Attest1", "Attest2"], certificates := ["Cert1", "Cert2"] } := by
  unfold Spec; decide
