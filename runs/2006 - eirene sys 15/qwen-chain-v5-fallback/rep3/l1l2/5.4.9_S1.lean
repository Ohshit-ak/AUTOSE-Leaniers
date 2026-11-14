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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { sent := (x.activation ∧ x.functions.contains "additional_on_train_function") ∨ (¬x.activation ∧ false),
    message := if (x.activation ∧ x.functions.contains "additional_on_train_function") ∨ (¬x.activation ∧ false) then "USSD message sent" else "USSD message not sent" }
