import ContractForge
open ContractForge

-- 5.4.9/S1: Upon detection (automatically or based on a list stored in the Cab radio) of the additional on-train functions for equipment physically connected to the Cab radio, a USSD message (see section 11) shall be sent by the Cab radio after activation of the registration or deregistration function.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  functions : List String
  registered : Bool
  activation : Bool
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.registered
  post := fun i o => (o.sent = true ↔
    (i.activation ∧ ∃ f ∈ i.functions, f = "additional_on_train_function") ∨
    (¬i.activation ∧ o.sent = false)) ∧
    (o.message = "USSD message sent" ↔ o.sent = true)

example : Spec.pre { functions := ["additional_on_train_function", "other_function"], registered := true, activation := true } ∧ Spec.post { functions := ["additional_on_train_function", "other_function"], registered := true, activation := true } { sent := true, message := "USSD message sent" } := by
  unfold Spec; decide
