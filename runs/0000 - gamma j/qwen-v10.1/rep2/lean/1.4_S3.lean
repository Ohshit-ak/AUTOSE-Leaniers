import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: False · checked: False

structure ProductCode where
  code : String
  unique : Bool
  deriving DecidableEq, Repr

structure Input where
  productCodes : List ProductCode
  inventorySize : Nat
  deriving DecidableEq, Repr

structure Output where
  inventorySize : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productCodes.Nodup ∧
                 i.productCodes.all (fun p => p.unique = true)
  post := fun i o => o.inventorySize = i.inventorySize + 1 ∧
                     ∃ p ∈ i.productCodes, o.inventorySize = i.inventorySize + 1 ∧
                     (o.inventorySize = i.inventorySize + 1 →
                      ∃ p ∈ i.productCodes, p.unique = true)

example : Spec.pre { productCodes := [{ code := "A1", unique := true },
                                       { code := "A2", unique := true }],
                     inventorySize := 10 } ∧
          Spec.post { productCodes := [{ code := "A1", unique := true },
                                        { code := "A2", unique := true }],
                      inventorySize := 10 }
                    { inventorySize := 11 } := by
  unfold Spec; decide
