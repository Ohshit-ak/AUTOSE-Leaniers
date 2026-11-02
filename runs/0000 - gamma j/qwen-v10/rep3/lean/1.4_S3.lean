import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: True · checked: True

structure Code where
  unique : Bool
  deriving DecidableEq, Repr

structure Input where
  inventory : List Code
  count     : Nat
  deriving DecidableEq, Repr

structure Output where
  inventory : List Code
  count     : Nat
  purchased : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.count > 0
  post := fun i o => o.count = i.count ∧
                     o.purchased ≤ i.count ∧
                     o.inventory.length = i.inventory.length + o.purchased ∧
                     ∀ c ∈ o.inventory.drop i.inventory.length, c.unique = true

example : Spec.pre { inventory := [{ unique := true }, { unique := false }], count := 2 } ∧
          Spec.post { inventory := [{ unique := true }, { unique := false }], count := 2 }
                    { inventory := [{ unique := true }, { unique := false }, { unique := true }, { unique := true }], count := 2, purchased := 2 } := by
  unfold Spec; decide
