import ContractForge
open ContractForge

-- 4/usability/R8: Minimizing navigation effort: The number of navigation steps needed to reach a certain piece of content should be minimized as long as different mental models, navigation strategies and tasks of the user are taken into account.

-- L0 spec

structure Input where
  navigationSteps : Nat
  deriving DecidableEq, Repr

structure Output where
  navigationSteps : Nat
  contentReached  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.navigationSteps
  post := fun i o => o.contentReached = true ∧
                     o.navigationSteps = i.navigationSteps

example : Spec.pre { navigationSteps := 3 } ∧
          Spec.post { navigationSteps := 3 }
                    { contentReached := true, navigationSteps := 3 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { navigationSteps := x.navigationSteps,
    contentReached := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
