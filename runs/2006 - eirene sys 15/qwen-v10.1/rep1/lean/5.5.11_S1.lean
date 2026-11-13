import ContractForge
open ContractForge

-- 5.5.11/S1: Stored number access shall be provided to initiate the following calls: (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  storedNumbers : List String
  callType      : String
  deriving DecidableEq, Repr

structure Output where
  callInitiated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.storedNumbers ≠ [] ∧ i.callType = "M"
  post := fun i o => o.callInitiated = true ↔
    ∃ s ∈ i.storedNumbers, s = "M" ∧ i.callType = "M"

example : Spec.pre { storedNumbers := ["M", "N"], callType := "M" } ∧ Spec.post { storedNumbers := ["M", "N"], callType := "M" } { callInitiated := true } := by
  unfold Spec; decide
