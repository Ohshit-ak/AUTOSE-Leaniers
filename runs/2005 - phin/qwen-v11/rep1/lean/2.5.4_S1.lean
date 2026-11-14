import ContractForge
open ContractForge

-- 2.5.4/S1: Systems supporting OM should be able to receive, parse and process messages for laboratory test request responses, in accordance with PHIN Laboratory Test Order Response Message Implementation Guide, available at www.cdc.gov/phin.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  parsed   : Option String
  response : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ ""
  post := fun i o => (o.parsed = some "Lab test request response" ↔
    i.message.toList.all Char.isAlpha = true ∧ i.message.length = 30) ∧
                     (o.response = true ↔ o.parsed = some "Lab test request response")

example : Spec.pre { message := "Lab test request response" } ∧ Spec.post { message := "Lab test request response" } { parsed := none, response := false } := by
  unfold Spec; decide
