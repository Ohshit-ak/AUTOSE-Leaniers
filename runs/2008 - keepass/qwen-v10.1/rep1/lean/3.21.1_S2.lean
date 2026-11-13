import ContractForge
open ContractForge

-- 3.21.1/S2: They can be added to user's database by using TAN wizard and can contain all letters and numbers.
-- compiles: True · rejects_bad_example: None · checked: True

structure TAN where
  value : String
  deriving DecidableEq, Repr

structure Input where
  tans : List TAN
  deriving DecidableEq, Repr

structure Output where
  tans : List TAN
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.tans.all (fun t => t.value.toList.all Char.isAlphanum = true)
  post := fun i o => o.tans = i.tans

example : Spec.pre { tans := [{ value := "AB12" }, { value := "CD34" }] } ∧
          Spec.post { tans := [{ value := "AB12" }, { value := "CD34" }] }
                    { tans := [{ value := "AB12" }, { value := "CD34" }] } := by
  unfold Spec; decide
