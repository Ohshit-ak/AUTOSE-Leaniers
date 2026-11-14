import ContractForge
open ContractForge

-- 5.2.2.46: 5.2.2.46 Once the driver has accepted the standard point-to-point call, it shall be connected appropriately, eg if the driver has accepted the call by lifting the handset, then the call shall be routed to the handset. (M) Receive incoming group or broadcast voice call

-- L0 spec

structure Input where
  driverAccepted : Bool
  handsetConnected : Bool
  deriving DecidableEq, Repr

structure Output where
  connected : Bool
  handsetConnected : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverAccepted = true
  post := fun i o => (o.connected = true ↔ i.handsetConnected = true) ∧
                     (o.handsetConnected = i.handsetConnected) ∧
                     (o.connected = true → o.handsetConnected = true)

example : Spec.pre { driverAccepted := true, handsetConnected := false } ∧
          Spec.post { driverAccepted := true, handsetConnected := false }
                    { connected := false, handsetConnected := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { connected := decide (x.handsetConnected = true),
    handsetConnected := x.handsetConnected }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
