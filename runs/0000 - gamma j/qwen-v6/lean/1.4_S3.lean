import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  uniqueCodes : List String
  inventorySize : Nat
  deriving DecidableEq, Repr

structure Output where
  inventorySize : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.uniqueCodes.Nodup
  post := fun i o => o.inventorySize = i.inventorySize + i.uniqueCodes.length

example : Spec.pre { uniqueCodes := ["A1", "A2"], inventorySize := 10 } ∧
          Spec.post { uniqueCodes := ["A1", "A2"], inventorySize := 10 }
                    { inventorySize := 12 } := by
  unfold Spec; decide
