import ContractForge
open ContractForge

-- 13.2.3.3: 13.2.3.3 The information shall be received by the same set of users who received the warning tone. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  users   : List String
  deriving DecidableEq, Repr

structure Output where
  users   : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.users = i.users ∧
                     (o.users.length = i.users.length ∧
                      ∀ u ∈ o.users, ∃ u' ∈ i.users, u = u')

example : Spec.pre { users := ["user1", "user2", "user3"] } ∧
          Spec.post { users := ["user1", "user2", "user3"] }
                    { users := ["user1", "user2", "user3"] } := by
  unfold Spec; decide
