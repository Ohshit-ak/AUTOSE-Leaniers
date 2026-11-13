import ContractForge
open ContractForge

-- 13.1.7: 13.1.7 The Shunting emergency call shall be sent to all users involved in shunting operations in the shunting area. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure User where
  name : String
  deriving DecidableEq, Repr

structure Input where
  users : List User
  deriving DecidableEq, Repr

structure Output where
  usersNotified : List User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.users.length > 0
  post := fun i o => o.usersNotified = i.users

example : Spec.pre { users := [{ name := "Alice" }, { name := "Bob" }] } ∧
          Spec.post { users := [{ name := "Alice" }, { name := "Bob" }] }
                    { usersNotified := [{ name := "Alice" }, { name := "Bob" }] } := by
  unfold Spec; decide
