import ContractForge
open ContractForge

-- DD-shipping-date: Date when the specified order is shipped; format MM/DD/YYYY
-- compiles: False · rejects_bad_example: None · checked: False

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
     i.raw.toList.all (fun c => c == ' ' ∨ c.isDigit) = true ∧
     i.raw.substring 0 2 .toNat ≤ 12 ∧
     i.raw.substring 3 5 .toNat ≤ 31 ∧
     i.raw.substring 6 8 .toNat ≤ 99)

example : Spec.pre { raw := "12/31/99" } ∧
          Spec.post { raw := "12/31/99" }
                    { valid := true } := by
  unfold Spec; decide
