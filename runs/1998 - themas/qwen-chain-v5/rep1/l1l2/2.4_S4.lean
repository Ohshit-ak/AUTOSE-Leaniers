import ContractForge
open ContractForge

-- 2.4/S4: When a signal is sent to a heating or cooling unit, no signal shall be available to allow the THEMAS system to determine if the signal sent to the unit was realized by the unit.

-- L0 spec

structure Input where
  signalSent : Bool
  signalRealized : Bool
  deriving DecidableEq, Repr

structure Output where
  signalSent : Bool
  signalRealized : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signalSent
  post := fun i o => o.signalSent = i.signalSent ∧
                     o.signalRealized = false ∧
                     (o.signalSent = true ↔ i.signalSent = true)

example : Spec.pre { signalSent := true, signalRealized := false } ∧
          Spec.post { signalSent := true, signalRealized := false }
                    { signalSent := true, signalRealized := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { signalSent := x.signalSent,
    signalRealized := false }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
