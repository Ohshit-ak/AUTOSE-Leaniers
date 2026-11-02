import ContractForge
open ContractForge

-- DD-state: Name of the state for the above city; maximum 20 characters alphabetic string
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.raw.length ≤ 20
  post := fun i o => (o.valid = true ↔
    (i.raw.length = 20 ∧ i.raw.toList.all (·.isAlpha) = true)) ∧
    (o.valid = false ↔
    (i.raw.length < 20))

example : Spec.pre { raw := "DD-state" } ∧
          Spec.post { raw := "DD-state" } { valid := false } := by
  unfold Spec; decide
