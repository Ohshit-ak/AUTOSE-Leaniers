import ContractForge
open ContractForge

-- 3.1.1.3.1/S1: There shall be a maximum number of heating or cooling u nits that can be on at any given time.

-- L0 spec

structure Input where
  maxUnits : Nat
  currentUnits : Nat
  deriving DecidableEq, Repr

structure Output where
  currentUnits : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.maxUnits > 0 ∧ i.currentUnits ≤ i.maxUnits
  post := fun i o => o.currentUnits = i.currentUnits ∧ o.currentUnits ≤ i.maxUnits

example : Spec.pre { maxUnits := 5, currentUnits := 3 } ∧
          Spec.post { maxUnits := 5, currentUnits := 3 }
                    { currentUnits := 3 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { currentUnits := x.currentUnits }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
