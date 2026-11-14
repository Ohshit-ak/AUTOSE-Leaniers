import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.

-- L0 spec

structure Code where
  value : Nat
  deriving DecidableEq, Repr

structure Input where
  inventory : List Code
  purchases : List Code
  deriving DecidableEq, Repr

structure Output where
  inventory : List Code
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.purchases.Nodup
  post := fun i o => o.inventory = i.inventory ++ i.purchases

example : Spec.pre { inventory := [{ value := 1 }, { value := 2 }],
                     purchases := [{ value := 3 }, { value := 4 }] } ∧
          Spec.post { inventory := [{ value := 1 }, { value := 2 }],
                      purchases := [{ value := 3 }, { value := 4 }] }
                    { inventory := [{ value := 1 }, { value := 2 }, { value := 3 }, { value := 4 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { inventory := x.inventory ++ x.purchases }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
