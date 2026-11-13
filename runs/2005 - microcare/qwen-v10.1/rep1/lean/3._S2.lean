import ContractForge
open ContractForge

-- 3./S2: In this module you will see that every capture of data will be validated and checked on saving into the database.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.data.isEmpty = false ∧
     i.data.toList.all (fun c => c.isAlpha ∨ Char.isDigit c ∨ c == ' '))

example : Spec.pre { data := "example data" } ∧
          Spec.post { data := "example data" }
                    { valid := true } := by
  unfold Spec; decide
