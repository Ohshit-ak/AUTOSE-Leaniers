import ContractForge
open ContractForge

-- 10.4.1: 10.4.1 A mobile may be a member of a number of groups. It shall be possible to activate or deactivate the mobiles subscription to these groups. (M)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { mobileId := x.mobileId,
    groupId := x.groupId,
    active := decide (x.active = true) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
