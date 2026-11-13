import ContractForge
open ContractForge

-- 10.4.4: 10.4.4 In order to provide interoperability, Cab radios will be members of a number of standard groups: Railway emergency call; (M) all train drivers; (M) shunting team; (M) trackside worker. (O)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  cabId : Nat
  groupMemberships : List String
  deriving DecidableEq, Repr

structure Output where
  cabId : Nat
  groupMemberships : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabId ≠ 0
  post := fun i o => o.cabId = i.cabId ∧
                     (o.groupMemberships = ["Railway emergency call"] ∨
                      o.groupMemberships.contains "all train drivers" ∨
                      o.groupMemberships.contains "shunting team" ∨
                      o.groupMemberships.contains "trackside worker")

example : Spec.pre { cabId := 1, groupMemberships := ["Railway emergency call", "all train drivers"] } ∧
          Spec.post { cabId := 1, groupMemberships := ["Railway emergency call", "all train drivers"] }
                    { cabId := 1, groupMemberships := ["Railway emergency call", "all train drivers"] } := by
  unfold Spec; decide
