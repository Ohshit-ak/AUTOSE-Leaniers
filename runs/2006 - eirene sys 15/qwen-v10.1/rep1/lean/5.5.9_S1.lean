import ContractForge
open ContractForge

-- 5.5.9/S1: The driver shall be able to initiate a call by selecting a name/number from stored number information in the radio.
-- compiles: True · rejects_bad_example: True · checked: True

structure StoredNumber where
  name  : String
  number : String
  deriving DecidableEq, Repr

structure Input where
  selectedNumber : Option StoredNumber
  callsInProgress : Nat
  deriving DecidableEq, Repr

structure Output where
  callInitiated : Bool
  callsInProgress : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selectedNumber.isSome
  post := fun i o => o.callInitiated = true ∧
                     o.callsInProgress = i.callsInProgress + 1

example : Spec.pre { selectedNumber := some { name := "John", number := "1234567890" },
                     callsInProgress := 0 } ∧
          Spec.post { selectedNumber := some { name := "John", number := "1234567890" },
                      callsInProgress := 0 }
                    { callInitiated := true, callsInProgress := 1 } := by
  unfold Spec; decide
