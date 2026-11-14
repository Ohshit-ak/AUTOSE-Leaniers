import ContractForge
open ContractForge

-- 3.2.3/S1: The TCS will have the functionality necessary to manage all aspects of payload product handling to include receiving, processing, displaying, and performing limited exploitation.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  payloadId : String
  operation : String
  data      : String
  deriving DecidableEq, Repr

structure Output where
  success   : Bool
  message   : String
  payloadId : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.operation ∈ ["receive", "process", "display", "exploit"]
  post := fun i o => (o.success = true ↔
    (i.operation = "receive" → i.data ≠ "" ∧ i.data.length ≤ 1000) ∧
    (i.operation = "process" → i.data ≠ "" ∧ i.data.length ≤ 1000) ∧
    (i.operation = "display" → i.data ≠ "" ∧ i.data.length ≤ 1000) ∧
    (i.operation = "exploit" → i.data ≠ "" ∧ i.data.length ≤ 1000))

example : Spec.pre { payloadId := "P123", operation := "receive", data := "data123" } ∧
          Spec.post { payloadId := "P123", operation := "receive", data := "data123" }
                    { success := true, message := "", payloadId := "P123" } := by
  unfold Spec; decide
