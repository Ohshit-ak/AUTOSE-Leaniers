import ContractForge
open ContractForge

-- 4.3.1/I2: flexibility to meet the dynamics of the organisational and legal changes and

-- L0 spec

structure Input where
  currentState : String
  changesApplied : Nat
  deriving DecidableEq, Repr

structure Output where
  newState : String
  changesApplied : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentState ≠ ""
  post := fun i o => o.newState = i.currentState ++ " (updated)" ∧
                     o.changesApplied = i.changesApplied + 1

example : Spec.pre { currentState := "Austrian legal framework", changesApplied := 0 } ∧
          Spec.post { currentState := "Austrian legal framework", changesApplied := 0 }
                    { newState := "Austrian legal framework (updated)", changesApplied := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { newState := x.currentState ++ " (updated)",
    changesApplied := x.changesApplied + 1 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
