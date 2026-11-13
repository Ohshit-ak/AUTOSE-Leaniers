import ContractForge
open ContractForge

-- 1.4/S2: The initial inventory will be 100 items.

-- L0 spec

structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items = 100
  post := fun i o => o.items = i.items

example : Spec.pre { items := 100 } ∧ Spec.post { items := 100 } { items := 100 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { items := x.items }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
