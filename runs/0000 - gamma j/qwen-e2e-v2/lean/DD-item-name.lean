import ContractForge
open ContractForge

-- DD-item-name: Name of the selected item; maximum 50 character alphabetic string
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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 50 ∧
     i.raw.toList.all (·.isAlpha) = true)

example : Spec.pre { raw := "exampleName" } ∧
          Spec.post { raw := "exampleName" } { valid := true } := by
  unfold Spec; decide
