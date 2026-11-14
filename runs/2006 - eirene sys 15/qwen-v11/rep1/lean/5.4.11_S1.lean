import ContractForge
open ContractForge

-- 5.4.11/S1: On-train functions for equipment physically connected to the Cab radio shall be registered or deregistered automatically based on a USSD message (see section 11) sent by the Cab radio.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  registeredFunctions : List String
  deriving DecidableEq, Repr

structure Output where
  registeredFunctions : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.registeredFunctions = i.registeredFunctions ∧
                     (o.registeredFunctions.length = i.registeredFunctions.length ∧
                      ∀ f ∈ o.registeredFunctions, f ∈ i.registeredFunctions)

example : Spec.pre { registeredFunctions := ["func1", "func2"] } ∧
          Spec.post { registeredFunctions := ["func1", "func2"] }
                    { registeredFunctions := ["func1", "func2"] } := by
  unfold Spec; decide
