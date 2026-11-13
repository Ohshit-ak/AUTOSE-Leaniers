import ContractForge
open ContractForge

-- 13.2.3.3: 13.2.3.3 The information shall be received by the same set of users who received the warning tone. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  warningUsers : List String
  deriving DecidableEq, Repr

structure Output where
  informationUsers : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.warningUsers.Nodup
  post := fun i o => o.informationUsers = i.warningUsers

example : Spec.pre { warningUsers := ["user1", "user2"] } ∧
          Spec.post { warningUsers := ["user1", "user2"] }
                    { informationUsers := ["user1", "user2"] } := by
  unfold Spec; decide
