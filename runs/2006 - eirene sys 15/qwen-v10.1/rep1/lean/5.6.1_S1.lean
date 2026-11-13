import ContractForge
open ContractForge

-- 5.6.1/S1: Incoming calls to the Cab radio shall be routed to the correct on-train user or device using information contained in the sub-addressing field.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  subAddressing : String
  onTrainUsers  : List String
  deriving DecidableEq, Repr

structure Output where
  routedTo : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.subAddressing ≠ ""
  post := fun i o => o.routedTo = i.onTrainUsers.find (·.toList.all Char.isDigit = true) (i.subAddressing.toList.map (·.toNat))

example : Spec.pre { subAddressing := "123", onTrainUsers := ["user1", "user2"] } ∧
          Spec.post { subAddressing := "123", onTrainUsers := ["user1", "user2"] }
                    { routedTo := "user1" } := by
  unfold Spec; decide
