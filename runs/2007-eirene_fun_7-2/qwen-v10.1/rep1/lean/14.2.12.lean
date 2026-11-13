import ContractForge
open ContractForge

-- 14.2.12: 14.2.12 It shall be possible for all shunting drivers and shunting group members to receive a shunting emergency call from any equipment capable of taking part in shunting communications. The shunting emergency call shall cause the audible link assurance signal to be interrupted. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  shuntingDriver : Bool
  shuntingGroupMember : Bool
  equipment : Bool
  deriving DecidableEq, Repr

structure Output where
  audibleLinkAssuranceInterrupted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shuntingDriver ∨ i.shuntingGroupMember ∨ i.equipment
  post := fun i o => (o.audibleLinkAssuranceInterrupted = true ↔
    i.shuntingDriver ∨ i.shuntingGroupMember) ∧
    (o.audibleLinkAssuranceInterrupted = false → o.audibleLinkAssuranceInterrupted = false)

example : Spec.pre { shuntingDriver := true, shuntingGroupMember := false, equipment := false } ∧
          Spec.post { shuntingDriver := true, shuntingGroupMember := false, equipment := false }
                    { audibleLinkAssuranceInterrupted := true } := by
  unfold Spec; decide
