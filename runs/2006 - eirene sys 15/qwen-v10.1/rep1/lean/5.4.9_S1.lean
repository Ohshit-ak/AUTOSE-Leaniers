import ContractForge
open ContractForge

-- 5.4.9/S1: Upon detection (automatically or based on a list stored in the Cab radio) of the additional on-train functions for equipment physically connected to the Cab radio, a USSD message (see section 11) shall be sent by the Cab radio after activation of the registration or deregistration function.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  functions : List String
  registered : Bool
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.registered
  post := fun i o => o.sent ↔
    (i.functions.length > 0 ∧
     (i.registered →
      o.message = "USSD message sent after registration" ∧
      o.sent = true) ∧
     (¬i.registered →
      o.message = "USSD message sent after deregistration" ∧
      o.sent = true))

example : Spec.pre { functions := ["func1", "func2"], registered := true } ∧
          Spec.post { functions := ["func1", "func2"], registered := true }
                    { sent := true, message := "USSD message sent after registration" } := by
  unfold Spec; decide
