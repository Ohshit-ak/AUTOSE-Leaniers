import ContractForge
open ContractForge

-- 9.2.1.1: 9.2.1.1 The EIRENE system shall enable users to originate and receive calls by functional number. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  functionalNumber : String
  deriving DecidableEq, Repr

structure Output where
  callOriginated : Bool
  callReceived   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber ≠ ""
  post := fun i o => (o.callOriginated = true ↔ i.functionalNumber = "1234567890") ∧
                     (o.callReceived = true ↔ i.functionalNumber = "1234567890")

example : Spec.pre { functionalNumber := "1234567890" } ∧
          Spec.post { functionalNumber := "1234567890" }
                    { callOriginated := true, callReceived := true } := by
  unfold Spec; decide
