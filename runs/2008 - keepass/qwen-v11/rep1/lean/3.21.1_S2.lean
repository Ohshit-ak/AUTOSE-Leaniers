import ContractForge
open ContractForge

-- 3.21.1/S2: They can be added to user's database by using TAN wizard and can contain all letters and numbers.
-- compiles: False · rejects_bad_example: None · checked: False

structure TAN where
  value : String
  deriving DecidableEq, Repr

structure Input where
  lettersAndNumbers : String
  deriving DecidableEq, Repr

structure Output where
  tanAdded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.lettersAndNumbers.toList.all (·.isDigit ∨ ·.isAlpha) = true
  post := fun i o => o.tanAdded = true ↔
    (i.lettersAndNumbers.length ≤ 16 ∧
     i.lettersAndNumbers.length ≥ 8)

example : Spec.pre { lettersAndNumbers := "AB1234567890CD" } ∧
          Spec.post { lettersAndNumbers := "AB1234567890CD" }
                    { tanAdded := true } := by
  unfold Spec; decide
