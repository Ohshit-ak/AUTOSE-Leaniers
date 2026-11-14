import ContractForge
open ContractForge

-- 3./S2: In this module you will see that every capture of data will be validated and checked on saving into the database.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  data  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.data.isEmpty → o.valid = false) ∧
    (i.data.isEmpty → o.data = "") ∧
    (i.data.length ≤ 100 → i.data.length ≥ 1 → o.valid = true) ∧
    (i.data.length > 100 → o.valid = false) ∧
    (o.data = i.data)

example : Spec.pre { data := "test" } ∧
          Spec.post { data := "test" } { valid := true, data := "test" } := by
  unfold Spec; decide
