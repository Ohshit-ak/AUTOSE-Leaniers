import ContractForge
open ContractForge

-- 9.5.1: 9.5.1 Authorised users within the EIRENE network shall be able to receive calls from calling parties outside the EIRENE network. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  callerNumber : String
  callingParty : String
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callerNumber ≠ "" ∧ i.callingParty ≠ ""
  post := fun i o => (o.accepted = true ↔
    i.callerNumber.toList.all Char.isDigit = true ∧
    i.callingParty.toList.all Char.isDigit = true)

example : Spec.pre { callerNumber := "123456789", callingParty := "987654321" } ∧
          Spec.post { callerNumber := "123456789", callingParty := "987654321" }
                    { accepted := true } := by
  unfold Spec; decide
