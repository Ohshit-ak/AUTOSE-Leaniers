import ContractForge
open ContractForge

-- 13.2.3.3: 13.2.3.3 The information shall be received by the same set of users who received the warning tone. (M)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { users := x.users }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
