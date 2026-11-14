import ContractForge
open ContractForge

-- 4.3.5/S1: If a Railway emergency call set up from an EIRENE radio is unsuccessful, the radio shall automatically re-attempt the call setup until the call setup is successful, a retry timer expires (duration 30 seconds, as specified in the [EIRENE FRS]) or the user abandons the call.

-- L0 spec

structure Input where
  retryTimer : Nat
  succeeded  : Bool
  abandoned  : Bool
  deriving DecidableEq, Repr

structure Output where
  succeeded : Bool
  abandoned : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.retryTimer = 30
  post := fun i o => (o.succeeded = true ↔ o.elapsedMicros ≤ 30000000) ∧
                     (o.abandoned = true → o.elapsedMicros ≤ 30000000) ∧
                     (o.succeeded = false → o.elapsedMicros ≤ i.retryTimer * 1000000)

example : Spec.pre { retryTimer := 30, succeeded := false, abandoned := false } ∧ Spec.post { retryTimer := 30, succeeded := false, abandoned := false } { succeeded := true, abandoned := false, elapsedMicros := 2000000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { succeeded := x.retryTimer * 1000000 ≤ 30000000, abandoned := x.abandoned, elapsedMicros := x.retryTimer * 1000000 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
