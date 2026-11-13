import ContractForge
open ContractForge

-- 14.2.4: 14.2.4 It shall be possible for all mobile members of the shunting group (except the driver) to transmit a link assurance signal. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Member where
  isDriver : Bool
  deriving DecidableEq, Repr

structure Input where
  members : List Member
  deriving DecidableEq, Repr

structure Output where
  transmitted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.members.length > 1 ∧
                  ∃ m ∈ i.members, m.isDriver = false
  post := fun i o => o.transmitted = true ↔
                     ∃ m ∈ i.members, m.isDriver = false

example : Spec.pre { members := [{ isDriver := true }, { isDriver := false }] } ∧
          Spec.post { members := [{ isDriver := true }, { isDriver := false }] }
                    { transmitted := true } := by
  unfold Spec; decide
