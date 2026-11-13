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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  uniquePurchases : List Code
  inventory : List Code
  purchases : List Code
  deriving DecidableEq, Repr

def CheckUniquePurchasesContract : Contract Input Mid where
  pre  := fun i => i.purchases.all (fun c => c.unique)
  post := fun i m => m.uniquePurchases.length = i.purchases.length ∧
                     ∀ c ∈ i.purchases, c ∈ m.uniquePurchases ∧ c.unique

def UpdateInventoryContract : Contract Mid Output where
  pre  := fun m => m.uniquePurchases.length = m.purchases.length
  post := fun m o => o.inventory.length = m.inventory.length + m.purchases.length ∧
                     ∀ c ∈ m.purchases, c ∈ o.inventory ∧ c.unique
