import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: False · rejects_bad_example: None · checked: False

structure InventoryItem where
  code : String
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  codes : List String
  quantities : List Nat
  inventory : List InventoryItem
  deriving DecidableEq, Repr

structure Output where
  inventory : List InventoryItem
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.codes.Nodup ∧ i.quantities.length = i.codes.length
  post := fun i o => o.inventory.length = i.inventory.length + i.codes.length ∧
                     ∀ i' ∈ o.inventory, ∃ c ∈ i.codes, ∃ q ∈ i.quantities, i'.code = c ∧
                     i'.quantity = q ∧
                     ∃ j ∈ i.inventory, j.code = c → j.quantity + q = i'.quantity

example : Spec.pre { codes := ["A1", "B2"], quantities := [5, 3] } ∧
          Spec.post { codes := ["A1", "B2"], quantities := [5, 3] }
                    { inventory := [{ code := "A1", quantity := 5 }, { code := "B2", quantity := 3 },
                                    { code := "A1", quantity := 5 }, { code := "B2", quantity := 3 }] } := by
  unfold Spec; decide
