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

-- L1 architect (success=False)

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

-- Decompose the spec into two components

def InventoryRefinementContract : Contract Input Input where
  pre  := fun i => i.purchases.all (fun c => c.unique)
  post := fun i i' => i'.inventory.length = i.inventory.length + i.purchases.length ∧
                      ∀ c ∈ i.purchases, c ∈ i'.inventory ∧ c.unique

def FinalOutputContract : Contract Input Output where
  pre  := fun i => i.purchases.all (fun c => c.unique)
  post := fun i o => o.inventory.length = i.inventory.length + i.purchases.length ∧
                     ∀ c ∈ i.purchases, c ∈ o.inventory ∧ c.unique

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1_InventoryRefinementContract : Contract.Compatible (InventoryRefinementContract) Spec :=
  by
    discharge_po

theorem PO1_FinalOutputContract : Contract.Compatible FinalOutputContract (InventoryRefinementContract) :=
  by
    discharge_po

-- Prove PO2: the composition refines the spec

theorem PO2_CompositionRefinesSpec : Contract.Refines (Spec.seq (InventoryRefinementContract).seq FinalOutputContract) Spec :=
  by
    discharge_po

-- Example to check the contracts
example : Spec.pre { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := false }, { code := "A3", unique := true }, { code := "A4", unique := true }], purchases := [] } ∧
          (Spec.seq (InventoryRefinementContract).seq FinalOutputContract).post { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := false }, { code := "A3", unique := true }, { code := "A4", unique := true }], purchases := [] } { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := false }, { code := "A3", unique := true }, { code := "A4", unique := true }] } := by
  unfold Spec; unfold InventoryRefinementContract; unfold FinalOutputContract; decide