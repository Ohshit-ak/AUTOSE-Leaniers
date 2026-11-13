import ContractForge
open ContractForge

-- 2.5.4/S1: Systems supporting OM should be able to receive, parse and process messages for laboratory test request responses, in accordance with PHIN Laboratory Test Order Response Message Implementation Guide, available at www.cdc.gov/phin.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  parsed   : Option String
  response : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ ""
  post := fun i o => (o.parsed = some "test-response" ↔
    i.message.toList.all (fun c => c.isAlphanum || c == ' ')) ∧
                     (o.parsed = some "test-response" → o.response = true)

example : Spec.pre { message := "test-response" } ∧ Spec.post { message := "test-response" } { parsed := none, response := true } := by
  unfold Spec; decide
