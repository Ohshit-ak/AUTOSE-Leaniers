import ContractForge
open ContractForge

-- 5.6.1/S1: Incoming calls to the Cab radio shall be routed to the correct on-train user or device using information contained in the sub-addressing field.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  subAddress : String
  onTrainUsers : List String
  deriving DecidableEq, Repr

structure Output where
  routedTo : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.subAddress ≠ "" ∧ i.onTrainUsers.Nodup
  post := fun i o => 
    (∃ u ∈ i.onTrainUsers, o.routedTo = u ↔ i.subAddress = u) ∧
    (o.routedTo = "" ↔ ¬ ∃ u ∈ i.onTrainUsers, i.subAddress = u)

example : Spec.pre { subAddress := "user1", onTrainUsers := ["user1", "user2"] } ∧
          Spec.post { subAddress := "user1", onTrainUsers := ["user1", "user2"] }
                    { routedTo := "user1" } := by
  unfold Spec; decide
