import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: True · checked: True

structure Code where
  value : Nat
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
  post := fun i o => o.inventory = i.inventory ++ i.purchases

example : Spec.pre { inventory := [{ value := 1 }, { value := 2 }],
                     purchases := [{ value := 3 }, { value := 4 }] } ∧
          Spec.post { inventory := [{ value := 1 }, { value := 2 }],
                      purchases := [{ value := 3 }, { value := 4 }] }
                    { inventory := [{ value := 1 }, { value := 2 }, { value := 3 }, { value := 4 }] } := by
  unfold Spec; decide
