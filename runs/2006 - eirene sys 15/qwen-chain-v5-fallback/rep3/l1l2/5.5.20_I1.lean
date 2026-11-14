import ContractForge
open ContractForge

-- 5.5.20/I1: an incoming call is received whilst the Cab radio is in an on-going call; (M)

-- L0 spec

structure Input where
  onGoingCall : Bool
  incomingCall : Bool
  deriving DecidableEq, Repr

structure Output where
  onGoingCall : Bool
  incomingCall : Bool
  handling : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.onGoingCall = true ∧ i.incomingCall = true
  post := fun i o => (o.onGoingCall = i.onGoingCall ∧
                      o.incomingCall = i.incomingCall ∧
                      o.handling = true)

example : Spec.pre { onGoingCall := true, incomingCall := true } ∧
          Spec.post { onGoingCall := true, incomingCall := true }
                    { onGoingCall := true, incomingCall := true, handling := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { onGoingCall := x.onGoingCall,
    incomingCall := x.incomingCall,
    handling := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
