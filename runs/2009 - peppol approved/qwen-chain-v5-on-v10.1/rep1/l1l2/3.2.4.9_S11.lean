import ContractForge
open ContractForge

-- 3.2.4.9/S11: Instead such an attestation can be included into VCD stages 3 and 4 if it is sufficiently described through context specific data in multilingual versions (e.g.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { included := decide ((x.contextData.length > 0 ∧
     x.languages.length > 0 ∧
     x.contextData.all (fun cd => x.attestation.toList.all (fun c => cd.contains c)) = true)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
