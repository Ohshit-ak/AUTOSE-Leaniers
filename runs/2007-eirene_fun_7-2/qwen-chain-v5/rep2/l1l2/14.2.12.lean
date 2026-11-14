import ContractForge
open ContractForge

-- 14.2.12: 14.2.12 It shall be possible for all shunting drivers and shunting group members to receive a shunting emergency call from any equipment capable of taking part in shunting communications. The shunting emergency call shall cause the audible link assurance signal to be interrupted. (M)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { audibleLinkAssuranceInterrupted := decide (x.shuntingDriver ∨ x.shuntingGroupMember) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
