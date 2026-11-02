import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: None · checked: True

structure Code where
  value : Nat
  deriving DecidableEq, Repr

structure Inventory where
  items : List Code
  deriving DecidableEq, Repr

structure Input where
  codes : List Code
  inventory : Inventory
  deriving DecidableEq, Repr

structure Output where
  inventory : Inventory
  newCodes : List Code
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.codes.Nodup
  post := fun i o => o.inventory.items = i.inventory.items ++ i.codes ∧
                     o.newCodes = i.codes

example : Spec.pre { codes := [{ value := 1 }, { value := 2 }], inventory := { items := [] } } ∧
          Spec.post { codes := [{ value := 1 }, { value := 2 }], inventory := { items := [] } }
                     { inventory := { items := [{ value := 1 }, { value := 2 }] }, newCodes := [{ value := 1 }, { value := 2 }] } := by
  unfold Spec; decide
