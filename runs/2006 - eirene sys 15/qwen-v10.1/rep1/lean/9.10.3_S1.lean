import ContractForge
open ContractForge

-- 9.10.3/S1: Where access to public networks is allowed, this shall be performed by using an Access Code (AC), defined in table 9-13, followed by the international or national number of the called subscriber as defined in [ITU-T 164].
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  ac : String
  number : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.ac.length = 4 ∧ i.ac.toList.all Char.isDigit = true
  post := fun i o => o.valid = true ↔
    (1 ≤ i.number.length ∧ i.number.length ≤ 15 ∧
     i.number.toList.all (·.isDigit) = true)

example : Spec.pre { ac := "1234", number := "987654321012345" } ∧
          Spec.post { ac := "1234", number := "987654321012345" }
                    { valid := true } := by
  unfold Spec; decide
