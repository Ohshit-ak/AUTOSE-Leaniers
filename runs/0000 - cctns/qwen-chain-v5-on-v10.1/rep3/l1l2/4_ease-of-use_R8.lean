import ContractForge
open ContractForge

-- 4/ease-of-use/R8: Frequently-executed System transactions must be designed so that they can be completed with a small number of interactions (e.g. mouse clicks).

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  interactions : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.interactions ≤ 3

example : Spec.pre {} ∧ Spec.post {} { interactions := 2 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { interactions := 3 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
