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
  visualIndication : Bool
  audibleIndication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networkChange = true
  post := fun i o => (o.visualIndication = true ↔ i.networkChange = true) ∧
                     (o.audibleIndication = true ↔ i.networkChange = true)

example : Spec.pre { networkChange := true, visualIndication := true, audibleIndication := true } ∧
          Spec.post { networkChange := true, visualIndication := true, audibleIndication := true }
                    { visualIndication := true, audibleIndication := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { visualIndication := decide (x.networkChange = true),
    audibleIndication := decide (x.networkChange = true) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
