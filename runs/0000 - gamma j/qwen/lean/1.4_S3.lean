-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- checked: False

structure Input where
  code : String
  newCode : Option String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  newCode : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.code.length = 6 ∧ i.code.all Char.isAlphanum = true
  post := fun i o => o.success = true ↔
    (i.newCode.isNone → i.newCode = o.newCode) ∧
    (i.newCode.isSome → o.newCode = i.newCode)

example : Spec.pre { code := "A1B2C3", newCode := none } ∧
          Spec.post { code := "A1B2C3", newCode := none }
                    { success := true, newCode := none } := by
  unfold Spec; decide
