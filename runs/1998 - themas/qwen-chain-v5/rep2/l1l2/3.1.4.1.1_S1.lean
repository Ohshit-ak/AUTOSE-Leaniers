import ContractForge
open ContractForge

-- 3.1.4.1.1/S1: The THEMAS system shall determine wh en a reported temperature or a changed temperature setting exceeds the limits set by the overtemperature values.

-- L0 spec

structure Input where
  temperature : Nat
  overtempValues : Nat
  deriving DecidableEq, Repr

structure Output where
  status : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.temperature ≤ 1000 ∧ i.overtempValues ≤ 1000
  post := fun i o => o.status = true ↔ i.temperature > i.overtempValues

example : Spec.pre { temperature := 950, overtempValues := 900 } ∧
          Spec.post { temperature := 950, overtempValues := 900 }
                    { status := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { status := decide (x.temperature > x.overtempValues) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
