import ContractForge
open ContractForge

-- 5.2.3.25iii: 5.2.3.25iii If directed network selection is implemented and voice calls are ongoing at the time when the external device attempts to trigger a network change, an audible and visual indication shall be given to the driver and network change shall be deferred until the call is terminated or until coverage of the current network is lost. (M)

-- L0 spec

structure Input where
  directedNetworkSelection : Bool
  ongoingCalls : Nat
  deriving DecidableEq, Repr

structure Output where
  deferred : Bool
  indication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.directedNetworkSelection = true ∧ i.ongoingCalls > 0
  post := fun i o => (o.deferred = true ↔ i.directedNetworkSelection = true ∧ i.ongoingCalls > 0) ∧
                     (o.indication = true ↔ i.directedNetworkSelection = true ∧ i.ongoingCalls > 0) ∧
                     (o.deferred = true → o.indication = true) ∧
                     (o.deferred = false → (i.ongoingCalls = 0 ∨ i.directedNetworkSelection = false))

example : Spec.pre { directedNetworkSelection := true, ongoingCalls := 5 } ∧
          Spec.post { directedNetworkSelection := true, ongoingCalls := 5 }
                    { deferred := true, indication := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { deferred := decide (x.directedNetworkSelection = true ∧ x.ongoingCalls > 0),
    indication := decide (x.directedNetworkSelection = true ∧ x.ongoingCalls > 0) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
