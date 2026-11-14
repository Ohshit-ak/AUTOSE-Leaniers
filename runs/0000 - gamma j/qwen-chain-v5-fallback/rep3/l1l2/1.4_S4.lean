import ContractForge
open ContractForge

-- 1.4/S4: The minimum total inventory will be 20,000 items.

-- L0 spec

structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 20000 ≤ i.items
  post := fun i o => o.items = i.items ∧
                     (o.items = i.items ↔ 20000 ≤ i.items)

example : Spec.pre { items := 20000 } ∧ Spec.post { items := 20000 } { items := 20000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
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
