import ContractForge
open ContractForge

-- DD-name: Name of the customer; maximum 100 alphabetic characters
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 100 ∧
     i.raw.toList.all (·.isAlpha) = true)

example : Spec.pre { raw := "JohnDoe" } ∧
          Spec.post { raw := "JohnDoe" } { valid := true } := by
  unfold Spec; decide
