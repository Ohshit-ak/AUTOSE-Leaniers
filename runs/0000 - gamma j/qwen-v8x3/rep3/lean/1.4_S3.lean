import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  codes : List String
  inventorySize : Nat
  deriving DecidableEq, Repr

structure Output where
  inventorySize : Nat
  purchasedCodes : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.codes.Nodup
  post := fun i o => o.inventorySize = i.inventorySize + o.purchasedCodes.length ∧
                     o.purchasedCodes.Nodup ∧
                     ∀ c ∈ o.purchasedCodes, ∃ c' ∈ i.codes, c = c'

example : Spec.pre { codes := ["A1", "A2", "A3"], inventorySize := 10 } ∧ Spec.post { codes := ["A1", "A2", "A3"], inventorySize := 10 } { inventorySize := 10, purchasedCodes := [] } := by
  unfold Spec; decide
