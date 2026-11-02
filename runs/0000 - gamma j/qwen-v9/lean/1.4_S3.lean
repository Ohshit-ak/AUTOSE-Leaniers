import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: True · checked: True

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
  success   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.newCode ≠ "" ∧ i.unique
  post := fun i o => (o.success = true ↔
    ∃ c ∈ i.inventory, c.code = i.newCode ∧ c.unique = i.unique) ∧
    (o.success = false → o.inventory = i.inventory)

example : Spec.pre { inventory := [{ code := "A1", unique := true }, { code := "B2", unique := false }], newCode := "A1", unique := true } ∧ Spec.post { inventory := [{ code := "A1", unique := true }, { code := "B2", unique := false }], newCode := "A1", unique := true } { inventory := [{ code := "A1", unique := true }, { code := "B2", unique := false }], success := true } := by
  unfold Spec; decide
