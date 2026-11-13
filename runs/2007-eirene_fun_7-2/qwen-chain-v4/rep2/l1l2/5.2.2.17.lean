import ContractForge
open ContractForge

-- 5.2.2.17: 5.2.2.17 If the system is not able to connect the call, an audible and visual indication shall be provided to the driver. (M) Send Railway emergency call

-- L0 spec

structure Input where
  systemConnected : Bool
  deriving DecidableEq, Repr

structure Output where
  audibleIndication : Bool
  visualIndication  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.systemConnected = false
  post := fun i o => (o.audibleIndication = true ∧ o.visualIndication = true) ↔ i.systemConnected = false

example : Spec.pre { systemConnected := false } ∧
          Spec.post { systemConnected := false }
                    { audibleIndication := true, visualIndication := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { audibleIndication := x.systemConnected = false, visualIndication := x.systemConnected = false }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
