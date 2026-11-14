import ContractForge
open ContractForge

-- 5.5.11/S1: Stored number access shall be provided to initiate the following calls: (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  storedNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  callInitiated : Bool
  callType      : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.storedNumbers ≠ []
  post := fun i o => o.callInitiated = true ↔
    ∃ s ∈ i.storedNumbers, s = "M" ∧
    (o.callType = "M" ↔ s = "M") ∧
    (o.callInitiated = false → o.callType = "")

example : Spec.pre { storedNumbers := ["M", "N"] } ∧
          Spec.post { storedNumbers := ["M", "N"] }
                    { callInitiated := true, callType := "M" } := by
  unfold Spec; decide
