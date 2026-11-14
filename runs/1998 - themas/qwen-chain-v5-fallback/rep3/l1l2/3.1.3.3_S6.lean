import ContractForge
open ContractForge

-- 3.1.3.3/S6: A temperature setting value that is received from an individual thermostat shall be compared to the valid temperature range values.

-- L0 spec

structure Input where
  setting : Nat
  validMin : Nat
  validMax : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.validMin ≤ i.validMax
  post := fun i o => o.valid = (i.validMin ≤ i.setting ∧ i.setting ≤ i.validMax)

example : Spec.pre { setting := 25, validMin := 20, validMax := 30 } ∧
          Spec.post { setting := 25, validMin := 20, validMax := 30 }
                    { valid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := x.validMin ≤ x.setting ∧ x.setting ≤ x.validMax }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
