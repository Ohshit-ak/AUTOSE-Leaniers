import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.

-- L0 spec

structure Code where
  code : String
  unique : Bool
  deriving DecidableEq, Repr

structure Input where
  inventory : List Code
  purchases : List Code
  deriving DecidableEq, Repr

structure Output where
  inventory : List Code
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.purchases.all (fun c => c.unique)
  post := fun i o => o.inventory.length = i.inventory.length + i.purchases.length ∧
                     ∀ c ∈ i.purchases, c ∈ o.inventory ∧ c.unique

example : Spec.pre { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := false }, { code := "A3", unique := true }, { code := "A4", unique := true }], purchases := [] } ∧ Spec.post { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := false }, { code := "A3", unique := true }, { code := "A4", unique := true }], purchases := [] } { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := false }, { code := "A3", unique := true }, { code := "A4", unique := true }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { inventory := x.inventory ++ x.purchases.map (fun c => c) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
