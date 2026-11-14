import ContractForge
open ContractForge

-- 4.14.2/S2: The Qualification Methods applied to the software shall include test, demonstration, analysis, and inspection (T, D, A, I).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  method : String
  deriving DecidableEq, Repr

structure Output where
  qualified : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.qualified = true ↔
    (i.method = "T" ∨ i.method = "D" ∨ i.method = "A" ∨ i.method = "I")

example : Spec.pre { method := "T" } ∧
          Spec.post { method := "T" } { qualified := true } := by
  unfold Spec; decide
