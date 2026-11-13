import ContractForge
open ContractForge

-- 11.5.4/S1: The user-to-user information element in the SETUP, ALERT or CONNECT messages, as defined in [EN 301 515, Index [16]], shall be used to transfer the functional number of the calling party to the called party.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  callingPartyNumber : String
  deriving DecidableEq, Repr

structure Output where
  calledPartyNumber : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callingPartyNumber ≠ ""
  post := fun i o => o.calledPartyNumber = i.callingPartyNumber

example : Spec.pre { callingPartyNumber := "1234567890" } ∧
          Spec.post { callingPartyNumber := "1234567890" }
                    { calledPartyNumber := "1234567890" } := by
  unfold Spec; decide
