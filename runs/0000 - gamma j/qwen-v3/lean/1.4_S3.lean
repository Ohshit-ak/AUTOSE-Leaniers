-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- checked: False

structure Input where
  code : String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  newCode : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.code.length = 6 ∧ i.code.all (·.isDigit) = true
  post := fun i o => o.success = true ↔ o.newCode.isSome ∧
                     o.newCode.getD none = i.code

example : Spec.pre { code := "123456" } ∧
          Spec.post { code := "123456" } { success := true, newCode := some "123456" } := by
  unfold Spec; decide
