-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- checked: False

structure Input where
  ownerCode : String
  amount    : Nat
  deriving DecidableEq, Repr

structure Output where
  success   : Bool
  newCodes  : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.ownerCode.length = 6 ∧ i.ownerCode.all (·.isUpper) ∧ 0 < i.amount
  post := fun i o => o.success = true ∧
                     o.newCodes.length = i.amount ∧
                     o.newCodes.all (·.length = 6) ∧
                     o.newCodes.all (·.all (·.isUpper)) ∧
                     o.newCodes.nodupDecidable.val ∧
                     o.newCodes.all (· ∉ i.ownerCode)

example : Spec.pre { ownerCode := "ABCDEF", amount := 3 } ∧
          Spec.post { ownerCode := "ABCDEF", amount := 3 }
                     { success := true, newCodes := ["GHIJKL", "MNOPQR", "STUVWX"] } := by
  unfold Spec; decide
