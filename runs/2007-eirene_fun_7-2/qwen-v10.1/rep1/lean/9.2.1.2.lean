import ContractForge
open ContractForge

-- 9.2.1.2: 9.2.1.2 Each mobile shall be identified by a unique telephone number. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  telephoneNumber : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.telephoneNumber ≠ ""
  post := fun i o => o.valid = true ↔
    i.telephoneNumber.toList.all Char.isDigit = true ∧
    i.telephoneNumber.length = 10

example : Spec.pre { telephoneNumber := "1234567890" } ∧
          Spec.post { telephoneNumber := "1234567890" }
                    { valid := true } := by
  unfold Spec; decide
