import ContractForge
open ContractForge

-- DD-location: Place where the item is kept in the warehouse in the form of (aisle, column, shelf)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 3 ∧
     i.raw.toList[0] = 'a' ∧
     i.raw.toList[1] = 'c' ∧
     i.raw.toList[2] = 's' ∧
     i.raw.toList[3] = ',' ∧
     i.raw.toList[4] = ' ' ∧
     i.raw.toList[5] = 'a' ∧
     i.raw.toList[6] = 'i' ∧
     i.raw.toList[7] = 'l' ∧
     i.raw.toList[8] = 'e' ∧
     i.raw.toList[9] = ',' ∧
     i.raw.toList[10] = ' ' ∧
     i.raw.toList[11] = 'c' ∧
     i.raw.toList[12] = 'o' ∧
     i.raw.toList[13] = 'l' ∧
     i.raw.toList[14] = 'u' ∧
     i.raw.toList[15] = 'm' ∧
     i.raw.toList[16] = ',' ∧
     i.raw.toList[17] = ' ' ∧
     i.raw.toList[18] = 's' ∧
     i.raw.toList[19] = 'h' ∧
     i.raw.toList[20] = 'l' ∧
     i.raw.toList[21] = 'f' ∧
     i.raw.toList[22] = 'e')

example : Spec.pre { raw := "aile, column, shelf" } ∧
          Spec.post { raw := "aile, column, shelf" }
                    { valid := true } := by
  unfold Spec; decide
