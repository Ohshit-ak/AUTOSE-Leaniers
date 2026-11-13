import ContractForge
open ContractForge

-- 14.2.11: 14.2.11 It shall be possible for any member of the shunting group (including a driver) to transmit a shunting emergency call to all shunting groups in the area. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Member where
  id : Nat
  deriving DecidableEq, Repr

structure ShuntingGroup where
  members : List Member
  deriving DecidableEq, Repr

structure Input where
  sender : Member
  message : String
  deriving DecidableEq, Repr

structure Output where
  recipients : List Member
  messageSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.sender ∈ i.sender.members
  post := fun i o => o.recipients = i.sender.members ∧
                     o.messageSent = true

example : Spec.pre { sender := { id := 1 }, message := "Emergency call" } ∧
          Spec.post { sender := { id := 1 }, message := "Emergency call" }
                    { recipients := [{ id := 1 }], messageSent := true } := by
  unfold Spec; decide
