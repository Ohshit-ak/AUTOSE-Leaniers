import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- compiles: True · rejects_bad_example: None · checked: True

structure ItemCode where
  code : String
  unique : Bool
  deriving DecidableEq, Repr

structure Input where
  codes : List ItemCode
  deriving DecidableEq, Repr

structure Output where
  purchasedCode : ItemCode
  expanded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.codes.length > 0
  post := fun i o => o.expanded ↔
    ∃ c ∈ i.codes, c.unique = true ∧ o.purchasedCode = c

example : Spec.pre { codes := [{ code := "A1", unique := true },
                                { code := "B2", unique := false }] } ∧
          Spec.post { codes := [{ code := "A1", unique := true },
                                 { code := "B2", unique := false }] }
                    { purchasedCode := { code := "A1", unique := true }, expanded := true } := by
  unfold Spec; decide
