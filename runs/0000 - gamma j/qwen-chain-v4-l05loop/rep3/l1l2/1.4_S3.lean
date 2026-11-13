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
  pre  := fun i => i.purchases.Nodup
  post := fun i o => o.inventory.length = i.inventory.length + i.purchases.length ∧
                     ∀ c ∈ i.purchases, c.unique = true ∧
                     ∀ c ∈ o.inventory, ∃ p ∈ i.purchases, c.code = p.code

example : Spec.pre { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := true }, { code := "A3", unique := true }, { code := "A4", unique := true }], purchases := [] } ∧ Spec.post { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := true }, { code := "A3", unique := true }, { code := "A4", unique := true }], purchases := [] } { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := true }, { code := "A3", unique := true }, { code := "A4", unique := true }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { inventory := x.inventory ++ x.purchases.map (fun p => { code := p.code, unique := p.unique }) }
