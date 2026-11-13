import ContractForge
open ContractForge

-- 5.2.3.25ix: 5.2.3.25ix Automatic network selection is not suitable for use in areas where there is a risk that the Cab radio will change to a foreign network unpredictably. (I)

-- L0 spec

structure Input where
  cabNetwork : String
  safeAreas  : List String
  deriving DecidableEq, Repr

structure Output where
  selectedNetwork : String
  failedAttempts  : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabNetwork ≠ "" ∧ i.safeAreas.Nodup
  post := fun i o =>
    (o.failedAttempts = 0 ↔
      ∃ area ∈ i.safeAreas, area = i.cabNetwork) ∧
    (o.failedAttempts > 0 →
      o.selectedNetwork = i.cabNetwork ∧
      i.safeAreas.contains o.selectedNetwork = false)

example : Spec.pre { cabNetwork := "A1", safeAreas := ["A1", "A2"] } ∧
          Spec.post { cabNetwork := "A1", safeAreas := ["A1", "A2"] }
                    { selectedNetwork := "A1", failedAttempts := 0 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { selectedNetwork := if x.safeAreas.contains x.cabNetwork then x.cabNetwork else x.cabNetwork,
    failedAttempts := if x.safeAreas.contains x.cabNetwork then 0 else 1 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
