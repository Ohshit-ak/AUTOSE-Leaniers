import ContractForge
open ContractForge

-- 4.1.3.2a: Transfer to Shunting on driver's selection shall only be possible when stationary.

-- L0 spec

structure Input where
  stationary : Bool
  deriving DecidableEq, Repr

structure Output where
  transferred : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.stationary
  post := fun i o => o.transferred = true ↔ i.stationary

example : Spec.pre { stationary := true } ∧
          Spec.post { stationary := true } { transferred := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { transferred := decide (x.stationary) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
