import ContractForge
open ContractForge

-- 4.1.8.1: Unfitted operation shall be possible if ordered by trackside

-- L0 spec

structure Input where
  ordered : Bool
  deriving DecidableEq, Repr

structure Output where
  operationPossible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.ordered
  post := fun i o => o.operationPossible = i.ordered

example : Spec.pre { ordered := true } ∧
          Spec.post { ordered := true } { operationPossible := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { operationPossible := x.ordered }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
