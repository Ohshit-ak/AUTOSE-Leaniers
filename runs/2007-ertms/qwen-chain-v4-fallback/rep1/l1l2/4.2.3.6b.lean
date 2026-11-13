import ContractForge
open ContractForge

-- 4.2.3.6b: The train shall, as a minimum, be supervised to a ceiling speed; the supervised speed shall not be shown on the DMI unless selected by the driver.

-- L0 spec

structure Input where
  ceilingSpeed : Nat
  supervisedSpeed : Nat
  deriving DecidableEq, Repr

structure Output where
  dmiDisplay : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.ceilingSpeed
  post := fun i o => (o.dmiDisplay = true ↔ i.supervisedSpeed = i.ceilingSpeed) ∧
                     (o.dmiDisplay = false → i.supervisedSpeed ≠ i.ceilingSpeed)

example : Spec.pre { ceilingSpeed := 60, supervisedSpeed := 50 } ∧
          Spec.post { ceilingSpeed := 60, supervisedSpeed := 50 }
                    { dmiDisplay := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { dmiDisplay := decide (x.supervisedSpeed = x.ceilingSpeed) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
