import ContractForge
open ContractForge

-- 3.2.1.2/S1: For those payloads identified in Table 3-2, the TCS shall be able to generate payload planning information to be uplinked to the AV separate from a flight route plan. [SSS103] The TCS shall provide the system functionality necessary to generate a payload plan that, as a minimum, shall include the following information: [SSS104]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  payloads : List String
  deriving DecidableEq, Repr

structure Output where
  payloadPlan : String
  uplinked    : Bool
  flightRoutePlan : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.payloads.Nodup
  post := fun i o => o.uplinked = true ∧
                     o.flightRoutePlan = none ∧
                     o.payloadPlan.length > 0 ∧
                     (o.payloadPlan = "payload planning information" ↔
                      i.payloads.all (fun p => p ∈ o.payloadPlan))

example : Spec.pre { payloads := ["payload1", "payload2"] } ∧
          Spec.post { payloads := ["payload1", "payload2"],
                      payloadPlan := "payload planning information for payload1 and payload2",
                      uplinked := true, flightRoutePlan := none } := by
  unfold Spec; decide
