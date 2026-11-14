import ContractForge
open ContractForge

-- 10.4.1: 10.4.1 A mobile may be a member of a number of groups. It shall be possible to activate or deactivate the mobiles subscription to these groups. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mobileId : Nat
  groupId  : Nat
  active   : Bool
  deriving DecidableEq, Repr

structure Output where
  mobileId : Nat
  groupId  : Nat
  active   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.mobileId = i.mobileId ∧
                     o.groupId = i.groupId ∧
                     (o.active = true ↔ i.active = true)

example : Spec.pre { mobileId := 1, groupId := 2, active := true } ∧
          Spec.post { mobileId := 1, groupId := 2, active := true }
                    { mobileId := 1, groupId := 2, active := true } := by
  unfold Spec; decide
