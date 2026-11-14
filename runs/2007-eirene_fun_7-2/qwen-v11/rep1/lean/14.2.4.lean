import ContractForge
open ContractForge

-- 14.2.4: 14.2.4 It shall be possible for all mobile members of the shunting group (except the driver) to transmit a link assurance signal. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Member where
  isDriver : Bool
  deriving DecidableEq, Repr

structure Input where
  members : List Member
  deriving DecidableEq, Repr

structure Output where
  assured : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.members.length ≥ 2
  post := fun i o => o.assured = true ↔
    ∃ m1 ∈ i.members, ¬m1.isDriver ∧
    ∃ m2 ∈ i.members, ¬m2.isDriver ∧
    m1 ≠ m2

example : Spec.pre { members := [{ isDriver := true }, { isDriver := false }] } ∧ Spec.post { members := [{ isDriver := true }, { isDriver := false }] } { assured := false } := by
  unfold Spec; decide
