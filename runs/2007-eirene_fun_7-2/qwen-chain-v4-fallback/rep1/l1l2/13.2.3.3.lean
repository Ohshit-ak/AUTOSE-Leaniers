import ContractForge
open ContractForge

-- 13.2.3.3: 13.2.3.3 The information shall be received by the same set of users who received the warning tone. (M)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { informationUsers := x.warningUsers }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
