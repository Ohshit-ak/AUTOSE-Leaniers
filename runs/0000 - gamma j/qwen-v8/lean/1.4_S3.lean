import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: None · checked: True

structure ItemCode where
  code : String
  deriving DecidableEq, Repr

structure Input where
  uniqueCodes : List ItemCode
  inventorySize : Nat
  deriving DecidableEq, Repr

structure Output where
  inventorySize : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.uniqueCodes.Nodup
  post := fun i o => o.inventorySize = i.inventorySize + i.uniqueCodes.length

example : Spec.pre { uniqueCodes := [{ code := "A1" }, { code := "B2" }],
                     inventorySize := 10 } ∧
          Spec.post { uniqueCodes := [{ code := "A1" }, { code := "B2" }],
                      inventorySize := 10 }
                    { inventorySize := 12 } := by
  unfold Spec; decide
