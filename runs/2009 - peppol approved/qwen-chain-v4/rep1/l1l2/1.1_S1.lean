import ContractForge
open ContractForge

-- 1.1/S1: A VCD will facilitate electronic Tendering by providing cross-border data and document solution that contains the necessary attestations and certificates typically required in eTendering.

-- L0 spec

structure Input where
  companyDossier : List String
  attestations   : List String
  certificates   : List String
  deriving DecidableEq, Repr

structure Output where
  vcd : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.companyDossier.Nodup ∧ i.attestations.Nodup ∧ i.certificates.Nodup
  post := fun i o => o.vcd.length = i.companyDossier.length + i.attestations.length + i.certificates.length ∧
                     ∀ c ∈ i.companyDossier, o.vcd.contains c ∧
                     ∀ a ∈ i.attestations, o.vcd.contains a ∧
                     ∀ l ∈ i.certificates, o.vcd.contains l

example : Spec.pre { companyDossier := ["Name", "Address"], attestations := ["Att1"], certificates := ["Cert1"] } ∧
          Spec.post { companyDossier := ["Name", "Address"], attestations := ["Att1"], certificates := ["Cert1"] }
                    { vcd := ["Name", "Address", "Att1", "Cert1"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { vcd := x.companyDossier ++ x.attestations ++ x.certificates }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
