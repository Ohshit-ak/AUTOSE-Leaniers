import ContractForge
open ContractForge

-- 1.1/S1: A VCD will facilitate electronic Tendering by providing cross-border data and document solution that contains the necessary attestations and certificates typically required in eTendering.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { tendered := true, dossier := x.companyDossier, attestations := x.attestations, certificates := x.certificates }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
