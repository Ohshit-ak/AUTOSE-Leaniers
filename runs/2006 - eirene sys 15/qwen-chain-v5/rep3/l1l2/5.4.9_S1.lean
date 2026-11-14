import ContractForge
open ContractForge

-- 5.4.9/S1: Upon detection (automatically or based on a list stored in the Cab radio) of the additional on-train functions for equipment physically connected to the Cab radio, a USSD message (see section 11) shall be sent by the Cab radio after activation of the registration or deregistration function.

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  sent : Bool
  message : String
  deriving DecidableEq, Repr

def ComputeSentContract : Contract Input Mid where
  pre  := fun i => i.registered
  post := fun i m => m.sent = (i.activation ∧ ∃ f ∈ i.functions, f = "additional_on_train_function") ∨ (¬i.activation ∧ m.sent = false)

def DetermineMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.message = "USSD message sent" ↔ o.sent = true ∧ o.sent = m.sent
