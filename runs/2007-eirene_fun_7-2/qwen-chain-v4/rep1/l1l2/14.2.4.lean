import ContractForge
open ContractForge

-- 14.2.4: 14.2.4 It shall be possible for all mobile members of the shunting group (except the driver) to transmit a link assurance signal. (M)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { transmitted := ∃ m ∈ x.members, m.isDriver = false }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
