import ContractForge
open ContractForge

-- 3.6.1/S2: The user can create a new group or subgroups into an existing group.

-- L0 spec

structure Group where
  name   : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Input where
  name   : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Output where
  name   : String
  parent : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ ""
  post := fun i o => o.name = i.name ∧
                     (o.parent = i.parent ∨ (o.parent = none ∧ i.parent.isSome))

example : Spec.pre { name := "New Group", parent := none } ∧
          Spec.post { name := "New Group", parent := none }
                    { name := "New Group", parent := none } := by
  unfold Spec; decide

example : Spec.pre { name := "Subgroup", parent := some 123 } ∧
          Spec.post { name := "Subgroup", parent := some 123 }
                    { name := "Subgroup", parent := some 123 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { name := x.name,
    parent := if x.parent.isSome then x.parent else none }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
