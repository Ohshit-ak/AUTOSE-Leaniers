import ContractForge
open ContractForge

-- 15.2.3/S1: Direct mode equipment shall have a maximum transmit power of 1 Watt.

-- L0 spec

structure Input where
  transmitPower : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ i.transmitPower ≤ 1000

example : Spec.pre { transmitPower := 500 } ∧
          Spec.post { transmitPower := 500 }
                    { valid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide (x.transmitPower ≤ 1000) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
