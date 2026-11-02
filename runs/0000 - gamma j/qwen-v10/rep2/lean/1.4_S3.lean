import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: False · checked: False

structure ItemCode where
  code : String
  unique : Bool
  deriving DecidableEq, Repr

structure Input where
  inventory : List ItemCode
  newCode   : String
  unique    : Bool
  deriving DecidableEq, Repr

structure Output where
  inventory : List ItemCode
  added     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.newCode ≠ "" ∧ i.unique
  post := fun i o => (o.added = true ↔
    ∃ c ∈ i.inventory, c.code = i.newCode ∧ c.unique = i.unique) ∧
    o.inventory = i.inventory ++ [{ code := i.newCode, unique := i.unique }]

example : Spec.pre { inventory := [{ code := "A1", unique := true }], newCode := "A2", unique := true } ∧ Spec.post { inventory := [{ code := "A1", unique := true }], newCode := "A2", unique := true } { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := true }], added := false } := by
  unfold Spec; decide
