import ContractForge
open ContractForge

-- 5.2.2/S18: The VCD will be dependent on a number of services that rely on manual and semi-automated input.

-- L0 spec

structure Input where
  manualInput : Nat
  semiAutomatedInput : Nat
  deriving DecidableEq, Repr

structure Output where
  dependentServices : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.manualInput + i.semiAutomatedInput
  post := fun i o => o.dependentServices = i.manualInput + i.semiAutomatedInput

example : Spec.pre { manualInput := 2, semiAutomatedInput := 3 } ∧
          Spec.post { manualInput := 2, semiAutomatedInput := 3 }
                    { dependentServices := 5 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { dependentServices := x.manualInput + x.semiAutomatedInput }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
