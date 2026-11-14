import ContractForge
open ContractForge

-- 13.1.7: 13.1.7 The Shunting emergency call shall be sent to all users involved in shunting operations in the shunting area. (M)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { usersNotified := x.users }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
