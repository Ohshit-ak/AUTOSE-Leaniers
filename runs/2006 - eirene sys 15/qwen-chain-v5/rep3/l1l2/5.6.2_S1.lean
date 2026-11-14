import ContractForge
open ContractForge

-- 5.6.2/S1: As a train approaches the limits of the coverage of the PLMN it is registered with, it will be necessary for it to register with the next PLMN providing coverage.

-- L0 spec

structure Input where
  currentPlmn : String
  nextPlmn    : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  newPlmn    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentPlmn ≠ "" ∧ i.nextPlmn ≠ ""
  post := fun i o => (o.registered = true ↔ i.currentPlmn = i.nextPlmn) ∧
                     (o.registered = false → o.newPlmn = i.nextPlmn)

example : Spec.pre { currentPlmn := "PLMN1", nextPlmn := "PLMN2" } ∧
          Spec.post { currentPlmn := "PLMN1", nextPlmn := "PLMN2" }
                    { registered := false, newPlmn := "PLMN2" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { registered := decide (x.currentPlmn = x.nextPlmn),
    newPlmn := if x.currentPlmn = x.nextPlmn then x.nextPlmn else x.nextPlmn }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
