import ContractForge
open ContractForge

-- 7.2.3.9: 7.2.3.9 When the mobile changes network automatically, a visual and audible indication shall be given. (M)

-- L0 spec

structure Input where
  networkChange : Bool
  visualIndication : Bool
  audibleIndication : Bool
  deriving DecidableEq, Repr

structure Output where
  networkChange : Bool
  visualIndication : Bool
  audibleIndication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networkChange = true
  post := fun i o => (o.visualIndication = true ∧ o.audibleIndication = true) ↔ i.networkChange = true

example : Spec.pre { networkChange := true, visualIndication := false, audibleIndication := false } ∧
          Spec.post { networkChange := true, visualIndication := false, audibleIndication := false }
                    { networkChange := true, visualIndication := true, audibleIndication := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { networkChange := x.networkChange, visualIndication := true, audibleIndication := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
