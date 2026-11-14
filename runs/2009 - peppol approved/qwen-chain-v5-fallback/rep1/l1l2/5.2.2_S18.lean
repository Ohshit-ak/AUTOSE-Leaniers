import ContractForge
open ContractForge

-- 5.2.2/S18: The VCD will be dependent on a number of services that rely on manual and semi-automated input.

-- L0 spec

structure Input where
  manualInput : Bool
  semiAutomatedInput : Bool
  deriving DecidableEq, Repr

structure Output where
  dependentOnServices : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.manualInput ∨ i.semiAutomatedInput
  post := fun i o => o.dependentOnServices = true ∧
                     (o.dependentOnServices = i.manualInput ∨ o.dependentOnServices = i.semiAutomatedInput)

example : Spec.pre { manualInput := true, semiAutomatedInput := false } ∧
          Spec.post { manualInput := true, semiAutomatedInput := false }
                    { dependentOnServices := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { dependentOnServices := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
