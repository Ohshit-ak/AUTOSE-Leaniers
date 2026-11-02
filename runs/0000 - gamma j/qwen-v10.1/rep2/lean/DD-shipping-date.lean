import ContractForge
open ContractForge

-- DD-shipping-date: Date when the specified order is shipped; format MM/DD/YYYY
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
    (i.raw.length = 10 ∧
     i.raw.toList.all (fun c => c.isDigit) = true ∧
     (i.raw.toList.drop 5).all (fun c => c == '/') = true)

example : Spec.pre { raw := "12/34/5678" } ∧ Spec.post { raw := "12/34/5678" } { valid := false } := by
  unfold Spec; decide
