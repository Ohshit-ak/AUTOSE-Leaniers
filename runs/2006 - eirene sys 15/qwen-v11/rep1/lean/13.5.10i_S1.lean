import ContractForge
open ContractForge

-- 13.5.10i/S1: Confirmation centres shall be capable of decoding messages in either format A or B.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  message : String
  format  : String
  deriving DecidableEq, Repr

structure Output where
  decoded : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.format = "A" ∨ i.format = "B"
  post := fun i o => o.decoded = if i.format = "A" then "Decoded format A" else "Decoded format B"

example : Spec.pre { message := "", format := "A" } ∧
          Spec.post { message := "", format := "A" }
                    { decoded := "Decoded format A" } := by
  unfold Spec; decide
