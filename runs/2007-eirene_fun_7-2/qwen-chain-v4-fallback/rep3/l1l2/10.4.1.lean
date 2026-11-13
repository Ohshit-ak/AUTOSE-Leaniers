import ContractForge
open ContractForge

-- 10.4.1: 10.4.1 A mobile may be a member of a number of groups. It shall be possible to activate or deactivate the mobiles subscription to these groups. (M)

-- L0 spec

structure Input where
  mobileId : Nat
  groups   : List Nat
  deriving DecidableEq, Repr

structure Output where
  mobileId : Nat
  groups   : List Nat
  active   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.groups.Nodup
  post := fun i o => o.mobileId = i.mobileId ∧
                     o.groups = i.groups ∧
                     (o.active = true ↔ i.groups.Nodup ∧ 0 < o.groups.length)

example : Spec.pre { mobileId := 123, groups := [456, 789] } ∧
          Spec.post { mobileId := 123, groups := [456, 789] }
                    { mobileId := 123, groups := [456, 789], active := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { mobileId := x.mobileId, groups := x.groups, active := x.groups.Nodup ∧ 0 < x.groups.length }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
