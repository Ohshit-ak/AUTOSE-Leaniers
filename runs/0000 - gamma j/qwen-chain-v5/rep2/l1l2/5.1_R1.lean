import ContractForge
open ContractForge

-- 5.1/R1: Upon the USB being plugged in the system shall be able to be deployed and operational in less than 1 minute.

-- L0 spec

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.elapsedMicros < 60000000 ∧
                     (o.elapsedMicros = 0 → i.elapsedMicros = 0)

example : Spec.pre { elapsedMicros := 0 } ∧ Spec.post { elapsedMicros := 0 } { elapsedMicros := 0 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := if x.elapsedMicros = 0 then 0 else x.elapsedMicros }
