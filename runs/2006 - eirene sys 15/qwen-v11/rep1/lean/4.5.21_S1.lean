import ContractForge
open ContractForge

-- 4.5.21/S1: For determining battery requirements, the transmit/receive duty cycles used shall be as shown in table 4-7 for each call type.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  transmitDutyCycle  : Nat
  receiveDutyCycle   : Nat
  callType          : String
  deriving DecidableEq, Repr

structure Output where
  requiredBatteryCapacity : Nat
  deriving DecidableEq, Repr

-- Helper definition to check the call type and duty cycles
def checkCallType (callType : String) : Bool :=
  callType = "call1" ∨ callType = "call2" ∨ callType = "call3"

def Spec : Contract Input Output where
  pre  := fun i => checkCallType i.callType
  post := fun i o => (o.requiredBatteryCapacity = 100 * i.transmitDutyCycle + 20 * i.receiveDutyCycle ↔
    (i.callType = "call1" → i.transmitDutyCycle = 30 ∧ i.receiveDutyCycle = 20) ∧
    (i.callType = "call2" → i.transmitDutyCycle = 40 ∧ i.receiveDutyCycle = 10) ∧
    (i.callType = "call3" → i.transmitDutyCycle = 50 ∧ i.receiveDutyCycle = 30))

example : Spec.pre { transmitDutyCycle := 0, receiveDutyCycle := 20, callType := "call1" } ∧ Spec.post { transmitDutyCycle := 0, receiveDutyCycle := 20, callType := "call1" } { requiredBatteryCapacity := 1100 } := by
  unfold Spec; decide
