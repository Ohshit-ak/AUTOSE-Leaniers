import ContractForge
open ContractForge

-- 4.5.21/S1: For determining battery requirements, the transmit/receive duty cycles used shall be as shown in table 4-7 for each call type.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  transmitDutyCycle : Nat
  receiveDutyCycle  : Nat
  callType         : String
  deriving DecidableEq, Repr

structure Output where
  batteryRequirement : Nat
  deriving DecidableEq, Repr

-- Define the duty cycles for each call type
def dutyCycles : List (String × Nat × Nat) :=
  [ ("voice", 10, 20),
    ("data",  5, 15) ]

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => 
    (∃ (callType, transmitDuty, receiveDuty) ∈ dutyCycles,
      i.callType = callType ∧
      i.transmitDutyCycle = transmitDuty ∧
      i.receiveDutyCycle = receiveDuty) →
    o.batteryRequirement = (transmitDuty + receiveDuty) * 60

example : Spec.pre { transmitDutyCycle := 10, receiveDutyCycle := 20, callType := "voice" } ∧
          Spec.post { transmitDutyCycle := 10, receiveDutyCycle := 20, callType := "voice" }
                    { batteryRequirement := 1800 } := by
  unfold Spec; decide
